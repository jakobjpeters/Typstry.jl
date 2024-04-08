
# Internals

"""
    TypstText
"""
struct TypstText
    text::String
end

"""
    TypstString <: AbstractString
    TypstString(::TypstText)

See also [`TypstText`](@ref Typstry.TypstText)
"""
struct TypstString <: AbstractString
    text::String

    TypstString(text::TypstText) = new(text.text)
end

"""
    enclose(x, left, right = reverse(left))

Return `join((left, x, right))`.
"""
enclose(x, left, right = reverse(left)) = join((left, x, right))

"""
    pad_math(x, inline)

Return `enclose(x, inline ? "\\\$" : "\\\$ ")`.

See also [`enclose`](@ref Typstry.enclose)
"""
pad_math(x, inline) = enclose(x, inline ? "\$" : "\$ ")

_typstify(xs; settings...) = Iterators.map(x -> typstify(x; settings...), xs)

"""
    typstify(x; settings...)
"""
function typstify(x::AbstractChar; mode, settings...)
    s = repr(x)
    mode == markup ? s : enclose(s, "\"")
end
function typstify(x::AbstractMatrix; mode, inline, tab, settings...)
    s = "mat" * enclose(join(Iterators.map(row -> tab * join(
        Iterators.map(cell -> typstify(cell; mode = math, tab, inline, settings...), row)
    , ", "), eachrow(x)), ";\n"), "(\n", "\n)")
    mode == math ? s : pad_math(s, inline)
end
function typstify(x::AbstractString; mode, settings...)
    s = repr(x)
    mode == markup ? s : enclose(escape_string(s), "\"")
end
function typstify(x::Bool; mode, settings...)
    s = string(x)

    if mode == code s
    elseif mode == math enclose(x, "\"")
    else "#" * s
    end
end
typstify(x::Irrational; mode, settings...) = mode == code ? enclose(x, "\"") : string(x)
function typstify(x::Rational; mode, inline, settings...)
    n, d = _typstify([numerator(x), denominator(x)]; mode = math, settings...)
    s = "$n / $d"
    mode == markup ? pad_math(s, inline) : s
end
typstify(x::Union{AbstractFloat, Signed, Text}; settings...) = string(x)
function typstify(x::OrdinalRange{<:Integer, <:Integer}; mode, settings...)
    f, l, s = _typstify([first(x), last(x), step(x)]; mode = code, settings...)
    s = "range($f, $l, step: $s)"
    mode == code ? s : "#" * s
end
function typstify(x::AbstractVector; mode, inline, settings...)
    s = "vec" * enclose(join(Iterators.map(cell -> _typstify(cell; mode = math, settings...), x), ", "), "(", ")")
    mode == math ? s : pad_math(s, inline)
end
# typstify(x::Unsigned, mode) = mode == markup ? TypstString(x) :
# typstify(x::AbstractRange, mode) = typstify(collect(x), mode)

"""
    Mode
"""
@enum Mode code markup math

"""
    TypstString(x; mode = markup, inline = true, tab = " " ^ 4, settings...)

See also [`Mode`](@ref).
"""
TypstString(x; mode = markup, inline = true, tab = " " ^ 4, settings...) =
    TypstString(TypstText(typstify(x; mode, inline, tab, settings...)))

"""
    @typst_str(s)
    typst"s"

Construct a string with custom interpolation and without unescaping.
Backslashes `\\` and quotation marks `\"` must still be escaped.

The syntax for interpolation is a backslash `\\`,
followed by the [`Mode`](@ref) to [`typstify`](@ref) the interpolated value,
and finally a Julia expression enclosed in parentheses `(x)`.
The syntax `typst\"\\(x)\"` is equivalent to `typst\"\\markup(x)\"`.

!!! warning
    See also the performance tip to [avoid string interpolation for I/O]
    (https://docs.julialang.org/en/v1/manual/performance-tips/#Avoid-string-interpolation-for-I/O).

# Examples
```jldoctest
julia> x = 1;

julia> typst"\$1 / x\$"
typst"\\\$1 / x\\\$\"

julia> typst"\\(x) \\(x + 1)"
typst"1 2"

julia> typst"\\\\(x)"
typst"\\\\\\\\(x)"

julia> typst"\\ \\\\"
typst"\\\\ \\\\"
```
"""
macro typst_str(s)
    _s = Expr(:string)
    args = _s.args
    filename = string(__source__.file)
    previous = current = firstindex(s)

    while (regex_match = match(r"(?<!\\)\\((?:markup|math|code)|)\(", s, current)) !== nothing
        current = prevind(s, regex_match.offset)
        previous <= current && push!(args, s[previous:current])
        expr, current = parse(s, current + ncodeunits(regex_match.match); filename, greedy = false)
        previous = current
        mode = only(regex_match)
        push!(args, esc(:(TypstString($expr; mode = $(isempty(mode) ? :markup : Symbol(mode))))))
    end

    previous <= lastindex(s) && push!(args, s[previous:end])
    :(TypstString(TypstText($_s)))
end

# Interface

"""
    *(::TypstString, ::TypstString)
"""
x::TypstString * y::TypstString = TypstString(x.text * y.text)

"""
    show(::IO, ::TypstString)
"""
function show(io::IO, ts::TypstString)
    print(io, "typst")
    show(io, ts.text)
end

for f in (:iterate, :ncodeunits, :codeunit, :pointer, :IOBuffer)
    @eval begin
        "\t$($f)(::TypstString)"
        Base.$f(ts::TypstString) = $f(ts.text)
    end
end

for f in (:iterate, :isvalid, :codeunit)
    @eval begin
        "\t$($f)(::TypstString, ::Integer)"
        Base.$f(ts::TypstString, i::Integer) = $f(ts.text, i)
    end
end
