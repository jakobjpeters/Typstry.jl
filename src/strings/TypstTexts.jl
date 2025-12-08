
module TypstTexts

import Base: ==
import ..Strings: show_typst

using ..Strings: AbstractTypst
using Typstry: Typstry, TypstContext

export TypstText

"""
    TypstText{T}(::T) <: AbstractTypst
    TypstText(::T)

A wrapper whose [`show_typst`](@ref) method uses `print` on the wrapped value.

Subtype of [`AbstractTypst`](@ref).

# Interface

- `==(::TypstText{T},\u00A0::TypstText{T})\u00A0where\u00A0T`
- `show_typst(::IO,\u00A0::TypstContext,\u00A0::TypstText)`

# Examples

```jldoctest
julia> show_typst(TypstText('a'))
a
```
"""
struct TypstText{T} <: AbstractTypst
    value::T
end

function ==(typst_text_1::TypstText{T}, typst_text_2::TypstText{T}) where T
    typst_text_1.value == typst_text_2.value
end

show_typst(io::IO, ::TypstContext, typst_text::TypstText) = print(io, typst_text.value)

end # TypstTexts
