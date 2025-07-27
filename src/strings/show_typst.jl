
show_typst(io::IO, tc::TypstContext, x::AbstractChar) = show_typst(io, string(x))
function show_typst(io::IO, tc::TypstContext, x::AbstractFloat)
    if isinf(x)
        code_mode(io, tc)
        print(io, "float.inf")
    elseif isnan(x)
        code_mode(io, tc)
        print(io, "float.nan")
    else math_mode((io, _, x) -> print(io, x), io, tc, x)
    end
end
function show_typst(io::IO, tc::TypstContext, x::AbstractString)
    code_mode(io, tc)
    enclose(io, x, '"') do io, x
        escape_string(io, x, '"')
    end
end
function show_typst(io::IO, tc::TypstContext, x::Bool)
    code_mode(io, tc)
    print(io, x)
end
show_typst(io::IO, tc::TypstContext, x::Complex{<:Union{
    AbstractFloat, AbstractIrrational, Rational{<:Signed}, Signed
}}) = math_mode(io, tc, x) do io, tc, x
    enclose(io, x, (mode(tc) == math && parenthesize(tc) ? ("(", ")") : ("", ""))...) do io, x
        _real, _imag = real(x), imag(x)

        signbit(_real) && print(io, '-')
        show_typst(io, abs(_real); mode = math)
        print(io, ' ', signbit(_imag) ? '-' : '+', ' ')
        show_typst(io, abs(_imag); mode = math)
        print(io, 'i')
    end
end
show_typst(io::IO, tc::TypstContext, x::Complex{<:Union{
    Bool, Unsigned, Rational{<:Union{Bool, Unsigned
}}}}) = show_typst(
    io, Complex(signed(real(x)), signed(imag(x)))
)
show_typst(io::IO, tc::TypstContext, x::HTML) = show_raw(io, tc, MIME"text/html"(), :html, x)
show_typst(io::IO, tc::TypstContext, x::Irrational{T}) where T = math_mode(io, tc, x) do io, _, x
    if T isa Symbol && length(string(T)) == 1 print(io, x)
    else show_typst(io, string(x); mode = math)
    end
end
function show_typst(io::IO, tc::TypstContext, ::Nothing)
    code_mode(io, tc)
    print(io, "none")
end
show_typst(io::IO, tc::TypstContext, x::Rational{<:Signed}) = math_mode(io, tc, x) do io, tc, x
    enclose(io, x, (mode(tc) == math && parenthesize(tc) ? ("(", ")") : ("", ""))...) do io, x
        show_typst(io, numerator(x); mode = math)
        print(io, " / ")
        show_typst(io, denominator(x); mode = math)
    end
end
show_typst(io::IO, ::TypstContext, x::Rational{<:Union{Bool, Unsigned}}) = show_typst(
    io, signed(numerator(x)) // signed(denominator(x))
)
function show_typst(io::IO, tc::TypstContext, x::Regex)
    code_mode(io, tc)
    enclose(io, x, "regex(", ')') do io, x
        buffer = IOBuffer()

        print(buffer, x)
        seek(buffer, 1)
        write(io, read(buffer))
    end
end
function show_typst(io::IO, tc::TypstContext, x::Signed)
    mode(tc) == code ? print(io, x) : enclose(print, io, x, math_pad(tc))
end
function show_typst(io::IO, tc::TypstContext, x::Text)
    code_mode(io, tc)
    show_typst(io, string(x); mode = code)
end
function show_typst(io::IO, tc::TypstContext, x::Tuple)
    code_mode(io, tc)
    enclose(io, x, '(', ')') do io, x
        join_with(io, x, ", ") do io, x
            show_typst(io, x; parenthesize = false, mode = code)
        end

        if length(x) == 1 print(io, ',') end
    end
end
function show_typst(io::IO, tc::TypstContext, x::Unsigned)
    code_mode(io, tc)
    show(io, x)
end
function show_typst(io::IO, tc::TypstContext, x::VersionNumber)
    code_mode(io, tc)
    enclose(io, x, "version(", ')') do io, x
        join_with(print, io, eachsplit(string(x), '.'), ", ")
    end
end
function show_typst(io::IO, tc::TypstContext, x::Union{
    OrdinalRange{<:Integer, <:Integer},
    StepRangeLen{<:Integer, <:Integer, <:Integer}
})
    code_mode(io, tc)
    enclose(io, x, "range(", ')') do io, x
        _step = step(x)

        show_typst(io, first(x); mode = code)
        print(io, ", ")
        show_typst(io, last(x) + 1; mode = code)

        if _step ≠ 1
            print(io, ", step: ")
            show_typst(io, _step; mode = code)
        end
    end
end
show_typst(tc::TypstContext, x) = show_typst(typst_context(tc, x)...)
show_typst(io::IO, x; context...) = show_typst(typst_context(io, TypstContext(; context...), x)...)
show_typst(x; context...) = show_typst(typst_context(TypstContext(; context...), x)...)

# show_typst(io::IO, tc::TypstContext, x::AbstractArray) = math_mode(io, tc, x) do io, tc, x
#     _depth, _indent = depth(tc), indent(tc)
#     __depth = _depth + 1

#     show_parameters(io, tc, "vec", [:delim, :gap], true)
#     print(io, _indent ^ __depth)
#     join_with(io, x, ", ") do io, x
#         show_typst(io, x; depth = __depth, mode = math, parenthesize = false)
#     end
#     print(io, '\n', _indent ^ _depth, ')')
# end
# show_typst(io::IO, tc::TypstContext, x::AbstractMatrix) = math_mode(io, tc, x) do _io, _tc, _x
#     _depth = depth(_tc) + 1
#     show_parameters(_io, _tc, "mat", [
#         :augment, :column_gap, :delim, :gap, :row_gap
#     ], true)
#     join_with(_io, eachrow(_x), ";\n") do __io, __x
#         print(__io, indent(_tc) ^ _depth)
#         join_with(__io, __x, ", ") do ___io, ___x
#             show_typst(___io, ___x; depth = _depth, mode = math, parenthesize = false)
#         end
#     end
#     print(io, '\n', indent(_tc) ^ depth(_tc), ')')
# end
# function show_typst(io::IO, tc::TypstContext, x::Union{Date, DateTime, Period, Time})
#     f, keys, values = dates(x)
#     _values = map(value -> TypstString(value; mode = code), values)

#     code_mode(io, tc)
#     show_parameters(io, merge_contexts!(
#         TypstContext(; zip(keys, _values)...), tc
#     ), f, keys, false)
#     print(io, indent(tc) ^ depth(tc), ')')
# end
# function show_typst(io::IO, ::TypstContext, x)
#     if showable(MIME"text/typst"(), x) show(io, MIME"text/typst"(), x)
#     elseif showable(MIME"image/gif"(), x) show_image(io, MIME"image/gif"(), x)
#     elseif showable(MIME"image/svg+xml"(), x) show_image(io, MIME"image/svg+xml"(), x)
#     elseif showable(MIME"image/png"(), x) show_image(io, MIME"image/png"(), x)
#     elseif showable(MIME"image/jpg"(), x) show_image(io, MIME"image/jpg"(), x)
#     else show_typst(io, repr(MIME"text/plain"(), x))
#     end
# end

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
