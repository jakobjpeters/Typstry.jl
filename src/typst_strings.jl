
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

    TypstString(t::Union{Typst, TypstString, TypstText}; context...) =
        new(sprint(show, typst_mime, t; context = (context...,)))
end

TypstString(x; context...) = TypstString(Typst(x); context...)

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
    iterate(::TypstString)
    iterate(::TypstString, ::Integer)

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
