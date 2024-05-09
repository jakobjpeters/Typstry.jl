
# `Typstry`

"""
    Mode

An `Enum`erated type to indicate whether the current context
is in `code`, `markup`, or `math` mode.

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
    TypstString(x, ::Pair{Symbol}...)

Construct a string using [`show(::IO,\u00A0::MIME"text/typst",\u00A0::Any)`](@ref).

!!!
    This type implements the `String` interface.
    However, the interface is unspecified which may result unexpected behavior.

# Examples
```jldoctest
julia> TypstString(TypstText("a"))
typst"a"

julia> TypstString("a")
typst"\\\"a\\\""

julia> TypstString("a", :mode => code)
typst"\\\"\\\\\\"a\\\\\\"\\\""
```
"""
struct TypstString <: AbstractString
    text::String

    TypstString(x, settings...) = new(
        if x isa TypstText x.text
        else
            buffer = IOBuffer()
            show(IOContext(buffer, settings...), MIME"text/typst"(), x)
            String(take!(buffer))
        end
    )
end

"""
    TypstText(::Any)

A wrapper to construct a [`TypstString`](@ref) using `print` instead of
[`show(::IO,\u00A0::MIME"text/typst",\u00A0::Any)`](@ref).

!!! info
    Use `TypstText` to insert text into a `TypstString`
    and by extension a Typst source file.
    Use `Text` to directly insert text into a Typst document.

    Note that unescaped control characters, such as `"\\n"`,
    in `TypstString`s are not escaped when being printed.
    This may break formatting in some environments such as the REPL.

# Examples
```jldoctest
julia> TypstText("a")
TypstText("a")

julia> TypstText(1)
TypstText("1")
```
"""
struct TypstText
    text::String

    TypstText(x) = new(string(x))
end

"""
    @typst_str(s)
    typst"s"

Construct a [`TypstString`](@ref).

Values can be interpolated by calling the `TypstString` constructor,
except with a backslash `"\\\\"` instead of the type name.

!!! tip
    Use [`show(::IO,\u00A0::MIME"text/typst",\u00A0::Any)`](@ref) to print directly to an `IO`.

    See also the performance tip to [avoid string interpolation for I/O]
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

"""
    show_typst(io, x)

Settings are used in Julia to format the [`TypstString`](@ref) and can be any type.
Parameters are passed to a Typst function and must be a `String` with the same name
as in Typst, except that dashes `"-"` are replaced with underscores `"_"`.

| Type                                      | Settings                                | Parameters                                              |
|:------------------------------------------|:----------------------------------------|:--------------------------------------------------------|
| `AbstractChar`                            | `:mode`                                 |                                                         |
| `AbstractFloat`                           |                                         |                                                         |
| `AbstractMatrix`                          | `:mode`, `:inline`, `:indent`, `:depth` | `:delim`, `:augment`, `:gap`, `:row_gap`, `:column_gap` |
| `AbstractString`                          | `:mode`                                 |                                                         |
| `AbstractVector`                          | `:mode`, `:inline`, `:indent`, `:depth` | `:delim`, `:gap`                                        |
| `Bool`                                    | `:mode`                                 |                                                         |
| `Complex`                                 | `:mode`, `:inline`                      |                                                         |
| `Irrational`                              | `:mode`                                 |                                                         |
| `Nothing`                                 | `:mode`                                 |                                                         |
| `OrdinalRange{<:Integer,\u00A0<:Integer}` | `:mode`                                 |                                                         |
| `Rational`                                | `:mode`, `:inline`                      |                                                         |
| `Regex`                                   | `:mode`                                 |                                                         |
| `Signed`                                  |                                         |                                                         |
| `Text`                                    | `:mode`                                 |                                                         |
| `TypstText`                               |                                         |                                                         |

!!! warning
    This function's methods are incomplete.
    Please file an issue or create a pull-request for missing methods.

