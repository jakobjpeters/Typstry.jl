
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
("duration", (:days,), (TypstText{String}("1"),))
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
format(::MIME"image/gif") = "gif"
format(::MIME"image/jpg") = "jpg"
format(::MIME"image/png") = "png"
format(::MIME"image/svg+xml") = "svg"

"""
    indent(tc)
"""
indent(tc) = " " ^ tab_size(tc)

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
    show_array(io, x)
"""
show_array(io::IO, x) = enclose(io, x, "(", ")") do _io, _x
    join_with(_io, _x, ", ") do __io, __x
        show_typst(__io, __x; parenthesize = false, mode = code)
    end
    if length(_x) == 1 print(_io, ',') end
end

function show_image(io::IO, m::Union{
    MIME"image/gif", MIME"image/svg+xml", MIME"image/png", MIME"image/jpg"
}, value)
    tc = typst_context(io, value)
    path = tempname() * '.' * format(m)

    open(path; write = true) do file
        show(IOContext(file, IOContext(io, :typst_context => tc)), m, value)
    end

    code_mode(io, tc)
    show_parameters(io, tc, :format, [:format, :width, :height, :alt, :fit, :scaling, :icc], path)
    print(io, ')')
end

"""
    show_parameters(io, tc, f, keys, final)
"""
function show_parameters(io::IO, tc, f, keys, final)
    pairs = map(key -> key => unwrap(tc, TypstString, key), filter(key -> haskey(tc, key), keys))

    println(io, f, '(')
    join_with(io, pairs, ",\n") do _io, (key, value)
        print(_io, indent(tc) ^ (depth(tc) + 1), key, ": ")
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

function show_render(io::IO, m::Union{
    MIME"application/pdf", MIME"image/png", MIME"image/svg+xml"
}, x)
    input = tempname()
    output = input * '.' * format(m)

    render(typst_context(io), x; input, output, open = false, ignorestatus = false)
    write(io, read(output))

    nothing
end
