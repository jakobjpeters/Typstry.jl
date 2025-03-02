
module ShowTypst

using Dates:
    Date, DateTime, Day, Hour, Minute, Period, Second, Time, Week,
    day, hour, minute, month, second, year
using ..Strings:
    TypstContexts, Utilities, TypstStrings.TypstString, Typst, TypstText,
    @typst_str, code, markup, math, unwrap
using .TypstContexts: TypstContext, context, default_context, merge_contexts!
using .Utilities: enclose, join_with

"""
    code_mode(io, tc)

Print the number sign, unless `mode(tc) == code`.

See also [`Mode`](@ref) and [`mode`](@ref Typstry.Strings.mode).
"""
code_mode(io, tc) = if mode(tc) ≠ code print(io, "#") end

"""
    indent(tc)
"""
indent(tc) = " " ^ tab_size(tc)

"""
    math_mode(f, io, tc, x; kwargs...)
"""
math_mode(f, io, tc, x; kwargs...) = enclose(f, io, x, math_pad(tc); kwargs...)

"""
    math_pad(tc)

Return `""`, `"\\\$"`, or `"\\\$ "` depending on the
[`block`](@ref Typstry.Strings.block) and [`mode`](@ref Typstry.Strings.mode) settings.
"""
math_pad(tc) =
    if mode(tc) == math ""
    else block(tc) ? "\$ " : "\$"
    end

"""
    show_parameters(io, tc, f, keys, final)
"""
function show_parameters(io, tc, f, keys, final)
    pairs = map(key -> key => unwrap(tc, TypstString, key), filter(key -> haskey(tc, key), keys))

    println(io, f, "(")
    join_with(io, pairs, ",\n") do io, (key, value)
        print(io, indent(tc) ^ (depth(tc) + 1), key, ": ")
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
    join_with((io, x) -> _show_typst(io, x; parenthesize = false, mode = code), io, x, ", ")
    if length(x) == 1 print(io, ",") end
end

"""
    show_raw(f, io, tc, x, language)
"""
function show_raw(f, io, tc, x, language)
    _backticks, _block = "`" ^ backticks(tc), block(tc)

    mode(tc) == math && print(io, "#")
    print(io, _backticks, language)

    if _block
        _indent, _depth = indent(tc), depth(tc)

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
    show_vector(io, tc, x)
"""
show_vector(io, tc, x) = math_mode(io, tc, x) do io, x
    _depth, _indent = depth(tc), indent(tc)
    __depth = _depth + 1

    show_parameters(io, tc, "vec", [:delim, :gap], true)
    print(io, _indent ^ __depth)
    join_with((io, x) -> _show_typst(io, TypstContext(; depth = __depth, mode = math, parenthesize = false), x), io, x, ", "),
    print(io, "\n", _indent ^ _depth, ")")
end

for (key, value) in pairs(default_context)
    @eval begin
        $key(context) = unwrap(context, $(QuoteNode(key)), $value)
        @doc "$($key)" $key
    end
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
julia> Typstry.Strings.ShowTypst.duration(Dates.Day(1))
:days

julia> Typstry.Strings.ShowTypst.duration(Dates.Hour(1))
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
julia> Typstry.Strings.ShowTypst.dates(Dates.Date(1))
("datetime", (:year, :month, :day), (1, 1, 1))

julia> Typstry.Strings.ShowTypst.dates(Dates.Day(1))
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


function _show_typst(io, tc, x)
    _tc = TypstContext(x)
    merge!(merge_contexts!(_tc, context), tc)
    show_typst(io, _tc, x)
end
_show_typst(io, x; kwargs...) = _show_typst(io, TypstContext(; kwargs...), x)

"""
    show_typst(::IO = stdout, ::TypstContext = TypstContext(), x)

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
show_typst(io, tc, x::AbstractChar) = show_typst(io, tc, string(x))
show_typst(io, tc, x::AbstractFloat) =
    if isinf(x)
        code_mode(io, tc)
        print(io, "calc.inf")
    elseif isnan(x)
        code_mode(io, tc)
        print(io, "calc.nan")
    elseif mode(tc) == code print(io, x)
    else enclose(print, io, x, math_pad(tc))
    end
show_typst(io, tc, x::AbstractMatrix) = mode(tc) == code ?
    show_array(io, x) :
    math_mode((io, x; indent, depth) -> begin
        _depth = depth + 1

        show_parameters(io, tc, "mat", [:augment, :column_gap, :delim, :gap, :row_gap], true)
        join_with((io, x; indent) -> begin
            print(io, indent ^ _depth)
            join_with((io, x) -> _show_typst(io, x; depth = _depth, mode = math, parenthesize = false), io, x, ", ")
        end, io, eachrow(x), ";\n"; indent)
        print(io, "\n", indent ^ depth, ")")
    end, io, TypstContext(; mode = mode(tc)), x; indent = indent(tc), depth = depth(tc))
