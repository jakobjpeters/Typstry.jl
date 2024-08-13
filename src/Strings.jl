
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

import Base: IOBuffer, ==, codeunit, isvalid, iterate, ncodeunits, pointer, repr, show
using Base: escape_raw_string
using .Docs: HTML, Text
using .Iterators: Stateful
using .Meta: isexpr, parse
using Dates:
    Date, DateTime, Day, Hour, Minute, Period, Second, Time, Week,
    day, hour, minute, month, second, year

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
    TypstString <: AbstractString
    TypstString(::Any; context...)

Format the value as a Typst formatted string.

Optional Julia settings and Typst parameters are passed to
[`show(::IO,\u00A0::MIME"text/typst",\u00A0::Typst)`](@ref)
in an `IOContext`. See also [`show_typst`](@ref) for a list of supported types.

!!! info
    This type implements the `String` interface.
    However, the interface is undocumented, which may result in unexpected behavior.

# Examples

```jldoctest
julia> TypstString(1)
typst"\$1\$"

julia> TypstString(1 + 2im; mode = math)
typst"(1 + 2i)"
```
"""
struct TypstString <: AbstractString
    text::String

    TypstString(x; context...) =
        new(sprint(show, typst_mime, maybe_wrap(x); context = (context...,)))
end

TypstString(x::TypstString; context...) = x

"""
    TypstText{T}
    TypstText(::Any)

A wrapper whose [`show_typst`](@ref) method uses `print`.

!!! info
    This may be used to insert control characters into a [`TypstString`](@ref).
    Unescaped control characters in `TypstString`s may
    break formatting in some environments, such as the REPL.

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

    current ≤ final && push!(args, s[current:final])
    :(TypstString(TypstText($_s)))
end

# Internals

"""
    typst_mime

Equivalent to `MIME"text/typst"()`.

# Examples

```jldoctest
julia> Typstry.Strings.typst_mime
MIME type text/typst
```
"""
const typst_mime = MIME"text/typst"()

"""
    backticks(io)

Return to `io[:backticks]::Int`.

# Examples

```jldoctest
julia> Typstry.Strings.backticks(IOContext(stdout, :backticks => 3))
3
```
"""
backticks(io) = io[:backticks]::Int

"""
    block(io)

Return `io[:block]::Bool`.

# Examples

```jldoctest
julia> Typstry.Strings.block(IOContext(stdout, :block => true))
true
```
"""
block(io) = io[:block]::Bool

"""
    code_mode(io)

Print the number sign, unless `mode(io) == code`.

See also [`Mode`](@ref) and [`mode`](@ref Typstry.Strings.mode).

# Examples

```jldoctest
julia> Typstry.Strings.code_mode(IOContext(stdout, :mode => code))

julia> Typstry.Strings.code_mode(IOContext(stdout, :mode => markup))
#

julia> Typstry.Strings.code_mode(IOContext(stdout, :mode => math))
#
```
"""
code_mode(io) = if mode(io) ≠ code print(io, "#") end

"""
    depth(io)

Return `io[:depth]::Int`.

# Examples

```jldoctest
julia> Typstry.Strings.depth(IOContext(stdout, :depth => 0))
0
```
"""
depth(io) = io[:depth]::Int

"""
    enclose(f, io, x, left, right = reverse(left); kwargs...)

Call `f(io,\u00A0x;\u00A0kwargs...)` between printing `left` and `right`, respectfully.

# Examples

```jldoctest
julia> Typstry.Strings.enclose((io, i; x) -> print(io, i, x), stdout, 1, "\\\$ "; x = "x")
\$ 1x \$
```
"""
function enclose(f, io, x, left, right = reverse(left); context...)
    print(io, left)
    f(io, x; context...)
    print(io, right)
end

"""
    indent(io)

Return `" " ^ io[:tab_size]::Int`.

See also [`TypstString`](@ref).

# Examples

```jldoctest
julia> Typstry.Strings.indent(IOContext(stdout, :tab_size => 2))
"  "
```
"""
indent(io) = " " ^ io[:tab_size]

