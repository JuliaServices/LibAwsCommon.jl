using aws_c_common_jll
export aws_c_common_jll

using CEnum

const __darwin_time_t = Clong

struct __darwin_pthread_handler_rec
    __routine::Ptr{Cvoid}
    __arg::Ptr{Cvoid}
    __next::Ptr{__darwin_pthread_handler_rec}
end

struct _opaque_pthread_once_t
    __sig::Clong
    __opaque::NTuple{8, Cchar}
end

struct _opaque_pthread_rwlock_t
    __sig::Clong
    __opaque::NTuple{192, Cchar}
end

struct _opaque_pthread_t
    __sig::Clong
    __cleanup_stack::Ptr{__darwin_pthread_handler_rec}
    __opaque::NTuple{8176, Cchar}
end

const __darwin_pthread_once_t = _opaque_pthread_once_t

const __darwin_pthread_rwlock_t = _opaque_pthread_rwlock_t

const __darwin_pthread_t = Ptr{_opaque_pthread_t}

const time_t = __darwin_time_t

const pthread_once_t = __darwin_pthread_once_t

const pthread_rwlock_t = __darwin_pthread_rwlock_t

const pthread_t = __darwin_pthread_t

struct aws_allocator
    mem_acquire::Ptr{Cvoid}
    mem_release::Ptr{Cvoid}
    mem_realloc::Ptr{Cvoid}
    mem_calloc::Ptr{Cvoid}
    impl::Ptr{Cvoid}
end

"""
    aws_default_allocator()

### Prototype
```c
AWS_COMMON_API struct aws_allocator *aws_default_allocator(void);
```
"""
function aws_default_allocator()
    @ccall libaws_c_common.aws_default_allocator()::Ptr{Cint}
end

mutable struct __CFAllocator end

const CFAllocatorRef = Ptr{__CFAllocator}

"""
    aws_wrapped_cf_allocator_destroy(allocator)

### Prototype
```c
AWS_COMMON_API void aws_wrapped_cf_allocator_destroy(CFAllocatorRef allocator);
```
"""
function aws_wrapped_cf_allocator_destroy(allocator)
    @ccall libaws_c_common.aws_wrapped_cf_allocator_destroy(allocator::CFAllocatorRef)::Cint
end

"""
    aws_mem_acquire(allocator, size)

### Prototype
```c
AWS_COMMON_API void *aws_mem_acquire(struct aws_allocator *allocator, size_t size);
```
"""
function aws_mem_acquire(allocator, size)
    @ccall libaws_c_common.aws_mem_acquire(allocator::Ptr{aws_allocator}, size::Cint)::Ptr{Cint}
end

"""
    aws_mem_calloc(allocator, num, size)

### Prototype
```c
AWS_COMMON_API void *aws_mem_calloc(struct aws_allocator *allocator, size_t num, size_t size);
```
"""
function aws_mem_calloc(allocator, num, size)
    @ccall libaws_c_common.aws_mem_calloc(allocator::Ptr{aws_allocator}, num::Cint, size::Cint)::Ptr{Cint}
end

"""
    aws_mem_release(allocator, ptr)

### Prototype
```c
AWS_COMMON_API void aws_mem_release(struct aws_allocator *allocator, void *ptr);
```
"""
function aws_mem_release(allocator, ptr)
    @ccall libaws_c_common.aws_mem_release(allocator::Ptr{aws_allocator}, ptr::Ptr{Cvoid})::Cint
end

"""
    aws_mem_realloc(allocator, ptr, oldsize, newsize)

### Prototype
```c
AWS_COMMON_API int aws_mem_realloc(struct aws_allocator *allocator, void **ptr, size_t oldsize, size_t newsize);
```
"""
function aws_mem_realloc(allocator, ptr, oldsize, newsize)
    @ccall libaws_c_common.aws_mem_realloc(allocator::Ptr{aws_allocator}, ptr::Ptr{Ptr{Cvoid}}, oldsize::Cint, newsize::Cint)::Cint
end

@cenum aws_mem_trace_level::UInt32 begin
    AWS_MEMTRACE_NONE = 0
    AWS_MEMTRACE_BYTES = 1
    AWS_MEMTRACE_STACKS = 2
end

