
module TypstStrings

import Base:
    *, IOBuffer, codeunit, codeunit, isvalid, iterate, iterate,
    ncodeunits, pointer, repr, show
import ..Strings: show_typst

using .Meta: isexpr
using ..Strings: TypstText
using Typstry: TypstContext
using ..Strings: escape

export TypstString, @typst_str

"""
    TypstString <: AbstractString
    TypstString(::TypstContext, ::Any)
    TypstString(::Any; context...)

A Typst formatted string.

The [`TypstContext`](@ref) is combined with additional context and passed to [`show_typst`](@ref).

# Interface

This type implements the `String` interface.
However, the interface is undocumented, which may result in unexpected behavior.

- `*(::TypstString,\u00A0::TypstString)`
- `IOBuffer(::TypstString)`
- `codeunit(::TypstString,\u00A0::Integer)`
- `codeunit(::TypstString)`
- `isvalid(::TypstString,\u00A0::Integer)`
- `iterate(::TypstString,\u00A0::Integer)`
- `iterate(::TypstString)`
- `ncodeunits(::TypstString)`
- `pointer(::TypstString)`
- `repr(::MIME"text/typst\u00A0::TypstString; context = nothing)`
- `repr(::MIME,\u00A0::TypstString; context = nothing)`
    - This method patches incorrect output from the assumption in `repr` that
        the parameter is already in the requested `MIME` type when the `MIME`
        type satisfies `istextmime` and the parameter is an `AbstractString`.
- `show_typst(::IO,\u00A0::TypstContext,\u00A0::TypstString)`
- `show(::IO,\u00A0::MIME"text/plain",\u00A0::TypstString)`
    - Print in `typst""` format if each character satisfies `isprint`.
        Otherwise, print with `show(::IO,\u00A0::TypstString)`.
- `show(::IO,\u00A0::MIME"text/typst",\u00A0::TypstString)`
    - Accepts a `IOContext(::IO,\u00A0::TypstContext)`.
- `show(::IO,\u00A0::Union{MIME"application/pdf",\u00A0MIME"image/png",\u00A0MIME"image/svg+xml"},\u00A0::TypstString)`
    - Accepts a `IOContext(::IO,\u00A0::TypstContext)`.
    - Supports the [`julia_mono`](@ref Typstry.Commands.JuliaMono.julia_mono) typeface.
    - The generated Typst source text contains the context's `preamble` and the formatted value.
- `show(::IO,\u00A0::TypstString)`
    - Print in `TypstString(TypstText(::String))` format.

# Examples

```jldoctest
julia> TypstString(1)
typst"\$1\$"

julia> TypstString(TypstContext(; mode = math), π)
typst"π"

julia> TypstString(1 + 2im; mode = math)
typst"(1 + 2i)"
```
"""
struct TypstString <: AbstractString
    text::String

    TypstString(typst_context::TypstContext, value) = new(sprint(
        show_typst, value; context = :typst_context => typst_context
    ))
end

TypstString(value; typst_context...) = TypstString(TypstContext(; typst_context...), value)

"""
    typst""
    @typst_str(::String)

Construct a [`TypstString`](@ref).

Control characters are escaped,
except double quotation marks and backslashes in the same manner as `@raw_str`.
Values may be interpolated by calling the `TypstString` constructor,
except using a backslash instead of the type name.
Interpolation syntax may be escaped in the same manner as quotation marks.

!!! tip
    Print directly to an `IO` using [`show_typst`](@ref).

    See also the performance tip to [Avoid string interpolation for I/O](https://docs.julialang.org/en/v1/manual/performance-tips/#Avoid-string-interpolation-for-I/O).

# Examples

```jldoctest
julia> x = 1;

julia> typst"\$ \\(x; mode = math) / \\(x + 1; mode = math) \$"
typst"\$ 1 / 2 \$"

julia> typst"\\(x//2)"
typst"\$1 / 2\$"

julia> typst"\\(x // 2; mode = math)"
typst"(1 / 2)"

julia> typst"\\\\(x)"
typst"\\\\(x)"
```
"""
macro typst_str(input::String)
    filename = __source__.file
    current, final = firstindex(input), lastindex(input)
    output = Expr(:string)
    args = output.args

    while (regex_match = match(r"(\\+)(\()", input, current)) ≢ nothing
        backslashes = length(first(regex_match.captures)::SubString{String})
        start = last(regex_match.offsets)
        interpolate, previous = isodd(backslashes), prevind(input, start)

        if current < previous
            push!(args, @view input[current:prevind(
                input, previous, interpolate + backslashes ÷ 2
            )])
        end

        if interpolate
            parameters, current = Meta.parse(input, start; filename, greedy = false)
            isexpr(parameters, :incomplete) && throw(only(parameters.args))
            interpolation = :($TypstString())

            @views append!(interpolation.args, Meta.parse(input[
                previous:prevind(input, current)
            ]; filename).args[2:end])
            push!(args, esc(interpolation))
        else current = start
        end
    end

    current > final || push!(args, @view input[current:final])
    :(TypstString(TypstText($output)))
end

*(typst_string::TypstString, _typst_string::TypstString) = TypstString(
    TypstText(typst_string.text * _typst_string.text)
)

IOBuffer(ts::TypstString) = IOBuffer(ts.text)

codeunit(ts::TypstString, i::Integer) = codeunit(ts.text, i)
codeunit(ts::TypstString) = codeunit(ts.text)

isvalid(ts::TypstString, i::Integer) = isvalid(ts.text, i::Integer)

iterate(ts::TypstString, i::Integer) = iterate(ts.text, i)
iterate(ts::TypstString) = iterate(ts.text)

ncodeunits(ts::TypstString) = ncodeunits(ts.text)

pointer(ts::TypstString) = pointer(ts.text)

repr(::MIME"text/typst", ts::TypstString; context = nothing) = ts
repr(m::MIME, ts::TypstString; context = nothing) = sprint(show, m, ts; context)

show_typst(io::IO, ::TypstContext, x::TypstString) = print(io, x)

show(io::IO, ::MIME"text/typst", x::TypstString) = show_typst(io, x)
function show(io::IO, ::MIME"text/plain", typst_string::TypstString)
    if all(isprint, typst_string)
        escapes = 0

        print(io, "typst\"")

        for character in typst_string
            if character == '\\' escapes += 1
            else
                if character == '"' escape(io, escapes + 1)
                elseif character == '(' escape(io, escapes)
                end

                escapes = 0
            end

            print(io, character)
        end

        escape(io, escapes)
        print(io, '"')
    else show(io, typst_string)
    end
end
function show(io::IO, typst_string::TypstString)
    print(io, TypstString, '(', TypstText, '(')
    show(io, typst_string.text)
    print(io, "))")
end

end # TypstStrings