"""
    join_with(f, io, xs, delimeter; kwargs...)

Similar to `join`, except printing with `f(io, x; kwargs...)`.

# Examples

```jldoctest
julia> Typstry.Strings.join_with((io, i; x) -> print(io, -i, x), stdout, 1:4, ", "; x = "x")
-1x, -2x, -3x, -4x
```
"""
function join_with(f, io, xs, delimeter; kwargs...)
    _xs = Stateful(xs)

    for x in _xs
        f(io, x; kwargs...)
        isempty(_xs) || print(io, delimeter)
    end
end

"""
    math_mode(f, io, x; kwargs...)
"""
math_mode(f, io, x; kwargs...) = enclose(f, io, x, math_pad(io); kwargs...)

"""
    math_pad(io)

Return `""`, `"\\\$"`, or `"\\\$ "` depending on the
[`block`](@ref Typstry.Strings.block) and [`mode`](@ref Typstry.Strings.mode) settings.

# Examples

```jldoctest
julia> Typstry.Strings.math_pad(IOContext(stdout, :mode => math))
""

julia> Typstry.Strings.math_pad(IOContext(stdout, :block => true, :mode => markup))
"\\\$ "

julia> Typstry.Strings.math_pad(IOContext(stdout, :block => false, :mode => markup))
"\\\$"
```
"""
math_pad(io) =
    if mode(io) == math ""
    else block(io) ? "\$ " : "\$"
    end

"""
    mode(io)

Return `io[:mode]::Mode`.

See also [`Mode`](@ref).

# Examples

```jldoctest
julia> Typstry.Strings.mode(IOContext(stdout, :mode => code))
code::Mode = 0
```
"""
mode(io) = io[:mode]::Mode

"""
    maybe_wrap(::Any)

Wrap the value in [`Typst`](@ref) unless it is a [`TypstString`](@ref) or [`TypstText`](@ref).

# Examples

```jldoctest
julia> Typstry.Strings.maybe_wrap(1)
Typst{Int64}(1)

julia> Typstry.Strings.maybe_wrap(TypstString(1))
typst"\$1\$"

julia> Typstry.Strings.maybe_wrap(TypstText(1))
TypstText{Int64}(1)
```
"""
maybe_wrap(x::Union{TypstString, TypstText}) = x
maybe_wrap(x) = Typst(x)

"""
    parenthesize(io)

Return `io[:parenthesize]::Bool`.

# Examples

```jldoctest
julia> Typstry.Strings.parenthesize(IOContext(stdout, :parenthesize => true))
true
```
"""
parenthesize(io) = io[:parenthesize]::Bool

"""
    show_parameters(io, f, keys, final)

# Examples

```jldoctest
julia> Typstry.Strings.show_parameters(
           IOContext(stdout, :depth => 0, :tab_size => 2, :delim => typst"\\\"(\\\""),
       "vec", [:delim, :gap], true)
vec(
  delim: "(",
```
"""
function show_parameters(io, f, keys, final)
    pairs = filter(!isempty ∘ last, map(key -> key => get(io, key, typst"")::TypstString, keys))

    println(io, f, "(")
    join_with(io, pairs, ",\n") do io, (key, value)
        print(io, indent(io) ^ (depth(io) + 1), key, ": ")
        _show_typst(io, value)
    end

    if !isempty(pairs)
        final && print(io, ",")
        println(io)
    end
end

"""
    show_array(io, x)
"""
show_array(io, x) = enclose(io, x, "(", ")") do io, x
    join_with(_show_typst, IOContext(io, :parenthesize => false), x, ", ")
    length(x) == 1 && print(io, ",")
end