"""
    aws_mem_tracer_new(allocator, deprecated, level, frames_per_stack)

### Prototype
```c
AWS_COMMON_API struct aws_allocator *aws_mem_tracer_new( struct aws_allocator *allocator, struct aws_allocator *deprecated, enum aws_mem_trace_level level, size_t frames_per_stack);
```
"""
function aws_mem_tracer_new(allocator, deprecated, level, frames_per_stack)
    @ccall libaws_c_common.aws_mem_tracer_new(allocator::Ptr{aws_allocator}, deprecated::Ptr{aws_allocator}, level::aws_mem_trace_level, frames_per_stack::Cint)::Ptr{Cint}
end

"""
    aws_mem_tracer_destroy(trace_allocator)

### Prototype
```c
AWS_COMMON_API struct aws_allocator *aws_mem_tracer_destroy(struct aws_allocator *trace_allocator);
```
"""
function aws_mem_tracer_destroy(trace_allocator)
    @ccall libaws_c_common.aws_mem_tracer_destroy(trace_allocator::Ptr{aws_allocator})::Ptr{Cint}
end

"""
    aws_mem_tracer_dump(trace_allocator)

### Prototype
```c
AWS_COMMON_API void aws_mem_tracer_dump(struct aws_allocator *trace_allocator);
```
"""
function aws_mem_tracer_dump(trace_allocator)
    @ccall libaws_c_common.aws_mem_tracer_dump(trace_allocator::Ptr{aws_allocator})::Cint
end

"""
    aws_small_block_allocator_new(allocator, multi_threaded)

### Prototype
```c
AWS_COMMON_API struct aws_allocator *aws_small_block_allocator_new(struct aws_allocator *allocator, bool multi_threaded);
```
"""
function aws_small_block_allocator_new(allocator, multi_threaded)
    @ccall libaws_c_common.aws_small_block_allocator_new(allocator::Ptr{aws_allocator}, multi_threaded::Cint)::Ptr{Cint}
end

"""
    aws_small_block_allocator_destroy(sba_allocator)

### Prototype
```c
AWS_COMMON_API void aws_small_block_allocator_destroy(struct aws_allocator *sba_allocator);
```
"""
function aws_small_block_allocator_destroy(sba_allocator)
    @ccall libaws_c_common.aws_small_block_allocator_destroy(sba_allocator::Ptr{aws_allocator})::Cint
end

@cenum __JL_Ctag_6::UInt32 begin
    AWS_ARRAY_LIST_DEBUG_FILL = 221
end

struct aws_array_list
    alloc::Ptr{aws_allocator}
    current_size::Csize_t
    length::Csize_t
    item_size::Csize_t
    data::Ptr{Cvoid}
end

# typedef int ( aws_array_list_comparator_fn ) ( const void * a , const void * b )
"""
Prototype for a comparator function for sorting elements.

a and b should be cast to pointers to the element type held in the list before being dereferenced. The function should compare the elements and return a positive number if a > b, zero if a = b, and a negative number if a < b.
"""
const aws_array_list_comparator_fn = Cvoid

"""
    aws_array_list_init_dynamic(AWS_RESTRICT_)

Initializes an array list with an array of size initial\\_item\\_allocation * item\\_size. In this mode, the array size will grow by a factor of 2 upon insertion if space is not available. initial\\_item\\_allocation is the number of elements you want space allocated for. item\\_size is the size of each element in bytes. Mixing items types is not supported by this API.

### Prototype
```c
int aws_array_list_init_dynamic( struct aws_array_list *AWS_RESTRICT list, struct aws_allocator *alloc, size_t initial_item_allocation, size_t item_size);
```
"""
function aws_array_list_init_dynamic(AWS_RESTRICT_)
    @ccall libaws_c_common.aws_array_list_init_dynamic(AWS_RESTRICT_::Ptr{aws_array_list})::Cint
end

"""
    aws_array_list_init_static(AWS_RESTRICT_)

### Prototype
```c
AWS_STATIC_IMPL void aws_array_list_init_static( struct aws_array_list *AWS_RESTRICT list, void *raw_array, size_t item_count, size_t item_size);
```
"""
function aws_array_list_init_static(AWS_RESTRICT_)
    @ccall libaws_c_common.aws_array_list_init_static(AWS_RESTRICT_::Ptr{aws_array_list})::Cint
end

"""
    aws_array_list_init_static_from_initialized(AWS_RESTRICT_)

### Prototype
```c
AWS_STATIC_IMPL void aws_array_list_init_static_from_initialized( struct aws_array_list *AWS_RESTRICT list, void *raw_array, size_t item_count, size_t item_size);
```
"""
function aws_array_list_init_static_from_initialized(AWS_RESTRICT_)
    @ccall libaws_c_common.aws_array_list_init_static_from_initialized(AWS_RESTRICT_::Ptr{aws_array_list})::Cint
