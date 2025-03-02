
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

import Base: IOBuffer, ==, codeunit, isvalid, iterate, ncodeunits, pointer, repr, show, showerror
using ..Typstry: enclose, join_with, unwrap
using .Docs: HTML, Text
using .Meta: isexpr, parse
using Dates:
    Date, DateTime, Day, Hour, Minute, Period, Second, Time, Week,
    day, hour, minute, month, second, year

# `Typstry`

"""
    ContextError <: Exception
    ContextError(::Type, ::Type, ::Symbol)

An `Exception` indicating that a [`context`](@ref) key returned a value of an incorrect type.

# Examples

```jldoctest
julia> ContextError(Mode, String, :mode)
ContextError(Mode, String, :mode)
```
"""
struct ContextError <: Exception
    expected::Type
    received::Type
    key::Symbol
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
    context(x)

Provide formatting data for
[`show(::IO,\u00A0::MIME"text/typst",\u00A0::Typst)`](@ref).

Implement this function for a custom type to specify its custom settings and parameters.
Passing a value wrapped in [`Typst`](@ref) will `merge!` its custom context with defaults,
such that the defaults may be overwritten.
To be compatible with merging contexts and constructing an `IOContext`,
methods must return an `AbstractDict{Symbol}`.

| Setting         | Default               | Type           | Description                                                                                                                                                                       |
|:----------------|:----------------------|:---------------|:----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `:backticks`    | `3`                   | `Int`          | The number of backticks to enclose raw text markup, which may be increased to disambiguiate nested raw text.                                                                             |
| `:block`        | `false`               | `Bool`         | When `:mode => math`, specifies whether the enclosing dollar signs are padded with a space to render the element inline or its own block.                                         |
| `:depth`        | `0`                   | `Int`          | The current level of nesting within container types to specify the degree of indentation.                                                                                         |
| `:mode`         | `markup`              | [`Mode`](@ref) | The current Typst syntactical context where `code` follows the number sign, `markup` is at the top-level and enclosed in square brackets, and `math` is enclosed in dollar signs. |
| `:parenthesize` | `true`                | `Bool`         | Whether to enclose some mathematical elements in parentheses to specify their operator precedence and avoid ambiguity.                                                            |
| `:tab_size`     | `2`                   | `Int`          | The number of spaces used by some elements with multi-line Typst formatting, which is repeated for each level of `depth`                                                          |
"""
context(x::Typst) = merge!(Dict(
    :backticks => 3,
    :block => false,
    :depth => 0,
    :mode => markup,
    :parenthesize => true,
    :tab_size => 2
), context(x.value))
context(::Any) = Dict{Symbol, Union{}}()

"""
    show(::IO, ::MIME"text/plain", ::ContextError)

# Examples

```jldoctest
julia> show(stdout, "text/plain", ContextError(Mode, String, :mode))
ContextError(Mode, String, :mode)
```
"""
show(io::IO, ::MIME"text/plain", ce::ContextError) =
    print(io, ContextError, "(", ce.expected, ", ", ce.received, ", :", ce.key, ")")

"""
    show(::IO, ::MIME"text/typst", ::Union{Typst, TypstString, TypstText})

Print in Typst format.

This method provides formatting data to [`show_typst`](@ref)
specified by a default and custom [`context`](@ref).

See also [`Typst`](@ref), [`TypstString`](@ref), and [`TypstText`](@ref).

# Examples

```jldoctest
julia> show(stdout, "text/typst", typst"a")
a

julia> show(stdout, "text/typst", Typst("a"))
"a"

julia> show(stdout, "text/typst", Typst(Text("a")))
#"a"
```
"""
show(io::IO, m::MIME"text/typst", t::Union{Typst, TypstString, TypstText}) =
    show(IOContext(io), m, t)
function show(io::IOContext, ::MIME"text/typst", t::Union{Typst, TypstString, TypstText})
    for (k, v) in context(t)
        io = IOContext(io, k => get(io, k, v))
    end

    show_typst(io, t)
end

"""
    showerror(::IO, ::ContextError)

# Examples

```jldoctest
julia> showerror(stdout, ContextError(Mode, String, :mode))
ContextError: the `context` key `:mode` expected a value of type `Mode` but received `String`
```
"""
showerror(io::IO, ce::ContextError) = print(io, "ContextError: the `",
    context, "` key `:", ce.key, "` expected a value of type `",
ce.expected, "` but received `", ce.received, "`")

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
