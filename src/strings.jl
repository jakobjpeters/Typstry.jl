
# Internals

"""
    enclose(x, left, right = reverse(left))

Return `left * x * right`.
"""
enclose(x, left, right = reverse(left)) = TypstString(left * x * right)

# Interface

"""
    TypstString <: AbstractString
    TypstString(x)
"""
struct TypstString <: AbstractString
    text::String

    TypstString(x) = new(string(x))
end

"""
    Mode
"""
@enum Mode markup math code

"""
    @typst_str(s)
    typst"s"

Construct a string with custom interpolation and without unescaping.
Backslashes (`\\`) and quotation marks (`\"`) must still be escaped.

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
        push!(args, esc(:(typstify($expr, $(isempty(mode) ? :markup : Symbol(mode))))))
    end

    previous <= lastindex(s) && push!(args, s[previous:end])
    :(TypstString($_s))
end

"""
    typstify(x, mode = markup)

See also [`Mode`](@ref).
"""
typstify(x::Union{Text, Signed, AbstractFloat}, mode) = TypstString(x)

typstify(x::Union{AbstractChar, AbstractString}, mode) =
    mode == markup ? TypstString(repr(x)) : enclose(x, "\"\\\"")

typstify(x::Bool, mode) = mode == math ? enclose(x, "\"") : TypstString(x)

# typstify(x::Unsigned, mode) = mode == markup ? TypstString(x) :

typstify(x::Irrational, mode) = mode == code ? enclose(x, "\"") : TypstString(x)

typstify(x::Rational, mode) = mode == markup ?
    enclose(typstify(x, math), "\$") :
    TypstString("$(numerator(x)) / $(denominator(x))")

function typstify(x::AbstractMatrix, mode)
    y = enclose(join(Iterators.map(row -> "    " * join(Iterators.map(typstify, row), ", "), eachrow(x)), ";\n"), "\n")
    typst"$ mat(\(Text(y))) $"
end

typstify(x::UnitRange{<:Integer}, mode) = typst"$ range(\(first(x)), \(last(x)), step: \(step(x))) $"

# typstify(x::TypstString, mode = markup) = x
typstify(x) = typstify(x, markup)

# Interface

"""
    show(::IO, ::TypstString)
"""
function show(io::IO, ts::TypstString)
    print(io, "typst")
    show(io, ts.text)
end

for f in (:iterate, :ncodeunits, :codeunit, :pointer, :IOBuffer)
    @eval begin
        """$($f)(::TypstString)"""
        Base.$f(ts::TypstString) = $f(ts.text)
    end
end

for f in (:iterate, :isvalid, :codeunit)
    @eval begin
        """$($f)(::TypstString, ::Integer)"""
        Base.$f(ts::TypstString, i::Integer) = $f(ts.text, i)
    end
end
