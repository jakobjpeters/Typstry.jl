
# Internals

"""
    code_mode(io)
"""
code_mode(io) = mode(io) == code || print(io, "#")

"""
    escape_quote(io, s)
"""
escape_quote(io, s) = enclose(io, s, "\"") do io, s
    for c in s
        c == '"' && print(io, "\\")
        print(io, c)
    end
end

"""
    typst_mime, Math
"""
const typst_mime = MIME"text/typst"()

"""
    TypstText, indent_width, string_with_env

Wrap a `String` to construct a [`TypstString`](@ref) instead of dispatching to [`show`](@ref).
"""
struct TypstText
    text::String

    TypstText(x) = new(string(x))
end

"""
    join_with(f, io, xs, delimeter; settings...)
"""
function join_with(f, io, xs, delimeter; settings...)
    _xs = Stateful(xs)

    for x in _xs
        f(io, x; settings...)
        isempty(_xs) || print(io, delimeter)
    end
end

"""
    enclose(f, io, x, left, right = reverse(left); settings...)
"""
function enclose(f, io, x, left, right = reverse(left); settings...)
    print(io, left)
    f(io, x; settings...)
    print(io, right)
end

"""
    math_pad(io, x, inline)
"""
math_pad(io) =
    if mode(io) == math ""
    else inline(io) ? "\$" : "\$ "
    end

"""
    TypstString <: AbstractString
    TypstString(x, ::Pair{Symbol}...)

Construct a string from [`show`](@ref) with `MIME"text/typst"`.
"""
struct TypstString <: AbstractString
    text::String

    TypstString(text::TypstText) = new(text.text)
end

function TypstString(x, settings...)
    buffer = IOBuffer()
    show(IOContext(buffer, settings...), typst_mime, x)
    TypstString(TypstText(String(take!(buffer))))
end

"""
    @typst_str(s)
    typst"s"

Construct a [`TypstString`](@ref).

Values can be interpolated by calling the `TypstString` constructor,
except with a backslash `\\` instead of the type name.

!!! tip
    Use [`show`](@ref) with `MIME"text/typst"` to print directly to an `IO`.

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
        _, current = parse(s, start; filename, greedy = false)
        previous = current
        push!(args, esc(parse("TypstString" * s[start:current - 1]; filename)))
    end

    previous <= last && push!(args, s[previous:last])
    :(TypstString(TypstText($_s)))
end

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

for (setting, type) in [:mode => Mode, :inline => Bool, :indent => String, :depth => Int]
    @eval $setting(io) = io[$(QuoteNode(setting))]::$type
end

"""
    settings

| Setting   | Value   | Description |
|:----------|:--------|:------------|
| mode      | markup  | The Typst [`Mode`](@ref) in the current context, where `code` follows the number sign `#`, `markup` is at the top-level and enclosed in square brackets `[]`, and `math` is enclosed in dollar signs `\$`. |
| inline    | true    | When `mode = math`, specifies whether the enclosing dollar signs `\$` are padded with a space to render the element inline or its own block. |
| indent    | ' ' ^ 4 | The string used for horizontal spacing by some elements with multi-line Typst code. |
| depth     | 0       | Indicates the current level of nesting within container types. |
"""
const settings = (
    mode = markup,
    inline = true,
    indent = "    ",
    depth = 0
)

"""
    show(::IO, ::MIME"text/typst", x)

Write `x` to `io` as Typst code.

Provides default settings for [`show_typst`](@ref).

!!! warning
    The methods of `show_typst` are incomplete.
    Please file an issue or create a pull-request for missing methods.
    It is safe to implement missing methods (via type-piracy) until
    it has been released in a new minor version of Typstry.jl.
"""
show(io::IO, ::MIME"text/typst", x) =
    show_typst(IOContext(io, map(key -> key => get(io, key, settings[key]), keys(settings))...), x)

"""
    show_typst(io, ::AbstractChar)

# Examples
```jldoctest
julia> show(IOContext(stdout, :mode => code), "text/typst", 'a')
"'a'"

julia> show(IOContext(stdout, :mode => markup), "text/typst", 'a')
'a'

julia> show(IOContext(stdout, :mode => math), "text/typst", 'a')
'a'
```
"""
show_typst(io, x::AbstractChar) =
    enclose(show, io, x, mode(io) == code ? "\"" : "")

# function format(io, x::AbstractDict{<:AbstractString}; mode, settings...)
#     mode == code || print(io, "#")

#     enclose(io, "(", ")") do
#         map_join(io, pairs(x), ", ") do (key, value)
#             # ?
#             print(io, ": ")
#             typstify(io, value; mode = code, settings)
#         end
#     end
# end

"""
    show_typst(io, ::AbstractFloat)

