
"""
    ContextError <: Exception
    ContextError(::Type, ::Type, ::Symbol)

An `Exception` indicating that a context key returned a value of an incorrect type.

# Interface

Implements the `Exception` interface.

- `showerror(::IO,\u00A0::ContextError)`
- `show(::IO,\u00A0::MIME"text/plain",\u00A0::ContextError)`

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
