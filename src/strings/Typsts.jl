
module Typsts

import Base: ==
import ..Strings: show_typst

using ..Strings: AbstractTypst
using Typstry: TypstContext

export Typst

"""
    Typst{T}(::T) <: AbstractTypst
    Typst(::T)

A wrapper used to pass values to `show`,
whose [`show_typst`](@ref) method formats the wrapped value.

Subtype of [`AbstractTypst`](@ref).

# Interface

- `==(::Typst{T},\u00A0::Typst{T})\u00A0where\u00A0T`
- `show_typst(::IO,\u00A0::TypstContext,\u00A0::Typst)`

# Examples

```jldoctest
julia> show_typst(Typst(1))
\$1\$
```
"""
struct Typst{T} <: AbstractTypst
    value::T
end

==(typst_1::Typst{T}, typst_2::Typst{T}) where T = typst_1.value == typst_2.value

show_typst(io::IO, ::TypstContext, typst::Typst) = show_typst(io, typst.value)

end # Typsts