# Examples
```jldoctest
julia> show(IOContext(stdout, :mode => code), "text/typst", 1.2)
1.2

julia> show(IOContext(stdout, :mode => markup), "text/typst", 1.2)
1.2

julia> show(IOContext(stdout, :mode => math), "text/typst", 1.2)
1.2
```
"""
show_typst(io, x::AbstractFloat) = print(io, x)

"""
    show_typst(io, ::AbstractMatrix)

# Examples
```jldoctest
julia> show(IOContext(stdout, :mode => code), "text/typst", [true 1; 1.0 [Any[true 1; 1.0 nothing]]])
\$mat(
    "true", 1;
    1.0, mat(
        "true", 1;
        1.0, ""
    )
)\$

julia> show(IOContext(stdout, :mode => markup), "text/typst", [true 1; 1.0 [Any[true 1; 1.0 nothing]]])
\$mat(
    "true", 1;
    1.0, mat(
        "true", 1;
        1.0, ""
    )
)\$

julia> show(IOContext(stdout, :mode => math), "text/typst", [true 1; 1.0 [Any[true 1; 1.0 nothing]]])
mat(
    "true", 1;
    1.0, mat(
        "true", 1;
        1.0, ""
    )
)
```
"""
show_typst(io, x::AbstractMatrix) =
    enclose((io, x; indent, depth) -> begin
        _depth = depth + 1

        print(io, "mat(\n")
        join_with((io, x; indent) -> begin
            print(io, indent ^ _depth)
            join_with((io, x) -> show_typst(io, x), io, x, ", ")
        end, IOContext(io, :mode => math, :depth => _depth), eachrow(x), ";\n"; indent)
        print(io, "\n", indent ^ depth, ")")
    end, io, x, math_pad(io); indent = indent(io), depth = depth(io))

"""
    show_typst(io, ::AbstractString)

# Examples
```jldoctest
julia> show(IOContext(stdout, :mode => code), "text/typst", "a")
"\\\"a\\\""

julia> show(IOContext(stdout, :mode => markup), "text/typst", "a")
"a"

julia> show(IOContext(stdout, :mode => math), "text/typst", "a")
"\\\"a\\\""
```
"""
show_typst(io, x::AbstractString) = enclose(io, x, "\"") do io, x
    s = mode(io) == markup ? "" : "\\\""
    enclose(io, x, s, s) do io, x
        for c in x
            c == '"' && print(io, "\\\\\\")
            print(io, c)
        end
    end
end

"""
    show_typst(io, ::AbstractVector)

# Examples
```jldoctest
julia> show(IOContext(stdout, :mode => code), "text/typst", Any[true, [1]])
\$vec("true", vec(1))\$

julia> show(IOContext(stdout, :mode => markup), "text/typst", Any[true, [1]])
\$vec("true", vec(1))\$

julia> show(IOContext(stdout, :mode => math), "text/typst", Any[true, [1]])
vec("true", vec(1))
```
"""
show_typst(io, x::AbstractVector) = enclose(IOContext(io, :mode => math), x, math_pad(io)) do io, x
    delim, gap = map(key -> get(io, key, "")::String, [:delim, :gap])
    print(io, "vec(")
    isempty(delim) || print(io, "delim: ", repr(delim), ", ")
    isempty(gap) || print(io, "gap: ", gap, ", ")
    join_with(show_typst, io, x, ", "),
    print(io, ")")
end

"""
    show_typst(io, ::Bool)

# Examples
```jldoctest
julia> show(IOContext(stdout, :mode => code), "text/typst", true)
true

julia> show(IOContext(stdout, :mode => markup), "text/typst", true)
#true

julia> show(IOContext(stdout, :mode => math), "text/typst", true)
"true"
```
"""
function show_typst(io, x::Bool)
    _mode = mode(io)

    if _mode == math enclose(print, io, x, "\"")
    elseif _mode == markup print(io, "#", x)
    else print(io, x)
    end
end

"""
    show_typst(io, ::Complex)

# Examples
```jldoctest
julia> show(IOContext(stdout, :mode => code), "text/typst", 1 + 2im)
\$1 + 2i\$

julia> show(IOContext(stdout, :mode => markup), "text/typst", 1 + 2im)
\$1 + 2i\$

julia> show(IOContext(stdout, :mode => math), "text/typst", 1 + 2im)
1 + 2i
```
"""
show_typst(io, x::Complex) =
    enclose((io, x) -> print(io, sprint(print, x)[begin:end - 1]), io, x, math_pad(io))

"""
    show_typst(io, ::Irrational)

