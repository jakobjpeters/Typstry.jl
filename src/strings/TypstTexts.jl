
module TypstTexts

import Base: ==, repr, show
import Typstry: show_typst

using Typstry: Typstry, TypstContext, show_render

export TypstText

"""
    TypstText{T}
    TypstText(::Any)

A wrapper whose [`show_typst`](@ref) method uses `print` on the wrapped value.

# Interface

- `==(::TypstText{T},\u00A0::TypstText{T})\u00A0where\u00A0T`
- `repr(::MIME"text/typst\u00A0::TypstText; context = nothing)`
- `show_typst(::IO,\u00A0::TypstContext,\u00A0::TypstText)`
- `show(::IO,\u00A0::MIME"text/typst",\u00A0::TypstText)`
    - Accepts `IOContext(::IO,\u00A0::TypstContext)`
- `show(::IO,\u00A0::Union{MIME"application/pdf",\u00A0MIME"image/png",\u00A0MIME"image/svg+xml"},\u00A0::TypstText)`
    - Accepts `IOContext(::IO,\u00A0::TypstContext)`
    - Uses the `preamble` in [`context`](@ref Typstry.context)
    - Supports the [`julia_mono`](@ref Typstry.Commands.julia_mono) typeface

# Examples

```jldoctest
julia> show_typst(TypstText('a'))
a
```
"""
struct TypstText{T}
    value::T
end

function ==(typst_text_1::TypstText{T}, typst_text_2::TypstText{T}) where T
    typst_text_1.value == typst_text_2.value
end

repr(mime::MIME"text/typst", typst_text::TypstText; context = nothing) = Typstry.TypstString(
    TypstText(sprint(show, mime, typst_text; context))
)

show_typst(io::IO, ::TypstContext, typst_text::TypstText) = print(io, typst_text.value)

show(io::IO, ::MIME"text/typst", typst_text::TypstText) = show_typst(io, typst_text)
show(io::IO, mime::Union{
    MIME"application/pdf", MIME"image/png", MIME"image/svg+xml"
}, typst_text::TypstText) = show_render(io, mime, typst_text)

end # TypstTexts
