
# `Typstry`

"""
    Mode

An `Enum`erated type used to specify that the current
Typst context is in `code`, `markup`, or `math` mode.

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
    TypstString <: AbstractString
    TypstString(::Any, ::Pair{Symbol}...)

Convert the value to a Typst formatted string.

Optional Julia settings and Typst parameters are passed to
[`show(::IO,\u00A0::MIME"text/typst",\u00A0::Any)`](@ref)
in an `IOContext`.
See also [`show_typst`](@ref) for a list of supported types.

!!! info
    This type implements the `String` interface.
    However, the interface is unspecified which may result unexpected behavior.

# Examples
```jldoctest
julia> TypstString("a")
typst"\\\"a\\\""

julia> TypstString("a", :mode => code)
typst"\\\"\\\\\\"a\\\\\\"\\\""
```
"""
struct TypstString <: AbstractString
    text::String

    TypstString(x::T, settings...) where T = new(
        if T <: Union{TypstString, TypstText} x.text
        else
            buffer = IOBuffer()
            show(IOContext(buffer, settings...), MIME"text/typst"(), x)
            String(take!(buffer))
        end
    )
end

"""
    @typst_str(s)
    typst"s"

Construct a [`TypstString`](@ref).

Control characters are escaped,
except quotation marks and backslashes in the same manner as `@raw_str`.
`TypstString`s containing control characters may be created using [`typst_text`](@ref).
Values may be interpolated by calling the `TypstString` constructor,
except using a backslash instead of the type name.

!!! tip
    Use [`show(::IO,\u00A0::MIME"text/typst",\u00A0::Any)`](@ref) to print directly to an `IO`.

    See also the performance tip to [Avoid string interpolation for I/O]
    (https://docs.julialang.org/en/v1/manual/performance-tips/#Avoid-string-interpolation-for-I/O).

# Examples
```jldoctest
julia> x = 1;

julia> typst"\$\\(x) / \\(x + 1)\$"
typst"\$1 / 2\$"

julia> typst"\\(x // 2)"
typst"\$1 / 2\$"

julia> typst"\\(x // 2, :mode => math)"
typst"1 / 2"

julia> typst"\\\\(x)"
typst"\\\\(x)"
```
"""
macro typst_str(s)
    _s = Expr(:string)
    args = _s.args
    filename = string(__source__.file)
    previous = current = firstindex(s)
    last = lastindex(s)

    while (regex_match = match(r"(?<!\\)\\\(", s, current)) !== nothing
        current = prevind(s, regex_match.offset)
        start = current + 2
        previous <= current && push!(args, s[previous:current])
        current = static_parse(s, start; filename, greedy = false)[2]
        previous = current
        push!(args, esc(static_parse("TypstString" * s[start: current - 1]; filename)))
    end

    previous <= last && push!(args, s[previous:last])
    :(TypstString(TypstText($_s)))
end

# Internals

"""
    TypstText(::Any)

A wrapper used to construct a [`TypstString`](@ref) with `print`
instead of [`show(::IO,\u00A0::MIME"text/typst",\u00A0::Any)`](@ref).

# Examples
```jldoctest
julia> Typstry.TypstText("a")
Typstry.TypstText("a")

julia> Typstry.TypstText([1, 2, 3, 4])
Typstry.TypstText("[1, 2, 3, 4]")
```
"""
struct TypstText
    text::String

    TypstText(x) = new(string(x))
end

