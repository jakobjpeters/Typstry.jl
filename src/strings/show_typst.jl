
show_typst(io::IO, tc::TypstContext, x::AbstractArray) = math_mode(io, tc, x) do io, tc, x
    _depth, _indent = depth(tc), indent(tc)
    __depth = _depth + 1

    show_parameters(io, tc, "vec", [:delim, :gap], true)
    print(io, _indent ^ __depth)
    join_with(io, x, ", ") do io, x
        show_typst(io, x; depth = __depth, mode = math, parenthesize = false)
    end
    print(io, '\n', _indent ^ _depth, ')')
end
show_typst(io::IO, tc::TypstContext, x::AbstractFloat) =
    if isinf(x)
        code_mode(io, tc)
        print(io, "calc.inf")
    elseif isnan(x)
        code_mode(io, tc)
        print(io, "calc.nan")
    else
        math_mode(io, tc, x) do io, tc, x
            print(io, x)
        end
    end
show_typst(io::IO, tc::TypstContext, x::AbstractMatrix) = math_mode(io, tc, x) do _io, _tc, _x
    _depth = depth(_tc) + 1
    show_parameters(_io, _tc, "mat", [
        :augment, :column_gap, :delim, :gap, :row_gap
    ], true)
    join_with(_io, eachrow(_x), ";\n") do __io, __x
        print(__io, indent(_tc) ^ _depth)
        join_with(__io, __x, ", ") do ___io, ___x
            show_typst(___io, ___x; depth = _depth, mode = math, parenthesize = false)
        end
    end
    print(io, '\n', indent(_tc) ^ depth(_tc), ')')
end
show_typst(io::IO, tc::TypstContext, x::AbstractString) = enclose(io, x, "\"") do _io, _x
    escape_string(_io, _x, '"')
end
function show_typst(io::IO, tc::TypstContext, x::Bool)
    mode(tc) == math ? enclose(print, io, x, "\"") : print(io, x)
end
show_typst(io::IO, tc::TypstContext, x::Complex) = math_mode(io, tc, x) do _io, _tc, _x
    imaginary = imag(_x)
    _real, _imaginary = real(_x), abs(imaginary)
    has_real, has_imaginary = _real ≠ 0, _imaginary ≠ 0
    negative_imaginary = signbit(imaginary)
    left, right = begin
        if !has_real || !has_imaginary || !(mode(_tc) == math && parenthesize(_tc)); ("", "")
        else ("(", ")")
        end
    end

    enclose(IOContext(
        _io, :typst_context => TypstContext(; mode = math)
    ), _x, left, right) do __io, _
        !has_real && has_imaginary || show_typst(__io, _real; mode = math)

        if _imaginary ≠ 0
            if has_real enclose(print, __io, negative_imaginary ? '-' : '+', " ")
            elseif negative_imaginary print(__io, '-')
            end

            _imaginary == 1 || show_typst(__io, abs(imaginary); mode = math)
            print(__io, 'i')
        end
    end
end
show_typst(io::IO, tc::TypstContext, x::HTML) = show_raw(io, tc, x, "html") do _io, _x
    show(_io, MIME"text/html"(), _x)
end
show_typst(io::IO, tc::TypstContext, x::Irrational) = math_mode(io, tc, x) do io, _, x
    print(io, x)
end
function show_typst(io::IO, tc::TypstContext, ::Nothing)
    code_mode(io, tc)
    print(io, "none")
end
function show_typst(io::IO, tc::TypstContext, x::Rational)
    function f(io, x; context...)
        enclose(io, x, (parenthesize(context) ? ("(", ")") : ("", ""))...) do _io, _x
            show_typst(_io, numerator(_x); context...)
            print(io, " / ")
            show_typst(_io, denominator(_x); context...)
        end
    end

    _mode = mode(tc)

    if _mode == markup
        enclose(io, x, block(tc) ? "\$ " : "\$") do _io, _x
            f(_io, _x; mode = math, parenthesize = false)
        end
    else f(io, x; mode = _mode, parenthesize = parenthesize(tc))
    end
end
function show_typst(io::IO, tc::TypstContext, x::Regex)
    code_mode(io, tc)
    enclose(io, x, "regex(", ")") do _io, _x
        buffer = IOBuffer()

        print(buffer, _x)
        seek(buffer, 1)
        write(_io, read(buffer))
    end
end
function show_typst(io::IO, tc::TypstContext, x::Signed)
    mode(tc) == code ? print(io, x) : enclose(print, io, x, math_pad(tc))
end
function show_typst(io::IO, tc::TypstContext, x::Text)
    code_mode(io, tc)
    show_typst(io, string(x))
end
show_typst(io::IO, tc::TypstContext, x::Tuple) = show_array(io, x)
function show_typst(io::IO, tc::TypstContext, x::Unsigned)
    code_mode(io, tc)
    show(io, x)
end
function show_typst(io::IO, tc::TypstContext, x::VersionNumber)
    code_mode(io, tc)
    enclose(io, x, "version(", ")") do _io, _x
        join_with(print, _io, eachsplit(string(_x), '.'), ", ")
    end
end
function show_typst(io::IO, tc::TypstContext, x::Union{
    OrdinalRange{<:Integer, <:Integer},
    StepRangeLen{<:Integer, <:Integer, <:Integer}
})
    code_mode(io, tc)
    enclose(io, x, "range(", ")") do _io, _x
        _step = step(_x)

        show_typst(_io, first(_x); mode = code)
        print(_io, ", ")
        show_typst(_io, last(_x) + 1; mode = code)

        if _step ≠ 1
            print(_io, ", step: ")
            show_typst(_io, _step; mode = code)
        end
    end
