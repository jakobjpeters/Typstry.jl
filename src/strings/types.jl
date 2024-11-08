
"""
    TypstText{T}
    TypstText(::Any)

A wrapper whose [`show_typst`](@ref) method uses `print` on the wrapped value.

# Interface

- `show_typst(::IO,\u00A0::TypstContext,\u00A0::TypstText)`
- `show(::IO,\u00A0::Union{MIME"application/pdf",\u00A0MIME"image/png",\u00A0MIME"image/svg+xml"},\u00A0::TypstText)`
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
    Typst{T}
    Typst(::T)

A wrapper used to pass values to [`show_typst`](@ref).

# Interface

- `show_typst(::IO,\u00A0::TypstContext,\u00A0::Typst)`
- `show(::IO,\u00A0::Union{MIME"application/pdf",\u00A0MIME"image/png",\u00A0MIME"image/svg+xml"},\u00A0::Typst)`
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
    Mode

An `Enum`erated type used to specify that the current Typst syntactical
context is [`code`](@ref), [`markup`](@ref), or [`math`](@ref).

# Examples

```jldoctest
julia> Mode
Enum Mode:
code = 0
markup = 1
math = 2
```
"""
@enum Mode code markup math

@doc """
    code

A Typst syntactical [`Mode`](@ref) prefixed by the number sign.

# Examples

```jldoctest
julia> code
code::Mode = 0
```
""" code

@doc """
    markup

A Typst syntactical [`Mode`](@ref) at the top-level of source text and enclosed within square brackets.

```jldoctest
julia> markup
markup::Mode = 1
```
""" markup

@doc """
    math

A Typst syntactical [`Mode`](@ref) enclosed within dollar signs.

```jldoctest
julia> math
math::Mode = 2
```
""" math

"""
    show_typst(::IO, ::TypstContext, ::TypstText)

Call `print` the value wrapped in [`TypstText`](@ref).

See also [`TypstContext`](@ref).
"""
show_typst(io, _, tt::TypstText) = print(io, tt.value)

"""
    show_typst(::IO, ::TypstContext, ::Typst)

Call [`show_typst`](@ref) on the value wrapped in [`Typst`](@ref).

See also [`TypstContext`](@ref).
"""
show_typst(io, tc, x::Typst) = _show_typst(io, tc, x.value)