"""
    examples

A constant `Vector` of Julia values and their corresponding `Type`s implemented for
[`show(::IO,\u00A0::MIME"text/plain",\u00A0::Any)`](@ref).

# Examples
```jldoctest
julia> Typstry.examples
16-element Vector{Pair{Any, Type}}:
                                       'a' => AbstractChar
                                       1.2 => AbstractFloat
 Any[true 1; 1.0 Any[true 1; 1.0 nothing]] => AbstractMatrix
                                       "a" => AbstractString
                            Any[true, [1]] => AbstractVector
                                      true => Bool
                                   1 + 2im => Complex
                                         π => Irrational
                                   nothing => Nothing
                                     0:2:6 => OrdinalRange{<:Integer, <:Integer}
                                      1//2 => Rational
                                  r"[a-z]" => Regex
                                         1 => Signed
                                     0:2:6 => StepRangeLen{<:Integer, <:Integer, <:Integer}
                                     ["a"] => Text
                            typst"[\\\"a\\\"]" => TypstString
```
"""
const examples = [
    'a' => AbstractChar,
    1.2 => AbstractFloat,
    [true 1; 1.0 [Any[true 1; 1.0 nothing]]] => AbstractMatrix,
    "a" => AbstractString,
    [true, [1]] => AbstractVector,
    true => Bool,
    1 + 2im => Complex,
    π => Irrational,
    nothing => Nothing,
    0:2:6 => OrdinalRange{<:Integer, <:Integer},
    1 // 2 => Rational,
    r"[a-z]" => Regex,
    1 => Signed,
    StepRangeLen(0, 2, 4) => StepRangeLen{<:Integer, <:Integer, <:Integer},
    text"[\"a\"]" => Text,
    @typst_str("[\"a\"]") => TypstString
]

"""
    preamble

# Examples
```jldoctest
julia> print(Typstry.preamble)
#set page(margin: 1em, height: auto, width: auto, fill: white)
#set text(16pt, font: "JuliaMono")
```
"""
const preamble = """
#set page(margin: 1em, height: auto, width: auto, fill: white)
#set text(16pt, font: "JuliaMono")
"""

"""
    settings

A constant `NamedTuple` containing the default `IOContext` settings
for [`show(::IO,\u00A0::MIME"text/typst",\u00A0::Any)`](@ref).

# Examples
```jldoctest
julia> Typstry.settings
(mode = markup, inline = true, indent = "    ", depth = 0)
```
"""
const settings = (
    mode = markup,
    inline = true,
    indent = "    ",
    depth = 0
)

"""
    typst_mime

# Examples
```jldoctest
julia> Typstry.typst_mime
MIME type text/typst
```
"""
const typst_mime = MIME"text/typst"()

"""
    code_mode(io)

Print the number sign, unless `mode(io) == code`.

# See also [`Mode`](@ref) and [`mode`](@ref Typstry.mode).

# Examples
```jldoctest
julia> Typstry.code_mode(IOContext(stdout, :mode => code))

julia> Typstry.code_mode(IOContext(stdout, :mode => markup))
#

julia> Typstry.code_mode(IOContext(stdout, :mode => math))
#
```
"""
code_mode(io) = if mode(io) != code print(io, "#") end

"""
    depth(io)

Return `io[:depth]::Int`.

# Examples
```jldoctest
julia> Typstry.depth(IOContext(stdout, :depth => 0))
0
```
"""
depth(io) = io[:depth]::Int

"""
    enclose(f, io, x, left, right = reverse(left); settings...)

Call `f(io,\u00A0x;\u00A0settings...)` between printing `left` and `right`, respectfully.

# Examples
```jldoctest
julia> Typstry.enclose((io, i; x) -> print(io, i, x), stdout, 1, "\\\$ "; x = "x")
\$ 1x \$
```
"""
function enclose(f, io, x, left, right = reverse(left); settings...)
    print(io, left)
    f(io, x; settings...)
    print(io, right)
end

"""
    format(::Union{MIME"image/png", MIME"image/svg+xml})

# Examples
```jldoctest
julia> Typstry.format(MIME"image/png"())
"png"

julia> Typstry.format(MIME"image/svg+xml"())
"svg"
```
"""
format(::MIME"image/png") = "png"
format(::MIME"image/svg+xml") = "svg"

"""
    indent(io)

Return `io[:indent]::String`.

# Examples
```jldoctest
julia> Typstry.indent(IOContext(stdout, :indent => ' ' ^ 4))
"    "
```
"""
indent(io) = io[:indent]::String

