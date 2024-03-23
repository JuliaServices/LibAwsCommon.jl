module LibAwsCommon

using aws_c_common_jll

if Sys.iswindows() && Sys.ARCH === :i686
    error("LibAwsCommon.jl does not support i686 windows https://github.com/JuliaPackaging/Yggdrasil/blob/bbab3a916ae5543902b025a4a873cf9ee4a7de68/A/aws_c_common/build_tarballs.jl#L48-L49")
else
    include("lib.jl")
end

# exports
for name in names(@__MODULE__; all=true)
    nm = string(name)
    if startswith(nm, "aws_") || startswith(nm, "AWS_")
        @eval export $name
    end
end

end
