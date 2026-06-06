
module AbstractTypsts

import Base: ==, show

using Base: Pairs
using .Docs: Text
using ..Strings: Mode, code
using Typstry: Typstry, Utilities, TypstContext, Contexts.ContextErrors.unwrap, context
using .Utilities: enclose, join_with

export
    AbstractTypst, TypstFunction, TypstImage, TypstMode, TypstRaw, TypstText, Typst,
    lower, show_typst

const typst, gif, svg, png, jpg, webp = Iterators.map(MIME, ["text/typst", ("image/" .* (
    "gif", "svg+xml", "png", "jpg", "webp"
))...])

"""
    AbstractTypst

Supertype of [`TypstFunction`](@ref), [`TypstText`](@ref), and [`Typst`](@ref).

# Interface

- `repr(::MIME"text/typst",\u00A0::AbstractTypst)`
- `show(::IO,\u00A0::Union{MIME"application/pdf",\u00A0MIME"image/png",\u00A0MIME"image/svg+xml"},\u00A0::AbstractTypst)`
    - Accepts `IOContext(::IO,\u00A0::TypstContext)`
    - Uses the `preamble` in [`context`](@ref Typstry.Contexts.TypstContexts.context)
    - Supports the [`julia_mono`](@ref Typstry.Commands.JuliaMono.julia_mono) typeface
- `show(::IO,\u00A0::MIME"text/typst",\u00A0::AbstractTypst)`
    - Accepts `IOContext(::IO,\u00A0::TypstContext)`
"""
abstract type AbstractTypst end

"""
    TypstFunction{P <: Tuple}(
        callable::Symbol,
        parameters::P...;
        keyword_parameters...
    ) <: AbstractTypst

A wrapper representing a Typst function.

This uses the `depth::Int`, `mode::Mode`, and `tab_size::Int` keys from the [`TypstContext`](@ref).

Subtype of [`AbstractTypst`](@ref).

See also [`Mode`](@ref).

# Interface

- `==(::TypstFunction,\u00A0::TypstFunction)`
- `show_typst(::IO,\u00A0::TypstContext,\u00A0::TypstFunction)`
- `show(::IO,\u00A0::TypstFunction)`

# Examples

```jldoctest
julia> show_typst(TypstFunction(context, typst"arguments", 1, 2; a = 3, b = 4))
#arguments(
  1,
  2,
  a: 3,
  b: 4
)
```
"""
struct TypstFunction{P <: Tuple} <: AbstractTypst
    callable::Symbol
    parameters::P
    keyword_parameters::Pairs

    TypstFunction(callable::Symbol, parameters...; keyword_parameters...) = new{typeof(parameters)}(
        callable,
        parameters,
        keyword_parameters
    )
end

"""
    TypstImage{M <: MIME, T} <: AbstractTypst
    TypstImage(::M, ::T)
"""
struct TypstImage{M <: MIME, T} <: AbstractTypst
    value::T

    TypstImage(mime::MIME, value) = new{typeof(mime), typeof(value)}(value)
end

"""
    TypstMode{T} <: AbstractTypst
    TypstMode(::Mode, ::T)
"""
struct TypstMode{T} <: AbstractTypst
    mode::Mode
    value::T
end

"""
    TypstRaw{M <: MIME, T} <: AbstractTypst
    TypstRaw(::M, language::Symbol, value::T)

!!! tip
    Use these:

    - `TypstRaw(MIME"text/plain"(), :julia, ::Any)`
    - `TypstRaw(MIME"text/typst"(), :typst, ::Union{AbstractTypst, TypstString})`

See also [`AbstractTypst`](@ref) and [`TypstString`](@ref).
"""
struct TypstRaw{M <: MIME, T} <: AbstractTypst
    language::Symbol
    value::T

    TypstRaw(mime::MIME, language::Symbol, value) = new{typeof(mime), typeof(value)}(
        language, value
    )
end

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

"""
    Typst{T}(::T) <: AbstractTypst
    Typst(::T)

A wrapper used to pass values to `show`,
whose [`show_typst`](@ref) method formats the wrapped value.

Subtype of [`AbstractTypst`](@ref).

# Interface

- `==(::Typst{T},\u00A0::Typst{T})\u00A0where\u00A0T`
- `(Typst(::T) where T <: Typst)::T`
    - This wrapper cannot be nested.
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

Typst(typst::Typst) = typst

==(typst_function_1::TypstFunction, typst_function_2::TypstFunction) = (
    typst_function_1.depth == typst_function_2.depth &&
    typst_function_1.mode == typst_function_2.mode &&
    typst_function_1.tab_size == typst_function_2.tab_size &&
    typst_function_1.callable == typst_function_2.callable &&
    typst_function_1.parameters == typst_function_2.parameters &&
    typst_function_1.keyword_parameters == typst_function_2.keyword_parameters
)
==(typst_1::T, typst_2::T) where T <: Union{
    TypstImage, TypstMode, TypstText, Typst
} = typst_1.value == typst_2.value

"""
    lower(value)

Lowering should be type-stable.
The need for unstable code typically indicates that the interface should be implemented using [`show_typst`](@ref) intead.

# Interface