"""
    inline(io)

Return `io[:inline]::Bool`.

# Examples
```jldoctest
julia> Typstry.inline(IOContext(stdout, :inline => true))
true
```
"""
inline(io) = io[:inline]::Bool

"""
    join_with(f, io, xs, delimeter; settings...)

Similar to `join`, except printing with `f(io, x; settings...)`.

# Examples
```jldoctest
julia> Typstry.join_with((io, i; x) -> print(io, -i, x), stdout, 1:4, ", "; x = "x")
-1x, -2x, -3x, -4x
```
"""
function join_with(f, io, xs, delimeter; settings...)
    _xs = Stateful(xs)

    for x in _xs
        f(io, x; settings...)
        isempty(_xs) || print(io, delimeter)
    end
end

"""
    math_pad(io, x)

Return `""`, `"\\\$"`, or `"\\\$ "` depending on the
[`mode`](@ref Typstry.mode) and [`inline`](@ref Typstry.inline) settings.

# Examples
```jldoctest
julia> Typstry.math_pad(IOContext(stdout, :mode => math))
""

julia> Typstry.math_pad(IOContext(stdout, :mode => markup, :inline => true))
"\\\$"

julia> Typstry.math_pad(IOContext(stdout, :mode => markup, :inline => false))
"\\\$ "
```
"""
math_pad(io) =
    if mode(io) == math ""
    else inline(io) ? "\$" : "\$ "
    end

"""
    mode(io)

Return `io[:mode]::Mode`.

See also [`Mode`](@ref).

# Examples
```jldoctest
julia> Typstry.mode(IOContext(stdout, :mode => code))
code::Mode = 0
```
"""
mode(io) = io[:mode]::Mode

"""
    print_parameters(io, f, keys)

Print the name of a Typst function, an opening parenthesis,
the parameters to a Typst function, and a newline.

Skip `keys` that are not in the `IOContext`.

# Examples
```jldoctest
julia> Typstry.print_parameters(
           IOContext(stdout, :delim => "\\\"(\\\""),
       "vec", [:delim, :gap])
vec(delim: "(",
```
"""
function print_parameters(io, f, keys)
    print(io, f, "(")

    for key in keys
        value = get(io, key, "")::String
        isempty(value) || print(io, key, ": ", value, ", ")
    end

    println(io)
end

"""
    print_quoted(io, s)

Print the string [`enclose`](@ref Typstry.enclose)d
in quotes and with interior quotes escaped.

# Examples
```jldoctest
julia> Typstry.print_quoted(stdout, TypstString("a"))
"\\\"a\\\""
```
"""
print_quoted(io, s) = enclose(escape_raw_string, io, s, "\"")

"""
    show_image(io, m, t)
"""
function show_image(io, m, t)
    name = tempname()
    _name = name * "." * format(m)

    open(file -> print(file, preamble, t), name; write = true)
    success(run(ignorestatus(TypstCommand([
        "compile", "--font-path=" * julia_mono, name, _name
    ])))) && print(io, read(_name, String))
end

"""
    static_parse(args...; filename, kwargs...)

Call `Meta.parse` with the `filename` if it is supported
in the current Julia version (at least v1.10).
"""
static_parse(args...; filename, kwargs...) =
    @static VERSION < v"1.10" ? parse(args...; kwargs...) : parse(args...; filename, kwargs...)

# `Typstry`

