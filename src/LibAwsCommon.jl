module LibAwsCommon

using aws_c_common_jll
export aws_c_common_jll

const IS_LIBC_MUSL = occursin("musl", Base.BUILD_TRIPLET)
if Sys.isapple() && Sys.ARCH === :aarch64
    include("lib.jl")
elseif Sys.islinux() && Sys.ARCH === :aarch64 && !IS_LIBC_MUSL
    include("lib.jl")
elseif Sys.islinux() && Sys.ARCH === :aarch64 && IS_LIBC_MUSL
    include("lib.jl")
elseif Sys.islinux() && startswith(string(Sys.ARCH), "arm") && !IS_LIBC_MUSL
    include("lib.jl")
elseif Sys.islinux() && startswith(string(Sys.ARCH), "arm") && IS_LIBC_MUSL
    include("lib.jl")
elseif Sys.islinux() && Sys.ARCH === :i686 && !IS_LIBC_MUSL
    include("lib.jl")
elseif Sys.islinux() && Sys.ARCH === :i686 && IS_LIBC_MUSL
    include("lib.jl")
elseif Sys.iswindows() && Sys.ARCH === :i686
    error("LibAwsCommon.jl does not support i686 windows https://github.com/JuliaPackaging/Yggdrasil/blob/bbab3a916ae5543902b025a4a873cf9ee4a7de68/A/aws_c_common/build_tarballs.jl#L48-L49")
elseif Sys.islinux() && Sys.ARCH === :powerpc64le
    include("lib.jl")
elseif Sys.isapple() && Sys.ARCH === :x86_64
    include("lib.jl")
elseif Sys.islinux() && Sys.ARCH === :x86_64 && !IS_LIBC_MUSL
    include("lib.jl")
elseif Sys.islinux() && Sys.ARCH === :x86_64 && IS_LIBC_MUSL
    include("lib.jl")
elseif Sys.isbsd() && !Sys.isapple()
    include("lib.jl")
elseif Sys.iswindows() && Sys.ARCH === :x86_64
    include("lib.jl")
else
    error("Unknown platform: $(Base.BUILD_TRIPLET)")
end

# exports
const PREFIXES = ["aws_", "AWS_"]
for name in names(@__MODULE__; all=true), prefix in PREFIXES
    if startswith(string(name), prefix)
        @eval export $name
    end
end

end