"""
    show_raw(f, io, x, language)
"""
function show_raw(f, io, x, language)
    _backticks, _block = "`" ^ backticks(io), block(io)

    mode(io) == math && print(io, "#")
    print(io, _backticks, language)

    if _block
        _indent, _depth = indent(io), depth(io)

        print(io, "\n")

        for line in eachsplit(sprint(f, x), "\n")
            println(io, _indent ^ (_depth + 1), line)
        end

        print(io, _indent ^ _depth)
    else enclose(f, io, x, " ")
    end

    print(io, _backticks)
end

"""
    show_vector(io, x)
"""
show_vector(io, x) = math_mode(io, x) do io, x
    _depth, _indent = depth(io), indent(io)
    __depth = _depth + 1

    show_parameters(io, "vec", [:delim, :gap], true)
    print(io, _indent ^ __depth)
    join_with(_show_typst, IOContext(io, :depth => __depth, :mode => math, :parenthesize => false), x, ", "),
    print(io, "\n", _indent ^ _depth, ")")
end

## Dates.jl

"""
    date_time(::Union{Dates.Date, Dates.Time, Dates.DateTime})
"""
date_time(::Date) = year, month, day
date_time(::Time) = hour, minute, second
date_time(::DateTime) = year, month, day, hour, minute, second

"""
    duration(::Dates.Period)

# Examples

```jldoctest
julia> Typstry.Strings.duration(Dates.Day(1))
:days

julia> Typstry.Strings.duration(Dates.Hour(1))
:hours
```
"""
duration(::Day) = :days
duration(::Hour) = :hours
duration(::Minute) = :minutes
duration(::Second) = :seconds
duration(::Week) = :weeks

"""
    dates(::Union{Dates.Date, Dates.DateTime, Dates.Period, Dates.Time})

# Examples

```jldoctest
julia> Typstry.Strings.dates(Dates.Date(1))
("datetime", (:year, :month, :day), (1, 1, 1))

julia> Typstry.Strings.dates(Dates.Day(1))
("duration", (:days,), (TypstText{String}("1"),))
```
"""
function dates(x::Union{Date, DateTime, Time})
    fs = date_time(x)
    "datetime", map(Symbol, fs), map(f -> f(x), fs)
end
function dates(x::Period)
    buffer = IOBuffer()

    print(buffer, x)
    seekstart(buffer)

    "duration", (duration(x),), (TypstText(readuntil(buffer, " ")),)
end

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

_show_typst(io, x) = show(io, typst_mime, Typst(x))

"""
    show_typst(x)

Print to `stdout` in Typst format with the default and custom [`context`](@ref)s.

# Examples

```jldoctest
julia> show_typst(1 // 2)
\$1 / 2\$

julia> show_typst(1:4)
\$vec(
  1, 2, 3, 4
)\$
```
"""
show_typst(x) = _show_typst(stdout, x)