# Examples
```jldoctest
julia> show_typst(stdout, TypstText("a"))
a

julia> show_typst(IOContext(stdout, :mode => markup), "a")
"a"
```
"""
show_typst(io, x::AbstractChar) =
    enclose(show, io, x, mode(io) == code ? "\"" : "")
show_typst(io, x::AbstractFloat) = print(io, x)
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
show_typst(io, x::AbstractString) = enclose(io, x, "\"") do io, x
    s = mode(io) == markup ? "" : "\\\""
    enclose(io, x, s, s) do io, x
        for c in x
            c == '"' && print(io, "\\\\\\")
            print(io, c)
        end
    end
end
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
    enclose((io, x) -> print(io, sprint(print, x)[begin:end - 1]), io, x, math_pad(io))
show_typst(io, x::Irrational) =
    mode(io) == code ? show_typst(io, Float64(x)) : print(io, x)
show_typst(io, ::Nothing) = if mode(io) != markup print(io, "\"\"") end
function show_typst(io, x::OrdinalRange{<:Integer, <:Integer})
    code_mode(io)

    enclose((io, x) -> begin
        show_typst(io, first(x))
        print(io, ", ")
        show_typst(io, last(x) + 1)
        print(io, ", step: ")
        show_typst(io, step(x))
    end, IOContext(io, :mode => code), x, "range(", ")")
end
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
    enclose((io, x) -> print(io, sprint(print, x)[begin + 1:end]), io, x, "regex(", ")")
end
show_typst(io, x::Signed) = print(io, x)
function show_typst(io, x::Text)
    code_mode(io)
    escape_quote(io, repr(x))
end
show_typst(io, x::TypstText) = print(io, x.text)
#=
AbstractDict
AbstractIrrational
AbstractRange
Symbol
Unsigned
Enum
=#

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
    show(::IO, ::MIME"text/typst", x)

Print `x` in Typst format.

Provides default settings for [`show_typst`](@ref)
which may be specified in an `IOContext`.
Custom default settings may be given by implementing new methods.

| Setting   | Default                  | Type           | Description                                                                                                                                                                         |
|:----------|:-------------------------|:---------------|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `:mode`   | `markup`                 | [`Mode`](@ref) | The current Typst context where `code` follows the number sign `#`, `markup` is at the top-level and enclosed in square brackets `[]`, and `math` is enclosed in dollar signs `\$`. |
| `:inline` | `true`                   | `Bool`         | When `mode = math`, specifies whether the enclosing dollar signs `\$` are padded with a space to render the element inline or its own block.                                        |
| `:indent` | `'\u00A0'\u00A0^\u00A04` | `String`       | The string used for horizontal spacing by some elements with multi-line Typst code.                                                                                                 |
| `:depth`  | `0`                      | `Int`          | The current level of nesting within container types to specify the degree of indentation.                                                                                           |

# Examples
```jldoctest
julia> show(stdout, "text/typst", TypstText("a"))
a

julia> show(stdout, "text/typst", "a")
"a"

julia> show(IOContext(stdout, :mode => code), "text/typst", "a")
"\\\"a\\\""
```
"""
show(io::IO, ::MIME"text/typst", x) =
    show_typst(IOContext(io, map(key -> key => get(io, key, settings[key]), keys(settings))...), x)

"""
    show(::IO, ::TypstString)

# Examples
```jldoctest
julia> show(stdout, typst"a")
typst"a"
```
"""
function show(io::IO, ts::TypstString)
    print(io, "typst")
    escape_quote(io, ts.text)
end

# Internals

"""
    examples

A constant `Vector{Pair{Any, Type}}` where the first element is a value
and the second element is the (potentially abstract) type corresponding
to its [`show(::IO,\u00A0::MIME"text/plain",\u00A0::Any)`](@ref) method.
"""
const examples = [
    'a' => AbstractChar,
    1.2 => AbstractFloat,
    [true 1; 1.0 [[true 1; 1.0 nothing]]] => AbstractMatrix,
    @typst_str("a") => AbstractString,
    [true, [1]] => AbstractVector,
    true => Bool,
    1 + 2im => Complex,
    π => Irrational,
    nothing => Nothing,
    1:4 => OrdinalRange{<:Integer, <:Integer},
    1 // 2 => Rational,
    r"[a-z]" => Regex,
    1 => Signed,
    text"[\"a\"]" => Text,
    TypstText("[\"a\"]") => TypstText
]

"""
    settings

A constant `NamedTuple` containing the default `IOContext` settings
for [`show(::IO,\u00A0::MIME"text/typst",\u00A0::Any)`](@ref).
"""
const settings = (
    mode = markup,
    inline = true,
    indent = "    ",
    depth = 0
)

"""
    typst_mime

A constant equal to `MIME"text/typst"()`.

# Examples
```jldoctest
julia> Typstry.typst_mime
MIME type text/typst
```
"""
const typst_mime = MIME"text/typst"()

"""
    code_mode(io)

Print the number sign `#` unless `mode(io) == code`.

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

Return `io[:depth]::Int`

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
    escape_quote(io, s)

Print the string, with quotes `\\` escaped.

# Examples
```jldoctest
julia> Typstry.escape_quote(stdout, TypstString("a"))
"\\\"a\\\""
```
"""
escape_quote(io, s) = enclose(escape_raw_string, io, s, "\"")

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

See also [`Mode`].

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
    static_parse(args...; filename, kwargs...)

Call `Meta.parse` with the `filename` if it is supported
in the current Julia version (at least v1.10).
"""
static_parse(args...; filename, kwargs...) =
    @static VERSION < v"1.10" ? parse(args...; kwargs...) : parse(args...; filename, kwargs...)