"""
    show_typst(io, x)

Print to Typst format using required settings and parameters in the `IOContext`.

Settings are used in Julia to format the [`TypstString`](@ref) and can be any type.
Parameters are passed to a function in the Typst source file and must be a `String`
with the same name as in Typst, except that dashes are replaced with underscores.

For more information on parameters and settings,
see also [`show(::IO,\u00A0::MIME"text/typst",\u00A0::Any)`](@ref)
and the [Typst Documentation](https://typst.app/docs/),
respectively.

For more information on printing and rendering, see also [Examples](@ref).

!!! tip
    Implement this function for new types to specify their Typst formatting.

!!! warning
    This function's methods are incomplete.
    Please file an issue or create a pull-request for missing methods.

| Type                                                      | Settings                                | Parameters                                              |
|:----------------------------------------------------------|:----------------------------------------|:--------------------------------------------------------|
| `AbstractChar`                                            | `:mode`                                 |                                                         |
| `AbstractFloat`                                           |                                         |                                                         |
| `AbstractMatrix`                                          | `:mode`, `:inline`, `:indent`, `:depth` | `:delim`, `:augment`, `:gap`, `:row_gap`, `:column_gap` |
| `AbstractString`                                          | `:mode`                                 |                                                         |
| `AbstractVector`                                          | `:mode`, `:inline`, `:indent`, `:depth` | `:delim`, `:gap`                                        |
| `Bool`                                                    | `:mode`                                 |                                                         |
| `Complex`                                                 | `:mode`, `:inline`                      |                                                         |
| `Irrational`                                              | `:mode`                                 |                                                         |
| `Nothing`                                                 | `:mode`                                 |                                                         |
| `OrdinalRange{<:Integer,\u00A0<:Integer}`                 | `:mode`                                 |                                                         |
| `Rational`                                                | `:mode`, `:inline`                      |                                                         |
| `Regex`                                                   | `:mode`                                 |                                                         |
| `Signed`                                                  |                                         |                                                         |
| `StepRangeLen{<:Integer,\u00A0<:Integer,\u00A0<:Integer}` | `:mode`                                 |                                                         |
| `Text`                                                    | `:mode`                                 |                                                         |
| `TypstString`                                             |                                         |                                                         |

# Examples
```jldoctest
julia> show_typst(stdout, 1)
1

julia> show_typst(IOContext(stdout, :mode => code), "a")
"\\\"a\\\""
```
"""
show_typst(io, x::AbstractChar) = mode(io) == code ?
    enclose(show, io, x, "\"") :
    show(io, x)
show_typst(io, x::AbstractMatrix) =
    enclose((io, x; indent, depth) -> begin
        _depth = depth + 1

        print_parameters(io, "mat", [:delim, :augment, :gap, :row_gap, :column_gap])
        join_with((io, x; indent) -> begin
            print(io, indent ^ _depth)
            join_with((io, x) -> show_typst(io, x), io, x, ", ")
        end, IOContext(io, :mode => math, :depth => _depth), eachrow(x), ";\n"; indent)
        print(io, "\n", indent ^ depth, ")")
    end, io, x, math_pad(io); indent = indent(io), depth = depth(io))
show_typst(io, x::AbstractString) = mode(io) == markup ?
    enclose(escape_string, io, x, "\"") :
    enclose(escape_string, io, escape_string(x), "\"\\\"", "\\\"\"") # TODO: remove string allocation
show_typst(io, x::AbstractVector) = enclose(IOContext(io, :mode => math), x, math_pad(io)) do io, x
    _depth, _indent = depth(io), indent(io)
    __depth = _depth + 1

    print_parameters(io, "vec", [:delim, :gap])
    print(io, _indent ^ __depth)
    join_with(show_typst, IOContext(io, :depth => __depth), x, ", "),
    print(io, "\n", _indent ^ _depth, ")")
end
function show_typst(io, x::Bool)
    _mode = mode(io)

    if _mode == math enclose(print, io, x, "\"")
    elseif _mode == markup print(io, "#", x)
    else print(io, x)
    end
end
show_typst(io, x::Complex) =
    enclose((io, x) -> print(io, real(x), " + ", imag(x), "i"), io, x, math_pad(io))
show_typst(io, x::Irrational) =
    mode(io) == code ? show_typst(io, Float64(x)) : print(io, x)
show_typst(io, ::Nothing) = if mode(io) != markup print(io, "\"\"") end
function show_typst(io, x::Rational)
    _mode = mode(io)
    f = (io, x) -> begin
        show_typst(io, numerator(x))
        print(io, " / ")
        show_typst(io, denominator(x))
    end

    if _mode == code enclose(f, IOContext(io, :mode => code), x, "(", ")")
    elseif _mode == markup enclose(f, IOContext(io, :mode => math), x, inline(io) ? "\$" : "\$ ")
    else f(io, x)
    end
