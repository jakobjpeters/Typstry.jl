
module Typsts

import Base: ==, repr, show
import Typstry: show_typst

using Typstry: TypstContext, TypstString, TypstText, show_render

export Typst

"""
    Typst{T}(::T)
    Typst(::T)

A wrapper used to pass values to `show`,
whose [`show_typst`](@ref) method formats the wrapped value.

# Interface

- `==(::Typst{T},\u00A0::Typst{T})\u00A0where\u00A0T`
- `repr(::MIME"text/typst\u00A0::Typst; context = nothing)`
- `show_typst(::IO,\u00A0::TypstContext,\u00A0::Typst)`
- `show(::IO,\u00A0::MIME"text/typst",\u00A0::Typst)`
    - Accepts `IOContext(::IO,\u00A0::TypstContext)`
- `show(::IO,\u00A0::Union{MIME"application/pdf",\u00A0MIME"image/png",\u00A0MIME"image/svg+xml"},\u00A0::Typst)`
    - Accepts `IOContext(::IO,\u00A0::TypstContext)`
    - Uses the `preamble` in [`context`](@ref Typstry.Contexts.TypstContexts.context)
    - Supports the [`julia_mono`](@ref Typstry.Commands.JuliaMono.julia_mono) typeface

# Examples

```jldoctest
julia> show_typst(Typst(1))
\$1\$
```
"""
struct Typst{T}
    value::T
end

==(typst_1::Typst{T}, typst_2::Typst{T}) where T = typst_1.value == typst_2.value

repr(mime::MIME"text/typst", typst::Typst; context = nothing) = TypstString(
    TypstText(sprint(show, mime, typst; context))
)

show_typst(io::IO, ::TypstContext, t::Typst) = show_typst(io, t.value)

show(io::IO, ::MIME"text/typst", t::Typst) = show_typst(io, t)
show(io::IO, m::Union{
    MIME"application/pdf", MIME"image/png", MIME"image/svg+xml"
}, t::Typst) = show_render(io, m, t)

end # Typsts
