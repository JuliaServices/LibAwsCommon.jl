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

# utilities for interacting with AWS library APIs

# like a Ref, but for a field of a struct
# many AWS APIs take a pointer to an aws struct, so this makes it convenient to to pass
# a field of a wrapper struct to a library function
struct FieldRef{T, S}
    x::T
    field::Symbol

    function FieldRef(x::T, field::Symbol) where {T}
        @assert isconcretetype(T) && ismutabletype(T) "only fields of mutable types are supported with FieldRef"
        S = fieldtype(T, field)
        @assert isconcretetype(S) && !ismutabletype(S) "field type must be concrete and immutable for FieldRef"
        return new{T, S}(x, field)
    end
end

function Base.unsafe_convert(P::Union{Type{Ptr{S}},Type{Ptr{Cvoid}}}, x::FieldRef{T, S}) where {T, S}
    return P(pointer_from_objref(x.x) + fieldoffset(T, Base.fieldindex(T, x.field)))
end

Base.pointer(x::FieldRef{S, T}) where {S, T} = Base.unsafe_convert(Ptr{T}, x)

# wraps a pointer to a struct and allows get/set on fields w/o unsafe_loading the entire struct
struct StructRef{T}
    ptr::Ptr{T}

    function StructRef(ptr::Ptr{T}) where {T}
        @assert isconcretetype(T) "only concrete struct types are supported with StructRef"
        return new{T}(ptr)
    end
end

function Base.getproperty(x::StructRef{T}, k::Symbol) where {T}
    S = fieldtype(T, k)
    @assert isconcretetype(S) && !ismutabletype(S) "field type must be concrete and immutable for StructRef"
    return unsafe_load(Ptr{S}(Ptr{UInt8}(getfield(x, :ptr)) + fieldoffset(T, Base.fieldindex(T, k))))
end

function Base.setproperty!(x::StructRef{T}, k::Symbol, v) where {T}
    S = fieldtype(T, k)
    @assert isconcretetype(S) && !ismutabletype(S) "field type must be concrete and immutable for StructRef"
    unsafe_store!(Ptr{S}(Ptr{UInt8}(getfield(x, :ptr)) + fieldoffset(T, Base.fieldindex(T, k))), convert(S, v))
    return v
end

# simple threadsafe Future impl appropriate for use with the common callback patterns in AWS libs
mutable struct Future{T}
    const notify::Threads.Condition
    @atomic set::Int8 # if 0, result is undefined, 1 means result is T, 2 means result is an exception
    result::Union{Exception, T} # undefined initially
    Future{T}() where {T} = new{T}(Threads.Condition(), 0)
end

Base.pointer(f::Future) = pointer_from_objref(f)
Future(ptr::Ptr) = unsafe_pointer_to_objref(ptr)::Future
Future{T}(ptr::Ptr) where {T} = unsafe_pointer_to_objref(ptr)::Future{T}

function Base.wait(f::Future{T}) where {T}
    set = @atomic f.set
    set == 1 && return f.result::T
    set == 2 && throw(f.result::Exception)
    lock(f.notify) # acquire barrier
    try
        set = f.set
        set == 1 && return f.result::T
        set == 2 && throw(f.result::Exception)
        wait(f.notify)
    finally
        unlock(f.notify) # release barrier
    end
    if f.set == 1
        return f.result::T
    else
        @assert isdefined(f, :result)
        throw(f.result::Exception)
    end
end

capture(e::Exception) = CapturedException(e, Base.backtrace())

function Base.notify(f::Future{T}, x::Union{Exception, T}) where {T}
    lock(f.notify) # acquire barrier
    try
        if f.set == Int8(0)
            if x isa Exception
                set = Int8(2)
                f.result = x
            else
                set = Int8(1)
                f.result = x
            end
            @atomic :release f.set = set
            notify(f.notify)
        end
    finally
        unlock(f.notify)
    end
    nothing
end

end