- `lower(::AbstractChar)::String`
- `lower(::AbstractFloat)::TypstMode{TypstText{String}}`
- `lower(::Bool)::TypstMode{TypstText{Bool}}`
- `lower(::Complex{<:Union{Bool,\u00A0Unsigned}})::Complex{<:Signed}`
- `lower(::Complex{<:Rational{<:Union{Bool,\u00A0Unsigned}}})::Complex{<:Rational{<:Signed}}`
- `lower(::Docs.HTML)::TypstRaw{MIME"text/html"}`
- `lower(::Nothing)::TypstMode{TypstString}`
- `lower(::Rational{<:Union{Bool,\u00A0Unsigned}})::Rational{<:Signed}`
- `lower(::Regex)::TypstFunction{Tuple{SubString{String}}}`
- `(lower(::S\u00A0where\u00A0<\u00A0Signed)::TypstMode{TypstText{S}}`
- `lower(::Symbol)::TypstMode{String}`
- `lower(::Text)::TypstMode{String}`
- `lower(::TypstString)::TypstText{TypstString}`
- `(lower(::T)\u00A0where\u00A0T\u00A0<:\u00A0Typst)::T`
- `lower(::Unsigned)::TypstMode{String}`
- `lower(::VersionNumber)::TypstFunction{<:NTuple{<:Any,\u00A0String}}`
    - May error for version numbers with non-empty `prerelease` or `build` fields
- `lower(range::Union{
      OrdinalRange{<:Integer, <:Integer},
      StepRangeLen{<:Integer, <:Integer, <:Integer, <:Integer}
   })::StepRange{<:Signed, <:Signed}`
- `(lower(::T)\u00A0where\u00A0T)::Typst{T}`
    - Used by [`show_typst`](@ref) as a fallback for recursive lowering

See also [`TypstString`](@ref) and [`Typst`](@ref).
"""
lower(value) = Typst(value)

show_typst_fallback(io::IO, typst::AbstractTypst) = show_typst(io, typst)
function show_typst_fallback(io::IO, typst::Typst)
    value = typst.value

    if showable(AbstractTypsts.typst, value) show(io, typst, value)
    elseif showable(gif, value) show_typst(io, TypstImage(gif, value))
    elseif showable(svg, value) show_typst(io, TypstImage(svg, value))
    elseif showable(png, value) show_typst(io, TypstImage(png, value))
    elseif showable(jpg, value) show_typst(io, TypstImage(jpg, value))
    elseif showable(webp, value) show_typst(io, TypstImage(webp, value))
    else show_typst(io, Text(value))
    end
end
show_typst_fallback(io::IO, value) = show_typst_fallback(io, lower(value))

function show_typst(io::IO, typst_image::TypstImage{M}) where M
    path = tempname() * '.' * format(M)
    typst_context = TypstContext(io, typst_image)

    open(path; write = true) do file
        show(IOContext(file, typst_context), mime, value)
    end

    # show_parameters(io, typst_context, TypstString(TypstText(:image)), (path,), [
    #     :alt, :fit, :format, :height, :icc, :page, :scaling, :width
    # ])
end
function show_typst(io::IO, (; mode, value)::TypstMode)
    typst_context = TypstContext(io, value)
    delimiters = begin
        if unwrap(typst_context, Mode, :mode) == mode "" => ""
        elseif mode == code "#" => ""
        elseif mode == markup "[" => "]"
        elseif mode == math
            unwrap(typst_context, Bool, :block) ? "\$ " => " \$" : "\$" => "\$"
        else error("unknown mode `$mode`")
        end
    end

    enclose((io, value) -> show_typst(value; io, mode), io, value, delimiters...)
end
show_typst(io::IO, typst_text::TypstText) = print(io, typst_text.value)
show_typst(io::IO, typst::Typst) = show_typst(io, typst.value)

"""
    show_typst(::IO, ::Any)::Nothing

# Interface

- `show_typst(::IO, ::AbstractIrrational)`
- `show_typst(::IO, ::TypstImage)`
- `show_typst(::IO, ::TypstText)`
- `show_typst(::IO, Typst)`
"""
show_typst(io::IO, value) = show_typst_fallback(io, value)

# TODO: combine implementation with `TypstContext(::IO, ::Any)`
"""
    show_typst(::TypstContext, ::Any)::Nothing
"""
show_typst(typst_context::TypstContext, value) = show_typst(unwrap(merge!(mergewith!(
    (left, right) -> left, TypstContext(value), context
), typst_context), IO, :io), value)

"""
    show_typst(::Any; typst_context...)::Nothing
"""
show_typst(value; typst_context...) = show_typst(TypstContext(; typst_context...), value)

show(io::IO, ::MIME"text/plain", typst::AbstractTypst) = show_typst(io, typst)
function show(io::IO, typst_function::TypstFunction)
    print(io, TypstFunction, '(')
    show(io, typst_function.callable)
    print(io, ", ")

    if !isempty(parameters)
        print(io, ", ")
        join_with(io, parameters, ", ") do io, parameter
            show(io, parameter)
        end
    end

    if !isempty(keyword_parameters)
        print(io, "; ")
        join_with(io, typst_function.keyword_parameters, ", ") do io, (key, value)
            print(io, key, " = ")
            show(io, value)
        end
    end
end

end # AbstractTypsts