end
function show_typst(io, x::Regex)
    code_mode(io)
    enclose(io, x, "regex(", ")") do io, x
        buffer = IOBuffer()

        print(buffer, x)
        seek(buffer, 1)

        for c in readeach(buffer, Char)
            print(io, c)
        end
    end
end
function show_typst(io, x::Text)
    code_mode(io)
    print_quoted(io, repr(x))
end
show_typst(io, x::Union{AbstractFloat, Signed, TypstString}) = print(io, x)
function show_typst(io, x::Union{OrdinalRange{<:Integer, <:Integer}, StepRangeLen{<:Integer, <:Integer, <:Integer}})
    code_mode(io)

    enclose((io, x) -> begin
        show_typst(io, first(x))
        enclose(show_typst, io, last(x) + 1, ", ", ", step: ")
        show_typst(io, step(x))
    end, IOContext(io, :mode => code), x, "range(", ")")
end
#=
AbstractDict
AbstractIrrational
Symbol
Unsigned
Enum
=#

"""
    typst_text(::Any)

Construct a [`TypstString`](@ref) using `print` instead of
[`show(::IO,\u00A0::MIME"text/typst",\u00A0::Any)`](@ref).

!!! tip
    Use `typst_text` to print text to a `TypstString`.
    Use `Text` to render the text in a Typst document.

!!! warning
    Unescaped control characters in `TypstString`s may
    break formatting in some environments such as the REPL.

# Examples
```jldoctest
julia> typst_text("a")
typst"a"

julia> typst_text([1, 2, 3, 4])
typst"[1, 2, 3, 4]"
```
"""
typst_text(x) = TypstString(TypstText(x))

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

# Examples
```jldoctest
julia> ncodeunits(typst"a")
1
```
"""
ncodeunits(ts::TypstString) = ncodeunits(ts.text)

"""
    pointer(::TypstString)
"""
pointer(ts::TypstString) = pointer(ts.text)

"""
    show(::IO, ::MIME"text/typst", ::Any)

Print to Typst format.

Provides default settings for [`show_typst`](@ref)
which may be specified in an `IOContext`.
Custom default settings may be provided by implementing new methods.

| Setting   | Default                  | Type           | Description                                                                                                                                                             |
|:----------|:-------------------------|:---------------|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `:mode`   | `markup`                 | [`Mode`](@ref) | The current Typst context where `code` follows the number sign, `markup` is at the top-level and enclosed in square brackets, and `math` is enclosed in dollar signs.   |
| `:inline` | `true`                   | `Bool`         | When `:mode => math`, specifies whether the enclosing dollar signs are padded with a space to render the element inline or its own block.                               |
| `:indent` | `'\u00A0'\u00A0^\u00A04` | `String`       | The string used for horizontal spacing by some elements with multi-line Typst formatting.                                                                               |
| `:depth`  | `0`                      | `Int`          | The current level of nesting within container types to specify the degree of indentation.                                                                               |

# Examples
```jldoctest
julia> show(stdout, "text/typst", "a")
"a"

julia> show(IOContext(stdout, :mode => code), "text/typst", "a")
"\\\"a\\\""
```
"""
show(io::IO, ::MIME"text/typst", x) =
    show_typst(IOContext(io, map(key -> key => get(io, key, settings[key]), keys(settings))...), x)

"""
    show(::IO, ::Union{MIME"image/png", MIME"image/svg+xml"}, ::TypstString)

Print to a Portable Network Graphics (PNG) or Scalable Vector Graphics (SVG) format.

Environments such as Pluto.jl notebooks use this
function to render [`TypstString`](@ref)s to a document.
The corresponding Typst source file begins with this preamble:

```typst
$preamble
```

See also [`julia_mono`](@ref).
"""
show(io::IO, m::Union{MIME"image/png", MIME"image/svg+xml"}, t::TypstString) =
    show_image(io, m, t)

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
    print_quoted(io, ts.text)
end
