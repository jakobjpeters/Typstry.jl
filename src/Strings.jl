
"""
    Strings

The Julia to Typst interface,
a custom string corresponding to Typst source text,
and its implementation of the `String` interface.

# Examples

```jldoctest
julia> Typstry.Strings
Typstry.Strings
```
"""
module Strings

import Base: IOBuffer, ==, codeunit, eltype, get, isvalid, iterate, length, ncodeunits, pointer, repr, show
using ..Typstry: enclose, join_with, set_preference, unwrap
using .Docs: HTML, Text
using .Meta: isexpr, parse
using Dates:
    Date, DateTime, Day, Hour, Minute, Period, Second, Time, Week,
    day, hour, minute, month, second, year
using Preferences: @load_preference

# `Typstry`

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

"""
    Typst{T}
    Typst(::T)

A wrapper used to pass values to
[`show(::IO,\u00A0::MIME"text/typst",\u00A0::Typst)`](@ref).

# Examples

```jldoctest
julia> Typst(1)
Typst{Int64}(1)

julia> Typst("a")
Typst{String}("a")
```
"""
struct Typst{T}
    value::T
end

"""
    TypstText{T}
    TypstText(::Any)

A wrapper whose [`show_typst`](@ref) method uses `print`.

# Examples

```jldoctest
julia> TypstText(1)
TypstText{Int64}(1)

julia> TypstText("a")
TypstText{String}("a")
```
"""
struct TypstText{T}
    value::T
end

"""
    @typst_str("s")
    typst"s"

Construct a [`TypstString`](@ref).

Control characters are escaped,
except double quotation marks and backslashes in the same manner as `@raw_str`.
Values may be interpolated by calling the `TypstString` constructor,
except using a backslash instead of the type name.
Interpolation syntax may be escaped in the same manner as quotation marks.

!!! tip
    Print directly to an `IO` using
    [`show(::IO,\u00A0::MIME"text/typst",\u00A0::Typst)`](@ref).

    See also the performance tip to [Avoid string interpolation for I/O]
    (https://docs.julialang.org/en/v1/manual/performance-tips/#Avoid-string-interpolation-for-I/O).

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
macro typst_str(s::String)
    filename = __source__.file
    current, final = firstindex(s), lastindex(s)
    _s = Expr(:string)
    args = _s.args

    while (regex_match = match(r"(\\+)(\()", s, current)) ≢ nothing
        backslashes, start = length(first(regex_match.captures)), last(regex_match.offsets)
        interpolate, previous = isodd(backslashes), prevind(s, start)

        current < previous && push!(args, s[current:prevind(s, previous, interpolate + backslashes ÷ 2)])

        if interpolate
            x, current = parse(s, start; filename, greedy = false)
            isexpr(x, :incomplete) && throw(first(x.args))
            interpolation = :($TypstString())

            append!(interpolation.args, parse(s[previous:prevind(s, current)]; filename).args[2:end])
            push!(args, esc(interpolation))
        else current = start
        end
    end

    current > final || push!(args, s[current:final])
    :(TypstString(TypstText($_s)))
end

include("typst_contexts.jl")
include("typst_strings.jl")
include("show_typst.jl")

# `Typstry`

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
    show(::IO, ::MIME"text/typst", ::Union{Typst, TypstString, TypstText})

Print in Typst format using [`show_typst`](@ref) and
formatting data specified by a [`TypstContext`](@ref).

The formatting data is given by combining the [`context`](@ref),
the `TypstContext` constructor implemented for the given type,
and the `IOContext` key `:typst_context` such that each successive
context overwrites duplicate keys in previous contexts.

See also [`TypstString`](@ref) and [`TypstText`](@ref).
"""
show(io::IO, ::MIME"text/typst", t::Union{Typst, TypstString, TypstText}) =
    _show_typst(io, t)
show(io::IOContext, ::MIME"text/typst", t::Union{Typst, TypstString, TypstText}) =
    _show_typst(io, unwrap(io, :typst_context, TypstContext()), t)

# Internals

"""
    examples

A constant `Vector` of Julia values and their corresponding
`Type`s implemented for [`show_typst`](@ref).
"""
const examples = [
    Any[true, 1, 1.2, 1 // 2] => AbstractArray
    'a' => AbstractChar
    1.2 => AbstractFloat
    Any[true 1; 1.2 1 // 2] => AbstractMatrix
    "a" => AbstractString
    true => Bool
    im => Complex{Bool}
    1 + 2im => Complex
    π => Irrational
    nothing => Nothing
    0:2:6 => OrdinalRange{<:Integer, <:Integer}
    1 // 2 => Rational
    r"[a-z]" => Regex
    1 => Signed
    StepRangeLen(0, 2, 4) => StepRangeLen{<:Integer, <:Integer, <:Integer}
    (true, 1, 1.2, 1 // 2) => Tuple
    Typst(1) => Typst
    typst"[\"a\"]" => TypstString
    TypstText([1, 2, 3, 4]) => TypstText
    0xff => Unsigned
    v"1.2.3" => VersionNumber
    html"<p>a</p>" => HTML
    text"[\"a\"]" => Text
    Date(1) => Date
    DateTime(1) => DateTime
    Day(1) => Period
    Time(0) => Time
]

end # Strings