# Examples
```jldoctest
julia> show(IOContext(stdout, :mode => code), "text/typst", π)
3.141592653589793

julia> show(IOContext(stdout, :mode => markup), "text/typst", π)
π

julia> show(IOContext(stdout, :mode => math), "text/typst", π)
π
```
"""
show_typst(io, x::Irrational) =
    mode(io) == code ? show_typst(io, Float64(x)) : print(io, x)

"""
    show_typst(io, ::Nothing)

# Examples
```jldoctest
julia> show(IOContext(stdout, :mode => code), "text/typst", nothing)
""

julia> show(IOContext(stdout, :mode => markup), "text/typst", nothing)

julia> show(IOContext(stdout, :mode => math), "text/typst", nothing)
""
```
"""
show_typst(io, ::Nothing) = if mode(io) != markup print(io, "\"\"") end

"""
    show_typst(io, ::OrdinalRange{<:Integer, <:Integer})

# Examples
```jldoctest
julia> show(IOContext(stdout, :mode => code), "text/typst", 1:4)
range(1, 5, step: 1)

julia> show(IOContext(stdout, :mode => markup), "text/typst", 1:4)
#range(1, 5, step: 1)

julia> show(IOContext(stdout, :mode => math), "text/typst", 1:4)
#range(1, 5, step: 1)
```
"""
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

"""
    show_typst(io, ::Rational)

# Examples
```jldoctest
julia> show(IOContext(stdout, :mode => code), "text/typst", 1//2)
(1 / 2)

julia> show(IOContext(stdout, :mode => markup), "text/typst", 1//2)
\$1 / 2\$

julia> show(IOContext(stdout, :mode => math), "text/typst", 1//2)
1 / 2
```
"""
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

"""
    show_typst(io, ::Regex)

# Examples
```jldoctest
julia> show(IOContext(stdout, :mode => code), "text/typst", r"[a-z]")
regex("[a-z]")

julia> show(IOContext(stdout, :mode => markup), "text/typst", r"[a-z]")
#regex("[a-z]")

julia> show(IOContext(stdout, :mode => math), "text/typst", r"[a-z]")
#regex("[a-z]")
```
"""
function show_typst(io, x::Regex)
    code_mode(io)
    enclose((io, x) -> print(io, sprint(print, x)[begin + 1:end]), io, x, "regex(", ")")
end

"""
    show_typst(io, ::Signed)

# Examples
```jldoctest
julia> show(IOContext(stdout, :mode => code), "text/typst", 1)
1

julia> show(IOContext(stdout, :mode => markup), "text/typst", 1)
1

julia> show(IOContext(stdout, :mode => math), "text/typst", 1)
1
```
"""
show_typst(io, x::Signed) = print(io, x)

"""
    show_typst(io, ::Text)

# Examples
```jldoctest
julia> show(IOContext(stdout, :mode => code), "text/typst", Text("[\\\"a\\\"]"))
"[\\\"a\\\"]"

julia> show(IOContext(stdout, :mode => markup), "text/typst", Text("[\\\"a\\\"]"))
#"[\\\"a\\\"]"

julia> show(IOContext(stdout, :mode => math), "text/typst", Text("[\\\"a\\\"]"))
#"[\\\"a\\\"]"
```
"""
function show_typst(io, x::Text)
    code_mode(io)
    escape_quote(io, repr(x))
end

"""
    show_typst(io, ::TypstText)

# Examples
```jldoctest
julia> show(IOContext(stdout, :mode => code), "text/typst", TypstText("[\\\"a\\\"]"))
["a"]

julia> show(IOContext(stdout, :mode => markup), "text/typst", TypstText("[\\\"a\\\"]"))
["a"]

julia> show(IOContext(stdout, :mode => math), "text/typst", TypstText("[\\\"a\\\"]"))
["a"]
```
"""
show_typst(io, x::TypstText) = print(io, x.text)
#=
AbstractIrrational
AbstractRange
Symbol
Unsigned
Enum
=#

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
    escape_quote(io, ts.text)
end

for f in (:IOBuffer, :codeunit, :iterate, :ncodeunits, :pointer)
    @eval begin
        "\t$($f)(::TypstString)"
        Base.$f(ts::TypstString) = $f(ts.text)
    end
end

for f in (:codeunit, :isvalid, :iterate)
    @eval begin
        "\t$($f)(::TypstString, ::Integer)"
        Base.$f(ts::TypstString, i::Integer) = $f(ts.text, i)
    end
end
