
"""
    ContextError <: Exception
    ContextError(::Type, ::Type, ::Symbol)

An `Exception` indicating that a [`context`](@ref) key returned a value of an incorrect type.

# Interface

Implements the `Exception` interface.

- `showerror(::IO, ::ContextError)`
- `show(::IO, ::MIME"text/plain", ::ContextError)`

# Examples

```jldoctest
julia> ContextError(Mode, String, :mode)
ContextError(Mode, String, :mode)
```
"""
struct ContextError <: Exception
    expected::Type
    received::Type
    key::Symbol
end

showerror(io::IO, ce::ContextError) = print(io, "ContextError: the context key `:", ce.key,
    "` expected a value of type `", ce.expected, "` but received `", ce.received, "`")

show(io::IO, ::MIME"text/plain", ce::ContextError) =
    print(io, ContextError, "(", ce.expected, ", ", ce.received, ", :", ce.key, ")")

_unwrap(type, key, value) = value isa type ? value : throw(ContextError(type, typeof(value), key))

"""
    unwrap(io, key::Symbol, default)
    unwrap(io, type::Type, key)
"""
unwrap(io, key::Symbol, default) = _unwrap(typeof(default), key, get(io, key, default))
function unwrap(io, type::Type, key)
    value = io[key]
    _unwrap(type, key, value)
end
