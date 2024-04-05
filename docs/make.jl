using LibAwsCommon
using Documenter

DocMeta.setdocmeta!(LibAwsCommon, :DocTestSetup, :(using LibAwsCommon); recursive=true)

makedocs(;
    modules=[LibAwsCommon],
    repo="https://github.com/JuliaServices/LibAwsCommon.jl/blob/{commit}{path}#{line}",
    sitename="LibAwsCommon.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://github.com/JuliaServices/LibAwsCommon.jl",
        assets=String[],
        size_threshold=2_000_000, # 2 MB, we generate about 1 MB page
        size_threshold_warn=2_000_000,
    ),
    pages=["Home" => "index.md"],
)

deploydocs(; repo="github.com/JuliaServices/LibAwsCommon.jl", devbranch="main")