"""
    show_typst(io, x)

Print in Typst format with Julia settings and Typst parameters provided by an `IOContext`.

Implement this function for a custom type to specify its Typst formatting.
A setting is a value used in Julia, whose type varies across settings.
A parameter is passed directly to a Typst function and must be a [`TypstString`](@ref)
with the same name as in Typst, except that dashes are replaced with underscores.
Settings each have a default value, whereas the default values of parameters are handled by Typst functions.
Some settings, such as `block`, correspond with a parameter but may also be used in Julia.

For additional information on settings and parameters, see also [`context`](@ref)
and the [Typst Documentation](https://typst.app/docs/), respectively.

!!! info
    Some types, particularly containers, may call
    [`show(::IO,\u00A0::MIME"text/typst",\u00A0::Typst)`](@ref)
    to format a value, which may use additional settings and parameters.

!!! warning
    This function's methods are incomplete.
    Please file an issue or create a pull-request for missing methods.

| Type                                                      | Settings                                 | Parameters                                              |
|:----------------------------------------------------------|:-----------------------------------------|:--------------------------------------------------------|
| `AbstractArray`                                           | `:block`, `:depth`, `:mode`, `:tab_size` | `:delim`, `:gap`                                        |
| `AbstractChar`                                            |                                          |                                                         |
| `AbstractFloat`                                           | `:mode`                                  |                                                         |
| `AbstractMatrix`                                          | `:block`, `:depth`, `:mode`, `:tab_size` | `:augment`, `:column_gap`, `:delim`, `:gap`, `:row_gap` |
| `AbstractString`                                          |                                          |                                                         |
| `Bool`                                                    | `:mode`                                  |                                                         |
| `Complex{Bool}`                                           | `:block`, `:mode`, `:parenthesize`       |                                                         |
| `Complex`                                                 | `:block`, `:mode`, `:parenthesize`       |                                                         |
| `Irrational`                                              | `:mode`                                  |                                                         |
| `Nothing`                                                 | `:mode`                                  |                                                         |
| `OrdinalRange{<:Integer,\u00A0<:Integer}`                 | `:mode`                                  |                                                         |
| `Rational`                                                | `:block`, `:mode`, `:parenthesize`       |                                                         |
| `Regex`                                                   | `:mode`                                  |                                                         |
| `Signed`                                                  | `:mode`                                  |                                                         |
| `StepRangeLen{<:Integer,\u00A0<:Integer,\u00A0<:Integer}` | `:mode`                                  |                                                         |
| `Tuple`                                                   | `:block`, `:depth`, `:mode`, `:tab_size` | `:delim`, `:gap`                                        |
| `Typst`                                                   |                                          |                                                         |
| `TypstString`                                             |                                          |                                                         |
| `TypstText`                                               | `:mode`                                  |                                                         |
| `Unsigned`                                                | `:mode`                                  |                                                         |
| `VersionNumber`                                           | `:mode`                                  |                                                         |
| `Docs.HTML`                                               | `:block`, `:depth`, `:mode`, `:tab_size` |                                                         |
| `Docs.Text`                                               | `:mode`                                  |                                                         |
| `Dates.Date`                                              | `:mode`, `:indent`                       |                                                         |
| `Dates.DateTime`                                          | `:mode`, `:indent`                       |                                                         |
| `Dates.Period`                                            | `:mode`, `:indent`                       |                                                         |
| `Dates.Time`                                              | `:mode`, `:indent`                       |                                                         |
"""
show_typst(io, x::AbstractChar) = show_typst(io, string(x))
show_typst(io, x::AbstractFloat) =
    if isinf(x)
        code_mode(io)
        print(io, "calc.inf")
    elseif isnan(x)
        code_mode(io)
        print(io, "calc.nan")
    elseif mode(io) == code print(io, x)
    else enclose(print, io, x, math_pad(io))
    end
show_typst(io, x::AbstractMatrix) = mode(io) == code ?
    show_array(io, x) :
    math_mode((io, x; indent, depth) -> begin
        _depth = depth + 1

        show_parameters(io, "mat", [:augment, :column_gap, :delim, :gap, :row_gap], true)
        join_with((io, x; indent) -> begin
            print(io, indent ^ _depth)
            join_with(_show_typst, io, x, ", ")
        end, IOContext(io, :depth => _depth, :mode => math), eachrow(x), ";\n"; indent)
        print(io, "\n", indent ^ depth, ")")
    end, IOContext(io, :parenthesize => false), x; indent = indent(io), depth = depth(io))
show_typst(io, x::AbstractString) = enclose((io, x) -> escape_string(io, x, "\""),
    io, x, "\"", mode(io) == math && length(x) == 1 ? " \"" : "\"")
show_typst(io, x::Bool) = mode(io) == math ? enclose(print, io, x, "\"") : print(io, x)
show_typst(io, x::Complex{Bool}) = _show_typst(io, Complex(Int(real(x)), Int(imag(x))))
show_typst(io, x::Complex) = math_mode(io, x) do io, x
    imaginary = imag(x)
    _real, _imaginary = real(x), abs(imaginary)
    __real, __imaginary = _real == 0, _imaginary == 0
    ___imaginary = signbit(imaginary)
    _enclose = __real || __imaginary || !(mode(io) == math && parenthesize(io)) ? ("", "") : ("(", ")")

    enclose(IOContext(io, :mode => math), x, _enclose...) do io, x
        __real && !__imaginary || _show_typst(io, _real)

        if _imaginary ≠ 0
            if !__real enclose(print, io, ___imaginary ? "-" : "+", " ")
            elseif ___imaginary print(io, "-")
            end

            _imaginary == 1 || _show_typst(io, abs(imaginary))
            print(io, "i")
        end
    end
