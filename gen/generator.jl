using Clang.Generators
using Clang.JLLEnvs
using JLLPrefixes
import aws_c_common_jll

cd(@__DIR__)

for target in JLLEnvs.JLL_ENV_TRIPLES
    if target == "i686-w64-mingw32"
        # aws_c_common_jll does not support i686 windows https://github.com/JuliaPackaging/Yggdrasil/blob/bbab3a916ae5543902b025a4a873cf9ee4a7de68/A/aws_c_common/build_tarballs.jl#L48-L49
        continue
    end
    options = load_options(joinpath(@__DIR__, "generator.toml"))
    options["general"]["output_file_path"] = joinpath(@__DIR__, "..", "lib", "$target.jl")

    header_dirs = []
    args = get_default_args(target)
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
    build!(ctx)
end
