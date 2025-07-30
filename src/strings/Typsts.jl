
module Typsts

import Base: repr, show
import ..Typstry: show_typst

using ..Typstry: TypstContext

export Typst

"""
    Typst{T}
    Typst(::T)

A wrapper used to pass values to `show`,
whose [`show_typst`](@ref) method formats the wrapped value.

# Interface

- `repr(::MIME"text/typst\u00A0::Typst; context = nothing)`
- `show_typst(::IO,\u00A0::TypstContext,\u00A0::Typst)`
- `show(::IO,\u00A0::MIME"text/typst",\u00A0::Typst)`
    - Accepts `IOContext(::IO,\u00A0:typst_context\u00A0=>\u00A0::TypstContext)`
- `show(::IO,\u00A0::Union{MIME"application/pdf",\u00A0MIME"image/png",\u00A0MIME"image/svg+xml"},\u00A0::Typst)`
    - Accepts `IOContext(::IO,\u00A0::TypstContext)`
    - Uses the `preamble` in [`context`](@ref Typstry.context)
    - Supports the [`julia_mono`](@ref Typstry.Commands.julia_mono) typeface

# Examples

```jldoctest
julia> t = Typst(1)
Typst{Int64}(1)

julia> show(stdout, "text/typst", t)
\$1\$
```
"""
struct Typst{T}
    value::T
end

repr(::MIME"text/typst", t::Typst; context = nothing) = TypstString(t)

show_typst(io::IO, ::TypstContext, t::Typst) = show_typst(io, t.value)

show(io::IO, ::MIME"text/typst", t::Typst) = show_typst(io, t)
show(io::IO, m::Union{
    MIME"application/pdf", MIME"image/png", MIME"image/svg+xml"
}, t::Typst) = show_render(io, m, t)

end # Typsts
