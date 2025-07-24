
# """
#     counter
# """
# const counter = Stateful(countfrom())

# """
#     lock
# """
# const lock = ReentrantLock()

# """
#     parameters
# """
# const parameters = Dict(
#     :image => [:alt, :fit, :height, :width],
#     :mat => [:align, :augment, :column_gap, :delim, :gap, :row_gap],
#     :raw => [:align, :block, :lang, :syntaxes, :tab_size, :theme],
#     :text => [
#         :alternates, :baseline, :bottom_edge, :cjk_latin_spacing, :costs, :dir,
#         :discretionary_ligatures, :fallback, :features, :fill, :font, :fractions,
#         :historical_ligatures, :hyphenate, :kerning, :lang, :ligatures, :number_type,
#         :number_width, :overhang, :region, :script, :size, :slashed_zero, :spacing,
#         :stretch, :stroke, :style, :stylistic_set, :top_edge, :tracking, :weight
#     ],
#     :vec => [:align, :delim, :gap]
# )

"""
    compile_workload(examples)

Given an iterable of value-type pairs, interpolate each value into
a `@typst_str` within a `PrecompileTools.@compile_workload` block.
"""
compile_workload(examples::Vector) = @compile_workload for example ∈ examples
    render(first(example))
end

"""
    code_mode(io, tc)

Print the number sign, unless `mode(tc) == code`.

See also [`Mode`](@ref) and [`mode`](@ref Typstry.mode).
"""
code_mode(io::IO, tc) = if mode(tc) ≠ code print(io, "#") end

date_time(::Date) = year, month, day
date_time(::Time) = hour, minute, second
date_time(::DateTime) = year, month, day, hour, minute, second

@doc"""
    date_time(::Union{Dates.Date, Dates.Time, Dates.DateTime})
""" date_time

function dates(x::Union{Date, DateTime, Time})
    fs = date_time(x)
    "datetime", map(Symbol, fs), map(f -> f(x), fs)
end
function dates(x::Period)
    buffer = IOBuffer()

    print(buffer, x)
    seekstart(buffer)

    "duration", (duration(x),), (TypstText(readuntil(buffer, ' ')),)
end

@doc """
    dates(::Union{Dates.Date, Dates.DateTime, Dates.Period, Dates.Time})

# Examples

```jldoctest
julia> Typstry.dates(Dates.Date(1))
("datetime", (:year, :month, :day), (1, 1, 1))

julia> Typstry.dates(Dates.Day(1))
("duration", (:days,), (TypstText("1"),))
```
""" dates

duration(::Day) = :days
duration(::Hour) = :hours
duration(::Minute) = :minutes
duration(::Second) = :seconds
duration(::Week) = :weeks

@doc """
    duration(::Dates.Period)

# Examples

```jldoctest
julia> Typstry.duration(Dates.Day(1))
:days

julia> Typstry.duration(Dates.Hour(1))
:hours
```
""" duration

"""
    enclose(f, io, x, left, right = reverse(left); kwargs...)

Call `f(io,\u00A0x;\u00A0kwargs...)` between printing `left` and `right`, respectfully.

# Examples

```jldoctest
julia> Typstry.enclose((io, i; x) -> print(io, i, x), stdout, 1, "\\\$ "; x = "x")
\$ 1x \$
```
"""
function enclose(f, io::IO, x, left::String, right::String = reverse(left); context...)
    print(io, left)
    f(io, x; context...)
    print(io, right)
end

"""
    escape(io, n)

Print `\\` to `io` `n` times.

# Examples

```jldoctest
julia> Typstry.escape(stdout, 2)
\\\\
```
"""
escape(io::IO, n::Int) = join(io, repeated('\\', n))

"""
    indent(tc)
"""
indent(tc) = " " ^ tab_size(tc)

