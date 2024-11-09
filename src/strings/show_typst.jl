
function _show_typst(io, tc, x)
    _tc = TypstContext(x)
    merge!(merge_contexts!(_tc, context), tc)
    show_typst(io, _tc, x)
end
_show_typst(io, x; kwargs...) = _show_typst(io, TypstContext(; kwargs...), x)

show_typst(io, tc, x::AbstractChar) = show_typst(io, tc, string(x))
show_typst(io, tc, x::AbstractFloat) =
    if isinf(x)
        code_mode(io, tc)
        print(io, "calc.inf")
    elseif isnan(x)
        code_mode(io, tc)
        print(io, "calc.nan")
    elseif mode(tc) == code print(io, x)
    else enclose(print, io, x, math_pad(tc))
    end
show_typst(io, tc, x::AbstractMatrix) = mode(tc) == code ?
    show_array(io, x) :
    math_mode((io, tc, x) -> begin
        _depth = depth(tc) + 1

        show_parameters(io, tc, "mat", [:augment, :column_gap, :delim, :gap, :row_gap], true)
        join_with((io, x) -> begin
            print(io, indent(tc) ^ _depth)
            join_with((io, x) -> _show_typst(io, x; depth = _depth, mode = math, parenthesize = false), io, x, ", ")
        end, io, eachrow(x), ";\n")
        print(io, "\n", indent(tc) ^ depth(tc), ")")
    end, io, tc, x)
show_typst(io, tc, x::AbstractString) = enclose((io, x) -> escape_string(io, x, "\""),
    io, x, "\"", mode(tc) == math && length(x) == 1 ? "\\u{200b}\"" : "\"")
show_typst(io, tc, x::Bool) = mode(tc) == math ? enclose(print, io, x, "\"") : print(io, x)
show_typst(io, tc, x::Complex{Bool}) = _show_typst(io, tc, Complex(Int(real(x)), Int(imag(x))))
show_typst(io, tc, x::Complex) = math_mode(io, tc, x) do io, tc, x
    imaginary = imag(x)
    _real, _imaginary = real(x), abs(imaginary)
    __real, __imaginary = _real == 0, _imaginary == 0
    ___imaginary = signbit(imaginary)
    _enclose = __real || __imaginary || !(mode(tc) == math && parenthesize(tc)) ? ("", "") : ("(", ")")

    enclose(IOContext(io, :typst_context => TypstContext(; mode = math)), x, _enclose...) do io, x
        _tc = TypstContext(; mode = math)
        __real && !__imaginary || _show_typst(io, _tc, _real)

        if _imaginary ≠ 0
            if !__real enclose(print, io, ___imaginary ? "-" : "+", " ")
            elseif ___imaginary print(io, "-")
            end

            _imaginary == 1 || _show_typst(io, _tc, abs(imaginary))
            print(io, "i")
        end
    end
end
show_typst(io, tc, x::HTML) = show_raw((io, x) -> show(io, MIME"text/html"(), x), io, tc, x, "html")
show_typst(io, tc, x::Irrational) = mode(tc) == code ?
    _show_typst(io, tc, Float64(x)) :
    math_mode((io, _, x) -> print(io, x), io, tc, x)
function show_typst(io, tc, ::Nothing)
    code_mode(io, tc)
    print(io, "none")
end
function show_typst(io, tc, x::Rational)
    _mode = mode(tc)
    f = (io, x; kwargs...) -> enclose(io, x, (parenthesize(kwargs) ? ("(", ")") : ("", ""))...) do io, x
        _show_typst(io, numerator(x); kwargs...)
        print(io, " / ")
        _show_typst(io, denominator(x); kwargs...)
    end

    _mode == markup ?
        enclose((io, x) -> f(io, x; mode = math, parenthesize = false), io, x, block(tc) ? "\$ " : "\$") :
        f(io, x; mode = _mode, parenthesize = parenthesize(tc))
end
function show_typst(io, tc, x::Regex)
    code_mode(io, tc)
    enclose(io, x, "regex(", ")") do io, x
        buffer = IOBuffer()
        print(buffer, x)
        seek(buffer, 1)
        write(io, read(buffer))
    end
end
show_typst(io, tc, x::Signed) = mode(tc) == code ?
    print(io, x) :
    enclose(print, io, x, math_pad(tc))
function show_typst(io, tc, x::Text)
    code_mode(io, tc)
    _show_typst(io, string(x))
end
function show_typst(io, tc, x::Unsigned)
    code_mode(io, tc)
    show(io, x)
end
function show_typst(io, tc, x::VersionNumber) # TODO: remove allocation
    code_mode(io, tc)
    enclose((io, x) -> join_with(print, io, eachsplit(string(x), "."), ", "), io, x, "version(", ")")
end
show_typst(io, tc, x::Union{AbstractArray, Tuple}) =
    mode(tc) == code ? show_array(io, x) : show_vector(io, tc, x)
show_typst(io, tc, x::Union{
    OrdinalRange{<:Integer, <:Integer},
    StepRangeLen{<:Integer, <:Integer, <:Integer}
}) = mode(tc) == code ?
    enclose(io, x, "range(", ")") do io, x
        _step = step(x)

        _show_typst(io, first(x); mode = code)
        print(io, ", ")
        _show_typst(io, last(x) + 1; mode = code)

        if _step ≠ 1
            print(io, ", step: ")
            _show_typst(io, _step; mode = code)
        end
    end : show_vector(io, tc, x)
function show_typst(io, tc, x::Union{Date, DateTime, Period, Time})
    f, keys, values = dates(x)
    _values = map(value -> TypstString(value; mode = code), values)

    code_mode(io, tc)
    show_parameters(io, merge_contexts!(TypstContext(; zip(keys, _values)...), tc), f, keys, false)
    print(io, indent(tc) ^ depth(tc), ")")
end
show_typst(tc, x) = _show_typst(stdout, tc, x)
show_typst(x) = show_typst(TypstContext(), x)

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