end
function show_typst(io::IO, tc::TypstContext, x::Union{Date, DateTime, Period, Time})
    f, keys, values = dates(x)
    _values = map(value -> TypstString(value; mode = code), values)

    code_mode(io, tc)
    show_parameters(io, merge_contexts!(
        TypstContext(; zip(keys, _values)...), tc
    ), f, keys, false)
    print(io, indent(tc) ^ depth(tc), ')')
end
function show_typst(io::IO, ::TypstContext, x)
    if showable(MIME"text/typst"(), x) show(io, MIME"text/typst"(), x)
    elseif showable(MIME"image/gif"(), x) show_image(io, MIME"image/gif"(), x)
    elseif showable(MIME"image/svg+xml"(), x) show_image(io, MIME"image/svg+xml"(), x)
    elseif showable(MIME"image/png"(), x) show_image(io, MIME"image/png"(), x)
    elseif showable(MIME"image/jpg"(), x) show_image(io, MIME"image/jpg"(), x)
    else show(io, MIME"text/plain"(), x)
    end
end
show_typst(io::IO, x::AbstractChar; context...) = show_typst(io, string(x); context...)
show_typst(io::IO, x::Complex{Bool}; context...) = show_typst(
    io, Complex(Int(real(x)), Int(imag(x))); context...
)
show_typst(tc::TypstContext, x) = show_typst(typst_context(tc, x)...)
show_typst(io::IO, x; context...) = show_typst(typst_context(io, TypstContext(; context...), x)...)
show_typst(x; context...) = show_typst(typst_context(TypstContext(; context...), x)...)

# function show_typst(io, tc, x::Union{Date, DateTime, Period, Time})
#     f, keys, values = dates(x)
#     _values = map(value -> TypstString(value; mode = code), values)

#     code_mode(io, tc)
#     show_parameters(io, merge_contexts!(TypstContext(; zip(keys, _values)...), tc), f, keys, false)
#     print(io, indent(tc) ^ _depth(tc), ")")
# end

@doc """
    show_typst(::IO = stdout, ::TypstContext, x)
    show_typst(::TypstContext = TypstContext(), x)

Print in Typst format with Julia settings and Typst
parameters provided by the [`TypstContext`](@ref).

Implement the three-parameter form of this function
for a custom type to specify its Typst formatting.
A setting is a value used in Julia, whose type varies across settings.
A parameter is passed directly to a Typst function and must be a [`TypstString`](@ref)
with the same name as in Typst, except that dashes are replaced with underscores.
Settings each have a default value specified by [`context`](@ref),
whereas the default values of parameters are handled in Typst functions.
Some settings, such as `block`, correspond with a parameter but may also be used in Julia.

!!! tip
    Please create an issue or pull-request to implement new methods.

| Type                                                      | Settings                                 | Parameters                                              |
|:----------------------------------------------------------|:-----------------------------------------|:--------------------------------------------------------|
| `AbstractArray`                                           | `:block`, `:depth`, `:mode`, `:tab_size` | `:delim`, `:gap`                                        |
| `AbstractChar`                                            |                                          |                                                         |
| `AbstractFloat`                                           | `:mode`                                  |                                                         |
| `AbstractMatrix`                                          | `:block`, `:depth`, `:mode`, `:tab_size` | `:augment`, `:column_gap`, `:delim`, `:gap`, `:row_gap` |
| `AbstractString`                                          |                                          |                                                         |
| `Bool`                                                    | `:mode`                                  |                                                         |
| `Complex{Bool}`                                           | `:block`, `:mode`, `:parenthesize`       |                                                         |
| `Complex`                                                 | `:block`, `:mode`, `:parenthesize`       |                                                         |
| `Irrational`                                              | `:mode`                                  |                                                         |
| `Nothing`                                                 | `:mode`                                  |                                                         |
| `OrdinalRange{<:Integer,\u00A0<:Integer}`                 | `:mode`                                  |                                                         |
| `Rational`                                                | `:block`, `:mode`, `:parenthesize`       |                                                         |
| `Regex`                                                   | `:mode`                                  |                                                         |
| `Signed`                                                  | `:mode`                                  |                                                         |
| `StepRangeLen{<:Integer,\u00A0<:Integer,\u00A0<:Integer}` | `:mode`                                  |                                                         |
| `Tuple`                                                   | `:block`, `:depth`, `:mode`, `:tab_size` | `:delim`, `:gap`                                        |
| `Typst`                                                   |                                          |                                                         |
| `TypstString`                                             |                                          |                                                         |
| `TypstText`                                               |                                          |                                                         |
| `Unsigned`                                                | `:mode`                                  |                                                         |
| `VersionNumber`                                           | `:mode`                                  |                                                         |
| `Docs.HTML`                                               | `:block`, `:depth`, `:mode`, `:tab_size` |                                                         |
| `Docs.Text`                                               | `:mode`                                  |                                                         |
| `Dates.Date`                                              | `:mode`, `:indent`                       |                                                         |
| `Dates.DateTime`                                          | `:mode`, `:indent`                       |                                                         |
| `Dates.Period`                                            | `:mode`, `:indent`                       |                                                         |
| `Dates.Time`                                              | `:mode`, `:indent`                       |                                                         |
""" show_typst