end

"""
    aws_array_list_clean_up(AWS_RESTRICT_)

### Prototype
```c
AWS_STATIC_IMPL void aws_array_list_clean_up(struct aws_array_list *AWS_RESTRICT list);
```
"""
function aws_array_list_clean_up(AWS_RESTRICT_)
    @ccall libaws_c_common.aws_array_list_clean_up(AWS_RESTRICT_::Ptr{aws_array_list})::Cint
end

"""
    aws_array_list_clean_up_secure(AWS_RESTRICT_)

### Prototype
```c
AWS_STATIC_IMPL void aws_array_list_clean_up_secure(struct aws_array_list *AWS_RESTRICT list);
```
"""
function aws_array_list_clean_up_secure(AWS_RESTRICT_)
    @ccall libaws_c_common.aws_array_list_clean_up_secure(AWS_RESTRICT_::Ptr{aws_array_list})::Cint
end

"""
    aws_array_list_push_back(AWS_RESTRICT_)

### Prototype
```c
AWS_STATIC_IMPL int aws_array_list_push_back(struct aws_array_list *AWS_RESTRICT list, const void *val);
```
"""
function aws_array_list_push_back(AWS_RESTRICT_)
    @ccall libaws_c_common.aws_array_list_push_back(AWS_RESTRICT_::Ptr{aws_array_list})::Cint
end

"""
    aws_array_list_front(AWS_RESTRICT_)

### Prototype
```c
AWS_STATIC_IMPL int aws_array_list_front(const struct aws_array_list *AWS_RESTRICT list, void *val);
```
"""
function aws_array_list_front(AWS_RESTRICT_)
    @ccall libaws_c_common.aws_array_list_front(AWS_RESTRICT_::Ptr{aws_array_list})::Cint
end

"""
    aws_array_list_push_front(AWS_RESTRICT_)

### Prototype
```c
AWS_STATIC_IMPL int aws_array_list_push_front(struct aws_array_list *AWS_RESTRICT list, const void *val);
```
"""
function aws_array_list_push_front(AWS_RESTRICT_)
    @ccall libaws_c_common.aws_array_list_push_front(AWS_RESTRICT_::Ptr{aws_array_list})::Cint
end

"""
    aws_array_list_pop_front(AWS_RESTRICT_)

### Prototype
```c
AWS_STATIC_IMPL int aws_array_list_pop_front(struct aws_array_list *AWS_RESTRICT list);
```
"""
function aws_array_list_pop_front(AWS_RESTRICT_)
    @ccall libaws_c_common.aws_array_list_pop_front(AWS_RESTRICT_::Ptr{aws_array_list})::Cint
end

"""
    aws_array_list_pop_front_n(AWS_RESTRICT_)

### Prototype
```c
AWS_STATIC_IMPL void aws_array_list_pop_front_n(struct aws_array_list *AWS_RESTRICT list, size_t n);
```
"""
function aws_array_list_pop_front_n(AWS_RESTRICT_)
    @ccall libaws_c_common.aws_array_list_pop_front_n(AWS_RESTRICT_::Ptr{aws_array_list})::Cint
end

"""
    aws_array_list_erase(AWS_RESTRICT_)

### Prototype
```c
AWS_STATIC_IMPL int aws_array_list_erase(struct aws_array_list *AWS_RESTRICT list, size_t index);
```
"""
function aws_array_list_erase(AWS_RESTRICT_)
    @ccall libaws_c_common.aws_array_list_erase(AWS_RESTRICT_::Ptr{aws_array_list})::Cint
end

"""
    aws_array_list_back(AWS_RESTRICT_)

### Prototype
```c
AWS_STATIC_IMPL int aws_array_list_back(const struct aws_array_list *AWS_RESTRICT list, void *val);
```
"""
function aws_array_list_back(AWS_RESTRICT_)
    @ccall libaws_c_common.aws_array_list_back(AWS_RESTRICT_::Ptr{aws_array_list})::Cint
end

"""
    aws_array_list_pop_back(AWS_RESTRICT_)

### Prototype
```c
AWS_STATIC_IMPL int aws_array_list_pop_back(struct aws_array_list *AWS_RESTRICT list);
```
"""
function aws_array_list_pop_back(AWS_RESTRICT_)
    @ccall libaws_c_common.aws_array_list_pop_back(AWS_RESTRICT_::Ptr{aws_array_list})::Cint
end