end
show_typst(io, x::HTML) = show_raw((io, x) -> show(io, MIME"text/html"(), x), io, x, "html")
show_typst(io, x::Irrational) = mode(io) == code ?
    _show_typst(io, Float64(x)) :
    math_mode(print, io, x)
function show_typst(io, ::Nothing)
    code_mode(io)
    print(io, "none")
end
function show_typst(io, x::Rational)
    _mode = mode(io)
    f = (io, x) -> enclose(io, x, (parenthesize(io) ? ("(", ")") : ("", ""))...) do io, x
        _show_typst(io, numerator(x))
        print(io, " / ")
        _show_typst(io, denominator(x))
    end

    _mode == markup ?
        enclose(f, IOContext(io, :mode => math, :parenthesize => false), x, block(io) ? "\$ " : "\$") :
        f(io, x)
end
function show_typst(io, x::Regex)
    code_mode(io)
    enclose(io, x, "regex(", ")") do io, x
        buffer = IOBuffer()
        print(buffer, x)
        seek(buffer, 1)
        write(io, read(buffer))
    end
end
show_typst(io, x::Signed) = mode(io) == code ?
    print(io, x) :
    enclose(print, io, x, math_pad(io))
function show_typst(io, x::Text)
    code_mode(io)
    _show_typst(io, string(x))
end
show_typst(io, x::Typst) = show_typst(io, x.value)
show_typst(io, x::TypstString) = print(io, x)
show_typst(io, x::TypstText) = print(io, x.value)
function show_typst(io, x::Unsigned)
    code_mode(io)
    show(io, x)
end
function show_typst(io, x::VersionNumber) # TODO: remove allocation
    code_mode(io)
    enclose((io, x) -> join_with(print, io, eachsplit(string(x), "."), ", "), io, x, "version(", ")")
end
show_typst(io, x::Union{AbstractArray, Tuple}) =
    mode(io) == code ? show_array(io, x) : show_vector(io, x)
show_typst(io, x::Union{
    OrdinalRange{<:Integer, <:Integer},
    StepRangeLen{<:Integer, <:Integer, <:Integer}
}) = mode(io) == code ?
    enclose(io, x, "range(", ")") do io, x
        _step = step(x)

        _show_typst(io, first(x))
        print(io, ", ")
        _show_typst(io, last(x) + 1)

        if _step ≠ 1
            print(io, ", step: ")
            _show_typst(io, _step)
        end
    end : show_vector(io, x)
function show_typst(io, x::Union{Date, DateTime, Period, Time})
    f, keys, values = dates(x)
    _values = map(value -> TypstString(value; mode = code), values)

    code_mode(io)
    show_parameters(IOContext(io, map(Pair, keys, _values)...), f, keys, false)
    print(io, indent(io) ^ depth(io), ")")
end

# `Base`

"""
    IOBuffer(::TypstString)

See also [`TypstString`](@ref).

# Examples

```jldoctest
julia> IOBuffer(typst"a")
IOBuffer(data=UInt8[...], readable=true, writable=false, seekable=true, append=false, size=1, maxsize=Inf, ptr=1, mark=-1)
```
"""
IOBuffer(ts::TypstString) = IOBuffer(ts.text)

"""
    codeunit(::TypstString)
    codeunit(::TypstString, ::Integer)

See also [`TypstString`](@ref).

# Examples

```jldoctest
julia> codeunit(typst"a")
UInt8

julia> codeunit(typst"a", 1)
0x61
```
"""
codeunit(ts::TypstString) = codeunit(ts.text)
codeunit(ts::TypstString, i::Integer) = codeunit(ts.text, i)

