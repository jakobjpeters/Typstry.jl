
"""
    TypstString <: AbstractString
    TypstString(::TypstContext, ::Any)
    TypstString(::Any; context...)

Format the value as a Typst formatted string.

The [`TypstContext`](@ref) is passed to
`show(::IO,\u00A0::MIME"text/typst",\u00A0::Any)`
as the `IOContext` parameter `:typst_context`.

# Interface

This type implements the `String` interface.
However, the interface is undocumented, which may result in unexpected behavior.

- `IOBuffer(::TypstString)`
- `codeunit(::TypstString,\u00A0::Integer)`
- `codeunit(::TypstString)`
- `isvalid(::TypstString,\u00A0::Integer)`
- `iterate(::TypstString,\u00A0::Integer)`
- `iterate(::TypstString)`
- `ncodeunits(::TypstString)`
- `pointer(::TypstString)`
- `repr(::MIME,\u00A0::TypstString)`
    - This method patches incorrect output from the assumption in `repr` that
        the parameter is already in the requested `MIME` type when the `MIME`
        type satisfies `istextmime` and the parameter is an `AbstractString`.
- `show(::IO,\u00A0::Union{MIME"application/pdf",\u00A0MIME"image/png",\u00A0MIME"image/svg+xml"},\u00A0::TypstString)`
- `show(::IO,\u00A0::TypstString)`
    - Print in [`@typst_str`](@ref) format if each character satisfies `isprint`.
        Otherwise, print in [`TypstString`](@ref) format.

# Examples

```jldoctest
julia> TypstString(1)
typst"\$1\$"

julia> TypstString(TypstContext(; mode = code), π)
typst"3.141592653589793"

julia> TypstString(1 + 2im; mode = math)
typst"(1 + 2i)"
```
"""
struct TypstString <: AbstractString
    text::String

    TypstString(tc::TypstContext, t::Union{Typst, TypstString, TypstText}) =
        new(sprint(show, typst_mime, t; context = :typst_context => tc))
end

TypstString(tc::TypstContext, x) = TypstString(tc, Typst(x))
TypstString(x; context...) = TypstString(TypstContext(; context...), x)

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

IOBuffer(ts::TypstString) = IOBuffer(ts.text)

codeunit(ts::TypstString) = codeunit(ts.text)
codeunit(ts::TypstString, i::Integer) = codeunit(ts.text, i)

isvalid(ts::TypstString, i::Integer) = isvalid(ts.text, i::Integer)

iterate(ts::TypstString) = iterate(ts.text)
iterate(ts::TypstString, i::Integer) = iterate(ts.text, i)

ncodeunits(ts::TypstString) = ncodeunits(ts.text)

pointer(ts::TypstString) = pointer(ts.text)

repr(m::MIME, ts::TypstString; context = nothing) = sprint(show, m, ts; context)

function show(io::IO, ts::TypstString)
    text = ts.text

    if all(isprint, text)
        escapes = 0

        print(io, "typst\"")

        for c in text
            if c == '\\' escapes += 1
            else
                if c == '\"' escape(io, escapes + 1)
                elseif c == '(' escape(io, escapes)
                end

                escapes = 0
            end

            print(io, c)
        end

        escape(io, escapes)
        print(io, "\"")
    else
        print(io, TypstString, "(", TypstText, "(")
        show(io, text)
        print(io, "))")
    end
end