show_typst(io, tc, x::AbstractString) = enclose((io, x) -> escape_string(io, x, "\""),
    io, x, "\"")
show_typst(io, tc, x::Bool) = mode(tc) == math ? enclose(print, io, x, "\"") : print(io, x)
show_typst(io, tc, x::Complex{Bool}) = _show_typst(io, tc, Complex(Int(real(x)), Int(imag(x))))
show_typst(io, tc, x::Complex) = math_mode(io, tc, x) do io, x
    imaginary = imag(x)
    _real, _imaginary = real(x), abs(imaginary)
    __real, __imaginary = _real == 0, _imaginary == 0
    ___imaginary = signbit(imaginary)
    _enclose = __real || __imaginary || !(mode(tc) == math && parenthesize(tc)) ? ("", "") : ("(", ")")

    enclose(IOContext(io, :typst_context => TypstContext(; mode = math)), x, _enclose...) do io, x
        _tc = TypstContext(; mode = math)
        __real && !__imaginary || _show_typst(io, _tc, _real)

        if _imaginary ≠ 0
            if !__real enclose(print, io, ___imaginary ? "-" : "+", " ")
            elseif ___imaginary print(io, "-")
            end

            _imaginary == 1 || _show_typst(io, _tc, abs(imaginary))
            print(io, "i")
        end
    end
end
show_typst(io, tc, x::HTML) = show_raw((io, x) -> show(io, MIME"text/html"(), x), io, tc, x, "html")
show_typst(io, tc, x::Irrational) = mode(tc) == code ?
    _show_typst(io, tc, Float64(x)) :
    math_mode(print, io, tc, x)
function show_typst(io, tc, ::Nothing)
    code_mode(io, tc)
    print(io, "none")
end
function show_typst(io, tc, x::Rational)
    _mode = mode(tc)
    f = (io, x; kwargs...) -> enclose(io, x, (parenthesize(kwargs) ? ("(", ")") : ("", ""))...) do io, x
        _show_typst(io, numerator(x); kwargs...)
        print(io, " / ")
        _show_typst(io, denominator(x); kwargs...)
    end

    _mode == markup ?
        enclose((io, x) -> f(io, x; mode = math, parenthesize = false), io, x, block(tc) ? "\$ " : "\$") :
        f(io, x; mode = _mode, parenthesize = parenthesize(tc))
end
function show_typst(io, tc, x::Regex)
    code_mode(io, tc)
    enclose(io, x, "regex(", ")") do io, x
        buffer = IOBuffer()
        print(buffer, x)
        seek(buffer, 1)
        write(io, read(buffer))
    end
end
show_typst(io, tc, x::Signed) = mode(tc) == code ?
    print(io, x) :
    enclose(print, io, x, math_pad(tc))
function show_typst(io, tc, x::Text)
    code_mode(io, tc)
    _show_typst(io, string(x))
end
show_typst(io, tc, x::Typst) = show_typst(io, tc, x.value)
show_typst(io, tc, x::TypstString) = print(io, x)
show_typst(io, tc, x::TypstText) = print(io, x.value)
function show_typst(io, tc, x::Unsigned)
    code_mode(io, tc)
    show(io, x)
end
function show_typst(io, tc, x::VersionNumber) # TODO: remove allocation
    code_mode(io, tc)
    enclose((io, x) -> join_with(print, io, eachsplit(string(x), "."), ", "), io, x, "version(", ")")
end
show_typst(io, tc, x::Union{AbstractArray, Tuple}) =
    mode(tc) == code ? show_array(io, x) : show_vector(io, tc, x)
show_typst(io, tc, x::Union{
    OrdinalRange{<:Integer, <:Integer},
    StepRangeLen{<:Integer, <:Integer, <:Integer}
}) = mode(tc) == code ?
    enclose(io, x, "range(", ")") do io, x
        _step = step(x)

        _show_typst(io, first(x); mode = code)
        print(io, ", ")
        _show_typst(io, last(x) + 1; mode = code)

        if _step ≠ 1
            print(io, ", step: ")
            _show_typst(io, _step; mode = code)
        end
    end : show_vector(io, tc, x)
function show_typst(io, tc, x::Union{Date, DateTime, Period, Time})
    f, keys, values = dates(x)
    _values = map(value -> TypstString(value; mode = code), values)

    code_mode(io, tc)
    show_parameters(io, TypstContext(; zip(keys, _values)...), f, keys, false)
    print(io, indent(tc) ^ depth(tc), ")")
end
show_typst(tc, x) = _show_typst(stdout, tc, x)
show_typst(x) = show_typst(TypstContext(), x)

end # ShowTypst