"""
    isvalid(::TypstString, ::Integer)

See also [`TypstString`](@ref).

# Examples

```jldoctest
julia> isvalid(typst"a", 1)
true
```
"""
isvalid(ts::TypstString, i::Integer) = isvalid(ts.text, i::Integer)

"""
    iterate(::TypstString, ::Integer)
    iterate(::TypstString)

See also [`TypstString`](@ref).

# Examples

```jldoctest
julia> iterate(typst"a")
('a', 2)

julia> iterate(typst"a", 1)
('a', 2)
```
"""
iterate(ts::TypstString) = iterate(ts.text)
iterate(ts::TypstString, i::Integer) = iterate(ts.text, i)

"""
    ncodeunits(::TypstString)

See also [`TypstString`](@ref).

# Examples

```jldoctest
julia> ncodeunits(typst"a")
1
```
"""
ncodeunits(ts::TypstString) = ncodeunits(ts.text)

"""
    pointer(::TypstString)

See also [`TypstString`](@ref).
"""
pointer(ts::TypstString) = pointer(ts.text)

"""
    repr(::MIME, ::TypstString; kwargs...)

See also [`TypstString`](@ref).

!!! info
    This method patches incorrect output from the assumption in `repr`
    that the parameter is already in the requested `MIME` type when the
    `MIME` type satisfies `istextmime` and the parameter is an `AbstractString`.

# Examples

```jldoctest
julia> repr("text/plain", typst"a")
"typst\\\"a\\\""

julia> repr("text/typst", typst"a")
typst"a"
```
"""
repr(::MIME"text/typst", ts::TypstString; kwargs...) = ts
repr(m::MIME, ts::TypstString; kwargs...) = sprint(show, m, ts; kwargs...)

"""
    show(::IO, ::TypstString)

See also [`TypstString`](@ref).

# Examples

```jldoctest
julia> show(stdout, typst"a")
typst"a"
```
"""
function show(io::IO, ts::TypstString)
    print(io, "typst")
    enclose((io, text) -> escape_raw_string(io, replace(text,
        r"(\\+)\(" => s"\1\1(")), io, ts.text, "\"")
end

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
show(io::IO, m::MIME"text/typst", t::Typst) = show(IOContext(io), m, t)
function show(io::IOContext, ::MIME"text/typst", t::Typst)
    for (k, v) in context(t)
        io = IOContext(io, k => get(io, k, v))
    end

    show_typst(io, t)
end
show(io::IO, ::MIME"text/typst", t::Union{TypstString, TypstText}) = show_typst(io, t)

# Internals

"""
    examples

A constant `Vector` of Julia values and their corresponding
`Type`s implemented for [`show_typst`](@ref).
"""
const examples = [
    Any[true, 1, 1.2, 1 // 2] => AbstractArray,
    'a' => AbstractChar,
    1.2 => AbstractFloat,
    Any[true 1; 1.2 1 // 2] => AbstractMatrix,
    "a" => AbstractString,
    true => Bool,
    im => Complex{Bool},
    1 + 2im => Complex,
    π => Irrational,
    nothing => Nothing,
    0:2:6 => OrdinalRange{<:Integer, <:Integer},
    1 // 2 => Rational,
    r"[a-z]" => Regex,
    1 => Signed,
    StepRangeLen(0, 2, 4) => StepRangeLen{<:Integer, <:Integer, <:Integer},
    (true, 1, 1.2, 1 // 2) => Tuple,
    Typst(1) => Typst,
    typst"[\"a\"]" => TypstString,
    TypstText([1, 2, 3, 4]) => TypstText,
    0xff => Unsigned,
    v"1.2.3" => VersionNumber,
    html"<p>a</p>" => HTML,
    text"[\"a\"]" => Text,
    Date(1) => Date,
    DateTime(1) => DateTime,
    Day(1) => Period,
    Time(0) => Time
]

end # Strings
