using Clang.Generators
using aws_c_common_jll

cd(@__DIR__)

include_dir = normpath(aws_c_common_jll.artifact_dir, "include", "aws", "common")

options = load_options(joinpath(@__DIR__, "generator.toml"))

args = get_default_args()

headers = filter!(x -> endswith(x, ".h"), readdir(include_dir; join=true, sort=true))

# create context
ctx = create_context(headers, args, options)

# run generator
build!(ctx)