"""
    aws_array_list_clear(AWS_RESTRICT_)

### Prototype
```c
AWS_STATIC_IMPL void aws_array_list_clear(struct aws_array_list *AWS_RESTRICT list);
```
"""
function aws_array_list_clear(AWS_RESTRICT_)
    @ccall libaws_c_common.aws_array_list_clear(AWS_RESTRICT_::Ptr{aws_array_list})::Cint
end

"""
    aws_array_list_shrink_to_fit(AWS_RESTRICT_)

### Prototype
```c
AWS_COMMON_API int aws_array_list_shrink_to_fit(struct aws_array_list *AWS_RESTRICT list);
```
"""
function aws_array_list_shrink_to_fit(AWS_RESTRICT_)
    @ccall libaws_c_common.aws_array_list_shrink_to_fit(AWS_RESTRICT_::Ptr{aws_array_list})::Cint
end

"""
    aws_array_list_copy(AWS_RESTRICT_)

### Prototype
```c
AWS_COMMON_API int aws_array_list_copy(const struct aws_array_list *AWS_RESTRICT from, struct aws_array_list *AWS_RESTRICT to);
```
"""
function aws_array_list_copy(AWS_RESTRICT_)
    @ccall libaws_c_common.aws_array_list_copy(AWS_RESTRICT_::Ptr{aws_array_list})::Cint
end

"""
    aws_array_list_swap_contents(AWS_RESTRICT_)

### Prototype
```c
AWS_STATIC_IMPL void aws_array_list_swap_contents( struct aws_array_list *AWS_RESTRICT list_a, struct aws_array_list *AWS_RESTRICT list_b);
```
"""
function aws_array_list_swap_contents(AWS_RESTRICT_)
    @ccall libaws_c_common.aws_array_list_swap_contents(AWS_RESTRICT_::Ptr{aws_array_list})::Cint
end

"""
    aws_array_list_get_at(AWS_RESTRICT_)

### Prototype
```c
AWS_STATIC_IMPL int aws_array_list_get_at(const struct aws_array_list *AWS_RESTRICT list, void *val, size_t index);
```
"""
function aws_array_list_get_at(AWS_RESTRICT_)
    @ccall libaws_c_common.aws_array_list_get_at(AWS_RESTRICT_::Ptr{aws_array_list})::Cint
end

"""
    aws_array_list_get_at_ptr(AWS_RESTRICT_)

### Prototype
```c
AWS_STATIC_IMPL int aws_array_list_get_at_ptr(const struct aws_array_list *AWS_RESTRICT list, void **val, size_t index);
```
"""
function aws_array_list_get_at_ptr(AWS_RESTRICT_)
    @ccall libaws_c_common.aws_array_list_get_at_ptr(AWS_RESTRICT_::Ptr{aws_array_list})::Cint
end

"""
    aws_array_list_ensure_capacity(AWS_RESTRICT_)

### Prototype
```c
AWS_COMMON_API int aws_array_list_ensure_capacity(struct aws_array_list *AWS_RESTRICT list, size_t index);
```
"""
function aws_array_list_ensure_capacity(AWS_RESTRICT_)
    @ccall libaws_c_common.aws_array_list_ensure_capacity(AWS_RESTRICT_::Ptr{aws_array_list})::Cint
end

"""
    aws_array_list_set_at(AWS_RESTRICT_)

### Prototype
```c
AWS_STATIC_IMPL int aws_array_list_set_at(struct aws_array_list *AWS_RESTRICT list, const void *val, size_t index);
```
"""
function aws_array_list_set_at(AWS_RESTRICT_)
    @ccall libaws_c_common.aws_array_list_set_at(AWS_RESTRICT_::Ptr{aws_array_list})::Cint
end

"""
    aws_array_list_swap(AWS_RESTRICT_)

### Prototype
```c
AWS_COMMON_API void aws_array_list_swap(struct aws_array_list *AWS_RESTRICT list, size_t a, size_t b);
```
"""
function aws_array_list_swap(AWS_RESTRICT_)
    @ccall libaws_c_common.aws_array_list_swap(AWS_RESTRICT_::Ptr{aws_array_list})::Cint
end

"""
    aws_array_list_sort(AWS_RESTRICT_)

### Prototype
```c
AWS_COMMON_API void aws_array_list_sort(struct aws_array_list *AWS_RESTRICT list, aws_array_list_comparator_fn *compare_fn);
```
"""
function aws_array_list_sort(AWS_RESTRICT_)
    @ccall libaws_c_common.aws_array_list_sort(AWS_RESTRICT_::Ptr{aws_array_list})::Cint
end

