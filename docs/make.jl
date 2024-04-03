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
    ),
    pages=["Home" => "index.md"],
)

deploydocs(; repo="github.com/JuliaServices/LibAwsCommon.jl", devbranch="main")
