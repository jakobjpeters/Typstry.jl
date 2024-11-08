
"""
    typst_mime

Equivalent to `MIME"text/typst"()`.

# Examples

```jldoctest
julia> Typstry.typst_mime
MIME type text/typst
```
"""
const typst_mime = MIME"text/typst"()

"""
    escape(io, n)

Print `\\` to `io` `n` times.

# Examples

```jldoctest
julia> Typstry.escape(stdout, 2)
\\\\
```
"""
escape(io, n) =
    for _ in 1:n
        print(io, '\\')
    end

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
- `codeunit(::TypstString, ::Integer)`
- `codeunit(::TypstString)`
- `isvalid(::TypstString, ::Integer)`
- `iterate(::TypstString, ::Integer)`
- `iterate(::TypstString)`
- `ncodeunits(::TypstString)`
- `pointer(::TypstString)`
- `repr(::MIME, ::TypstString)`
    - This method patches incorrect output from the assumption in `repr` that
        the parameter is already in the requested `MIME` type when the `MIME`
        type satisfies `istextmime` and the parameter is an `AbstractString`.
- `show(::IO, ::TypstString)`
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
