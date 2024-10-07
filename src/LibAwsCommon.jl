module LibAwsCommon

using aws_c_common_jll

const IS_LIBC_MUSL = occursin("musl", Base.BUILD_TRIPLET)
if Sys.isapple() && Sys.ARCH === :aarch64
    include("../lib/aarch64-apple-darwin20.jl")
elseif Sys.islinux() && Sys.ARCH === :aarch64 && !IS_LIBC_MUSL
    include("../lib/aarch64-linux-gnu.jl")
elseif Sys.islinux() && Sys.ARCH === :aarch64 && IS_LIBC_MUSL
    include("../lib/aarch64-linux-musl.jl")
elseif Sys.islinux() && startswith(string(Sys.ARCH), "arm") && !IS_LIBC_MUSL
    include("../lib/armv7l-linux-gnueabihf.jl")
elseif Sys.islinux() && startswith(string(Sys.ARCH), "arm") && IS_LIBC_MUSL
    include("../lib/armv7l-linux-musleabihf.jl")
elseif Sys.islinux() && Sys.ARCH === :i686 && !IS_LIBC_MUSL
    include("../lib/i686-linux-gnu.jl")
elseif Sys.islinux() && Sys.ARCH === :i686 && IS_LIBC_MUSL
    include("../lib/i686-linux-musl.jl")
elseif Sys.iswindows() && Sys.ARCH === :i686
    error("LibAwsCommon.jl does not support i686 windows https://github.com/JuliaPackaging/Yggdrasil/blob/bbab3a916ae5543902b025a4a873cf9ee4a7de68/A/aws_c_common/build_tarballs.jl#L48-L49")
elseif Sys.islinux() && Sys.ARCH === :powerpc64le
    include("../lib/powerpc64le-linux-gnu.jl")
elseif Sys.isapple() && Sys.ARCH === :x86_64
    include("../lib/x86_64-apple-darwin14.jl")
elseif Sys.islinux() && Sys.ARCH === :x86_64 && !IS_LIBC_MUSL
    include("../lib/x86_64-linux-gnu.jl")
elseif Sys.islinux() && Sys.ARCH === :x86_64 && IS_LIBC_MUSL
    include("../lib/x86_64-linux-musl.jl")
elseif Sys.isbsd() && !Sys.isapple()
    include("../lib/x86_64-unknown-freebsd13.2.jl")
elseif Sys.iswindows() && Sys.ARCH === :x86_64
    include("../lib/x86_64-w64-mingw32.jl")
else
    error("Unknown platform: $(Base.BUILD_TRIPLET)")
end

# exports
for name in names(@__MODULE__; all=true)
    if name == :eval || name == :include || contains(string(name), "#")
        continue
    end
    @eval export $name
end

const DEFAULT_AWS_ALLOCATOR = Ref{Ptr{aws_allocator}}(C_NULL)
const DEFAULT_AWS_ALLOCATOR_LOCK = ReentrantLock()

function set_default_aws_allocator!(allocator)
    @lock DEFAULT_AWS_ALLOCATOR_LOCK begin
        DEFAULT_AWS_ALLOCATOR[] = allocator
        return
    end
end

function default_aws_allocator()
    @lock DEFAULT_AWS_ALLOCATOR_LOCK begin
        if DEFAULT_AWS_ALLOCATOR[] == C_NULL
            set_default_aws_allocator!(aws_default_allocator())
        end
        return DEFAULT_AWS_ALLOCATOR[]
    end
end

mem_trace_allocator(allocator=default_aws_allocator(), mem_trace_level=AWS_MEMTRACE_STACKS, frames_per_stack=8) = aws_mem_tracer_new(allocator, C_NULL, mem_trace_level, frames_per_stack)

export default_aws_allocator, set_default_aws_allocator!

function init(allocator=default_aws_allocator())
    aws_common_library_init(allocator)
    return
end

end
