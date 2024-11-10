
"""
    TypstText{T}
    TypstText(::Any)

A wrapper whose [`show_typst`](@ref) method uses `print` on the wrapped value.

# Interface

- `show_typst(::IO,\u00A0::TypstContext,\u00A0::TypstText)`
- `show(::IO,\u00A0::MIME"text/typst",\u00A0::TypstText)`
    - Accepts `IOContext(::IO,\u00A0:typst_context\u00A0=>\u00A0::TypstContext)`
- `show(::IO,\u00A0::Union{MIME"application/pdf",\u00A0MIME"image/png",\u00A0MIME"image/svg+xml"},\u00A0::TypstText)`
    - Accepts `IOContext(::IO,\u00A0:typst_context\u00A0=>\u00A0::TypstContext)`
    - Supports the [`julia_mono`](@ref) typeface
    - The generated Typst source text contains the context's `preamble` and the formatted value
- `show(::IO,\u00A0::TypstText)`

# Examples

```jldoctest
julia> TypstText(1)
TypstText(1)

julia> TypstText("a")
TypstText("a")
```
"""
struct TypstText{T}
    value::T
end

"""
    show_typst(::IO, ::TypstContext, ::TypstText)

Call `print` the value wrapped in [`TypstText`](@ref).

See also [`TypstContext`](@ref).
"""
function show_typst(io::IO, tc::TypstContext, tt::TypstText)
    context = IOContext(io)

    for pair in unwrap(tc, :typst_context, default_io_context)
        context = IOContext(context, pair)
    end

    print(context, tt.value)
end