"""
    format(::Union{MIME"application/pdf", MIME"image/png", MIME"image/svg+xml"})

Return the image format acronym corresponding to the given `MIME`.

# Examples

```jldoctest
julia> Typstry.format(MIME"application/pdf"())
"pdf"

julia> Typstry.format(MIME"image/png"())
"png"

julia> Typstry.format(MIME"image/svg+xml"())
"svg"
```
"""
format(::MIME"application/pdf") = "pdf"
format(::MIME"image/png") = "png"
format(::MIME"image/svg+xml") = "svg"

"""
    join_with(f, io, xs, delimeter; kwargs...)

Similar to `join`, except printing with `f(io, x; kwargs...)`.

# Examples

```jldoctest
julia> Typstry.join_with((io, i; x) -> print(io, -i, x), stdout, 1:4, ", "; x = "x")
-1x, -2x, -3x, -4x
```
"""
function join_with(f, io::IO, xs, delimeter; kwargs...)
    _xs = Stateful(xs)

    for x in _xs
        f(io, x; kwargs...)
        isempty(_xs) || print(io, delimeter)
    end
end

"""
    math_mode(f, io, tc, x; kwargs...)
"""
math_mode(f, io::IO, tc, x; kwargs...) = enclose(
    (io, x; kwargs...) -> f(io, tc, x; kwargs...), io, x, math_pad(tc); kwargs...
)

"""
    math_pad(tc)

Return `""`, `"\\\$"`, or `"\\\$ "` depending on the
[`block`](@ref Typstry.block) and [`mode`](@ref Typstry.mode) settings.
"""
function math_pad(tc)
    if mode(tc) == math ""
    else block(tc) ? "\$ " : "\$"
    end
end

"""
    merge_contexts!(tc, context)
"""
merge_contexts!(tc, context) = mergewith!((x, _) -> x, tc, context)

"""
    show_array(io, x)
"""
show_array(io::IO, x) = enclose(io, x, "(", ")") do _io, _x
    join_with(_io, _x, ", ") do __io, __x
        show_typst(__io, __x; parenthesize = false, mode = code)
    end
    if length(_x) == 1 print(_io, ',') end
end

"""
    show_parameters(io, tc, f, keys, final)
"""
function show_parameters(io::IO, tc, f, keys, final)
    pairs = map(key -> key => unwrap(tc, TypstString, key), filter(key -> haskey(tc, key), keys))

    println(io, f, '(')
    join_with(io, pairs, ",\n") do _io, (key, value)
        print(_io, indent(tc) ^ (depth(tc) + 1), key, ": ")
        # println()
        # @show value
        # show_typst(IOContext(stdout, :typst_context => value)
        # println()
        show_typst(_io, value)
    end

    if !isempty(pairs)
        final && print(io, ',')
        println(io)
    end
end

"""
    show_raw(f, io, tc, x, language)
"""
function show_raw(f, io::IO, tc, x, language)
    _backticks, _block = '`' ^ backticks(tc), block(tc)

    mode(tc) == math && print(io, "#")
    print(io, _backticks, language)

    if _block
        _indent, _depth = indent(tc), depth(tc)

        println(io)

        for line in eachsplit(sprint(f, x), '\n')
            println(io, _indent ^ (_depth + 1), line)
        end

        print(io, _indent ^ _depth)
    else enclose(f, io, x, " ")
    end

    print(io, _backticks)
end

"""
    typst_context(io)
"""
typst_context(io::IO) = unwrap(io, :typst_context, TypstContext())

function _unwrap(dt::DataType, key::Symbol, value)
    value isa dt ? value : throw(ContextError(dt, typeof(value), key))
end

unwrap(x, key::Symbol, default) = _unwrap(typeof(default), key, get(x, key, default))
function unwrap(x, type::Type, key)
    value = x[key]
    _unwrap(type, key, value)
end

@doc """
    unwrap(x, key::Symbol, default)
    unwrap(x, type::Type, key)
""" unwrap
