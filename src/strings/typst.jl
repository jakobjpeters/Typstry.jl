
"""
    Typst{T}
    Typst(::T)

A wrapper used to pass values to [`show_typst`](@ref).

# Interface

- `show_typst(::IO,\u00A0::TypstContext,\u00A0::Typst)`
- `show(::IO,\u00A0::Union{MIME"application/pdf",\u00A0MIME"image/png",\u00A0MIME"image/svg+xml",\u00A0MIME"text/typst"},\u00A0::Typst)`
    - Accepts a `IOContext(::IO,\u00A0:typst_context\u00A0=>\u00A0::TypstContext)`
    - Supports the [`julia_mono`](@ref) typeface
    - The generated Typst source text contains the context's `preamble` and the formatted value
- `show(::IO,\u00A0::Typst)`

# Examples

```jldoctest
julia> Typst(1)
Typst(1)

julia> Typst("a")
Typst("a")
```
"""
struct Typst{T}
    value::T
end

"""
    show_typst(::IO, ::TypstContext, ::Typst)

Call [`show_typst`](@ref) on the value wrapped in [`Typst`](@ref).

See also [`TypstContext`](@ref).
"""
show_typst(io::IO, tc::TypstContext, x::Typst) = _show_typst(io, tc, x.value)
