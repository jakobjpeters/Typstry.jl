
"""
    backticks(io)

# Examples

```jldoctest
julia> Typstry.Strings.backticks(IOContext(stdout, :backticks => 3))
3
```
"""
backticks(io) = unwrap(io, Int, :backticks)

"""
    block(io)

# Examples

```jldoctest
julia> Typstry.Strings.block(IOContext(stdout, :block => true))
true
```
"""
block(io) = unwrap(io, Bool, :block)

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

# Examples

```jldoctest
julia> Typstry.Strings.depth(IOContext(stdout, :depth => 0))
0
```
"""
depth(io) = unwrap(io, Int, :depth)

"""
    escape(io, n)

Print `\\` to `io` `n` times.

# Examples

```jldoctest
julia> Typstry.Strings.escape(stdout, 2)
\\\\
```
"""
escape(io, n) =
    for _ in 1:n
        print(io, '\\')
    end

"""
    indent(io)

# Examples

```jldoctest
julia> Typstry.Strings.indent(IOContext(stdout, :tab_size => 2))
"  "
```
"""
indent(io) = " " ^ unwrap(io, Int, :tab_size)

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

# Examples

```jldoctest
julia> Typstry.Strings.mode(IOContext(stdout, :mode => code))
code::Mode = 0
```
"""
mode(io) = unwrap(io, Mode, :mode)

"""
    parenthesize(io)

# Examples

```jldoctest
julia> Typstry.Strings.parenthesize(IOContext(stdout, :parenthesize => true))
true
```
"""
parenthesize(io) = unwrap(io, Bool, :parenthesize)

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
    pairs = map(key -> key => unwrap(io, TypstString, key), filter(key -> haskey(io, key), keys))

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
    if length(x) == 1 print(io, ",") end
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

_show_typst(io, x::Union{Typst, TypstString, TypstText}) = show(io, typst_mime, x)
_show_typst(io, x) = _show_typst(io, Typst(x))

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
| `TypstText`                                               |                                          |                                                         |
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
    io, x, "\"")
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
