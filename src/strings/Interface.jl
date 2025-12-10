
module Interface

import ..Strings: show_typst

using Base: MathConstants.catalan # TODO
using ..Strings: Utilities, Mode, TypstFunction, TypstString, TypstText, code, markup, math
using Typstry: TypstContext, Utilities.enclose, Contexts.ContextErrors.unwrap
using .Utilities: code_mode, math_mode, math_pad, show_parameters, show_raw

show_typst(io::IO, typst_context::TypstContext, x::AbstractArray) = show_parameters(
    io, typst_context, TypstString(TypstText("math.vec")), x, [:delim, :align, :gap]
)
show_typst(io::IO, ::TypstContext, x::AbstractChar) = show_typst(io, string(x))
function show_typst(io::IO, tc::TypstContext, x::AbstractFloat)
    if isinf(x)
        code_mode(io, tc)
        print(io, "float.inf")
    elseif isnan(x)
        code_mode(io, tc)
        print(io, "float.nan")
    else unwrap(tc, Mode, :mode) == code ? print(io, x) : enclose(print, io, x, math_pad(tc))
    end
end
show_typst(io::IO, typst_context::TypstContext, x::AbstractMatrix) = show_parameters(
    io, typst_context, TypstString(TypstText("math.mat")), Tuple.(eachrow(x)), [
        :delim, :align, :augment, :gap, :row_gap, :column_gap
    ]
)
function show_typst(io::IO, tc::TypstContext, x::AbstractString)
    unwrap(tc, Mode, :mode) == markup && print(io, '#')
    enclose((io, x) -> escape_string(io, x, '"'), io, x, '"')
end
function show_typst(io::IO, tc::TypstContext, x::Bool)
    code_mode(io, tc)
    print(io, x)
end
function show_typst(io::IO, tc::TypstContext, x::Complex{<:Union{
    AbstractFloat, AbstractIrrational, Rational{<:Signed}, Signed
}})
    _mode = unwrap(tc, Mode, :mode)
    math_mode(io, tc, x) do io, tc, x
        enclose(io, x, (_mode == math && unwrap(tc, Bool, :parenthesize) ? ("(", ")") : ("", ""))...) do io, x
            imaginary = imag(x)

            show_typst(io, real(x))
            print(io, ' ', signbit(imaginary) ? '-' : '+', ' ')
            show_typst(io, imaginary)
            print(io, 'i')
        end
    end
end
function show_typst(io::IO, ::TypstContext, x::Complex{<:Rational{<:Union{Bool, Unsigned}}})
    _real, _imag = real(x), imag(x)
    show_typst(io, Complex(
        signed(numerator(_real)) // signed(denominator(_real)),
        signed(numerator(_imag)) // signed(denominator(_imag))
    ))
end
show_typst(io::IO, ::TypstContext, x::Complex{<:Union{Bool, Unsigned}}) = show_typst(
    io, Complex(signed(real(x)), signed(imag(x)))
)
show_typst(io::IO, tc::TypstContext, x::HTML) = show_raw(io, tc, MIME"text/html"(), :html, x)
show_typst(io::IO, tc::TypstContext, x::Irrational{T}) where T = math_mode(io, tc, x) do io, _, x
    if T isa Symbol && length(string(T)) == 1 print(io, x)
    else show_typst(io, string(x); mode = math)
    end
end
function show_typst(io::IO, typst_context::TypstContext, x::NamedTuple)
    if isempty(x)
        code_mode(io, typst_context)
        print(io, "(:)")
    else show_typst(io, TypstFunction(typst_context, TypstString(TypstText("")); x...))
    end
end
function show_typst(io::IO, tc::TypstContext, ::Nothing)
    code_mode(io, tc)
    print(io, "none")
end
function show_typst(io::IO, tc::TypstContext, x::Rational{<:Signed})
    _mode = unwrap(tc, Mode, :mode)
    math_mode(io, tc, x) do io, tc, x
        enclose(io, x, (_mode == math && unwrap(tc, Bool, :parenthesize) ? ("(", ")") : ("", ""))...) do io, x
            show_typst(io, numerator(x); mode = math)
            print(io, " / ")
            show_typst(io, denominator(x); mode = math)
        end
    end
end
show_typst(io::IO, ::TypstContext, x::Rational{<:Union{Bool, Unsigned}}) = show_typst(
    io, signed(numerator(x)) // signed(denominator(x))
)
show_typst(io::IO, typst_context::TypstContext, x::Regex) = show_typst(
    io,
    TypstFunction(typst_context, TypstString(TypstText(:regex)), @view sprint(show, x)[3:(end - 1)])
)
function show_typst(io::IO, tc::TypstContext, x::Signed)
    unwrap(tc, Mode, :mode) == code ? print(io, x) : enclose(print, io, x, math_pad(tc))
end
show_typst(io::IO, typst_context::TypstContext, x::Symbol) = math_mode(
    show_typst, io, typst_context, string(x)
)
function show_typst(io::IO, tc::TypstContext, x::Text)
    code_mode(io, tc)
    show_typst(io, string(x); mode = code)
end
function show_typst(io::IO, tc::TypstContext, x::Tuple)
    if length(x) == 1
        code_mode(io, tc)
        enclose(show_typst, io, only(x), '(', ",)"; mode = code)
    else show_typst(io, TypstFunction(tc, TypstString(TypstText("")), x...))
    end
end
function show_typst(io::IO, tc::TypstContext, x::Unsigned)
    code_mode(io, tc)
    show(io, x)
end
show_typst(io::IO, tc::TypstContext, x::VersionNumber) = show_typst(io, TypstFunction(
    tc,
    TypstString(TypstText(:version)), parse.(Int, eachsplit(string(x), '.'))...
))
function show_typst(io::IO, tc::TypstContext, x::Union{
    OrdinalRange{<:Signed, <:Signed},
    StepRangeLen{<:Signed, <:Signed, <:Signed, <:Signed}
})
    inputs = (tc, TypstString(TypstText(:range)), first(x), last(x) + one(last(x)))
    _step = step(x)

    if _step == 1 show_typst(io, TypstFunction(inputs...))
    else show_typst(io, TypstFunction(inputs...; step = _step))
    end
end
show_typst(io::IO, ::TypstContext, x::Union{
    OrdinalRange{<:Integer, <:Integer},
    StepRangeLen{<:Integer, <:Integer, <:Integer, <:Integer}
}) = show_typst(io, signed(first(x)):signed(step(x)):signed(last(x)))

end # Interface
