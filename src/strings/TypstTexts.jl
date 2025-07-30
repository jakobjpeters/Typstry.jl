
module TypstTexts

import Base: repr, show
import ..Typstry: show_typst

using ..Typstry: TypstContext

"""
    TypstText{T}
    TypstText(::Any)

A wrapper whose [`show_typst`](@ref) method uses `print` on the wrapped value.

# Interface

- `repr(::MIME"text/typst\u00A0::TypstText; context = nothing)`
- `show_typst(::IO,\u00A0::TypstContext,\u00A0::TypstText)`
- `show(::IO,\u00A0::MIME"text/typst",\u00A0::TypstText)`
    - Accepts `IOContext(::IO,\u00A0:typst_context\u00A0=>\u00A0::TypstContext)`
- `show(::IO,\u00A0::Union{MIME"application/pdf",\u00A0MIME"image/png",\u00A0MIME"image/svg+xml"},\u00A0::TypstText)`
    - Accepts `IOContext(::IO,\u00A0::TypstContext)`
    - Uses the `preamble` in [`context`](@ref Typstry.context)
    - Supports the [`julia_mono`](@ref Typstry.Commands.julia_mono) typeface

# Examples

```jldoctest
julia> tt = TypstText('a')
TypstText{Char}('a')

julia> show_typst(tt)
a
```
"""
struct TypstText{T}
    value::T
end

repr(::MIME"text/typst", tt::TypstText; context = nothing) = TypstString(tt)

show_typst(io::IO, ::TypstContext, tt::TypstText) = print(io, tt.value)

show(io::IO, ::MIME"text/typst", tt::TypstText) = show_typst(io, tt)
show(io::IO, m::Union{
    MIME"application/pdf", MIME"image/png", MIME"image/svg+xml"
}, tt::TypstText) = show_render(io, m, tt)

end # TypstTexts
