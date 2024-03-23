using Documenter, LibAwsCommon

makedocs(modules=[LibAwsCommon], sitename="LibAwsCommon.jl")

deploydocs(repo="github.com/quinnj/LibAwsCommon.jl.git", push_preview=true)
