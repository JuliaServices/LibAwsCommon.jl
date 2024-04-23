using Clang.Generators
using Clang.JLLEnvs
using JLLPrefixes
import aws_c_common_jll

cd(@__DIR__)

function node_is_ignored(node)
    for expr in get_exprs(node)
        node_name = if expr.head == :function
            if expr.args[1].args[1] isa Expr # function is Module.name instead of just name
                expr.args[1].args[1].args[2]
            else
                expr.args[1].args[1]
            end
        elseif expr.head == :struct
            if expr.args[2] isa Expr # struct has type parameter
                expr.args[2].args[1]
            else
                expr.args[2]
            end
        elseif expr.head == :const
            expr.args[1].args[1]
        end
        return contains(lowercase(string(node_name)), "itt")
    end
    return false
end

function remove_itt_symbols!(dag::ExprDAG)
    for i in eachindex(dag.nodes)
        # remove the node by renaming it to IGNORED, which we include in the generator's ignorelist
        node = dag.nodes[i]
        if node_is_ignored(node)
            dag.nodes[i] = ExprNode(:IGNORED, node.type, node.cursor, node.exprs, node.premature_exprs, node.adj)
        end
    end
    return nothing
end

const refs_to_remove = ("AWS_CONTAINER_OF", "AWS_STATIC_STRING_FROM_LITERAL",)

# This is called if the docs generated from the extract_c_comment_style method did not generate any lines.
# We need to generate at least some docs so that cross-references work with Documenter.jl.
function get_docs(node, docs)
    # The macro node types (except for MacroDefault) seem to not generate code, but they will still emit docs and then
    # you end up with docs stacked on top of each other, which is a Julia LoadError.
    if node.type isa Generators.AbstractMacroNodeType && !(node.type isa Generators.MacroDefault)
        return String[]
    end

    # don't generate empty docs because it makes Documenter.jl mad
    if isempty(docs)
        return ["Documentation not found."]
    end

    # remove references to things which don't exist because it causes Documenter.jl's cross_references check to fail
    for ref in refs_to_remove
        for doci in eachindex(docs)
            docs[doci] = replace(docs[doci], "[`$ref`](@ref)" => "`$ref`")
        end
    end

    # fix other random stuff
    for doci in eachindex(docs)
        # fix some code that gets bogus references inserted
        docs[doci] = replace(docs[doci], "for (struct [`aws_hash_iter`](@ref) iter = [`aws_hash_iter_begin`](@ref)(&map); ![`aws_hash_iter_done`](@ref)(&iter); [`aws_hash_iter_next`](@ref)(&iter)) { const key\\_type key = *(const key\\_type *)iter.element.key; value\\_type value = *(value\\_type *)iter.element.value; // etc. }" => "`for (struct aws_hash_iter iter = aws_hash_iter_begin(&map); !aws_hash_iter_done(&iter); aws_hash_iter_next(&iter)) { const key\\_type key = *(const key\\_type *)iter.element.key; value\\_type value = *(value\\_type *)iter.element.value; // etc. }`")
    end

    return docs
end

function should_skip_target(target)
    # aws_c_common_jll does not support i686 windows https://github.com/JuliaPackaging/Yggdrasil/blob/bbab3a916ae5543902b025a4a873cf9ee4a7de68/A/aws_c_common/build_tarballs.jl#L48-L49
    return target == "i686-w64-mingw32"
end

# download toolchains in parallel
Threads.@threads for target in JLLEnvs.JLL_ENV_TRIPLES
    if should_skip_target(target)
        continue
    end
    get_default_args(target) # downloads the toolchain
end

for target in JLLEnvs.JLL_ENV_TRIPLES
    if should_skip_target(target)
        continue
    end
    options = load_options(joinpath(@__DIR__, "generator.toml"))
    options["general"]["output_file_path"] = joinpath(@__DIR__, "..", "lib", "$target.jl")
    options["general"]["callback_documentation"] = get_docs

    header_dirs = []
    args = get_default_args(target)
    push!(args, "-fparse-all-comments")
    inc = JLLEnvs.get_pkg_include_dir(aws_c_common_jll, target)
    push!(args, "-I$inc")
    push!(header_dirs, inc)

    headers = String[]
    for header_dir in header_dirs
        for (root, dirs, files) in walkdir(header_dir)
            for file in files
                if endswith(file, ".h")
                    push!(headers, joinpath(root, file))
                end
            end
        end
    end
    unique!(headers)

    ctx = create_context(headers, args, options)

    # build without printing so we can do custom rewriting
    build!(ctx, BUILDSTAGE_NO_PRINTING)

    # the ITT symbols are just for aws-c-common's profiling stuff, we don't need to generate them and they cause
    # problems with the generated code
    remove_itt_symbols!(ctx.dag)

    # print
    build!(ctx, BUILDSTAGE_PRINTING_ONLY)
end
