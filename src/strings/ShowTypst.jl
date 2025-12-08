
module ShowTypst

import ..Strings: show_typst
import Typstry

# TODO:
using Base: MathConstants.catalan
using Typstry.Contexts: TypstContext, context
using Typstry.Utilities: enclose, typst_context
using ..Strings: Strings, Utilities, TypstString, TypstText, code, markup, math
using .Utilities: code_mode, math_mode, math_pad, show_image, show_parameters, show_raw

export show_typst

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
    else Strings.mode(tc) == code ? print(io, x) : enclose(print, io, x, math_pad(tc))
    end
end
show_typst(io::IO, typst_context::TypstContext, x::AbstractMatrix) = show_parameters(
    io, typst_context, TypstString(TypstText("math.mat")), Tuple.(eachrow(x)), [
        :delim, :align, :augment, :gap, :row_gap, :column_gap
    ]
)
function show_typst(io::IO, tc::TypstContext, x::AbstractString)
    Strings.mode(tc) == markup && print(io, '#')
    enclose((io, x) -> escape_string(io, x, '"'), io, x, '"')
end
function show_typst(io::IO, tc::TypstContext, x::Bool)
    code_mode(io, tc)
    print(io, x)
end
function show_typst(io::IO, tc::TypstContext, x::Complex{<:Union{
    AbstractFloat, AbstractIrrational, Rational{<:Signed}, Signed
}})
    _mode = Strings.mode(tc)
    math_mode(io, tc, x) do io, tc, x
        enclose(io, x, (_mode == math && Strings.parenthesize(tc) ? ("(", ")") : ("", ""))...) do io, x
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
    else show_typst(io, Strings.TypstFunction(typst_context, TypstString(TypstText("")); x...))
    end
end
function show_typst(io::IO, tc::TypstContext, ::Nothing)
    code_mode(io, tc)
    print(io, "none")
end
function show_typst(io::IO, tc::TypstContext, x::Rational{<:Signed})
    _mode = Strings.mode(tc)
    math_mode(io, tc, x) do io, tc, x
        enclose(io, x, (_mode == math && Strings.parenthesize(tc) ? ("(", ")") : ("", ""))...) do io, x
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
    Strings.TypstFunction(typst_context, TypstString(TypstText(:regex)), @view sprint(show, x)[3:(end - 1)])
)
function show_typst(io::IO, tc::TypstContext, x::Signed)
    Strings.mode(tc) == code ? print(io, x) : enclose(print, io, x, math_pad(tc))
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
    else show_typst(io, Strings.TypstFunction(tc, TypstString(TypstText("")), x...))
    end
end
function show_typst(io::IO, tc::TypstContext, x::Unsigned)
    code_mode(io, tc)
    show(io, x)
end
show_typst(io::IO, tc::TypstContext, x::VersionNumber) = show_typst(io, Strings.TypstFunction(
    tc,
    TypstString(TypstText(:version)), parse.(Int, eachsplit(string(x), '.'))...
))
function show_typst(io::IO, tc::TypstContext, x::Union{
    OrdinalRange{<:Signed, <:Signed},
    StepRangeLen{<:Signed, <:Signed, <:Signed, <:Signed}
})
    inputs = (tc, TypstString(TypstText(:range)), first(x), last(x) + one(last(x)))
    _step = step(x)

    if _step == 1 show_typst(io, Strings.TypstFunction(inputs...))
    else show_typst(io, Strings.TypstFunction(inputs...; step = _step))
    end
end
show_typst(io::IO, ::TypstContext, x::Union{
    OrdinalRange{<:Integer, <:Integer},
    StepRangeLen{<:Integer, <:Integer, <:Integer, <:Integer}
}) = show_typst(io, signed(first(x)):signed(step(x)):signed(last(x)))
function show_typst(io::IO, ::TypstContext, x)
    if showable(MIME"text/typst"(), x) show(io, MIME"text/typst"(), x)
    elseif showable(MIME"image/gif"(), x) show_image(io, MIME"image/gif"(), x)
    elseif showable(MIME"image/svg+xml"(), x) show_image(io, MIME"image/svg+xml"(), x)
    elseif showable(MIME"image/png"(), x) show_image(io, MIME"image/png"(), x)
    elseif showable(MIME"image/jpg"(), x) show_image(io, MIME"image/jpg"(), x)
    elseif showable(MIME"image/webp"(), x) show_image(io, MIME"image/webp"(), x)
    else show_typst(io, repr(x))
    end
end
show_typst(tc::TypstContext, x) = show_typst(typst_context(tc, x)...)
show_typst(io::IO, x; context...) = show_typst(typst_context(io, TypstContext(; context...), x)...)
show_typst(x; context...) = show_typst(typst_context(TypstContext(; context...), x)...)

@doc """
    show_typst(::IO, ::TypstContext, ::Any)::Nothing
    show_typst(::IO, ::Any; context...)::Nothing
    show_typst(::TypstContext, ::Any)::Nothing
    show_typst(::Any; context...)::Nothing

Print in Typst format with Julia settings and Typst
parameters provided by the [`TypstContext`](@ref).

Implement the three-parameter form of this function
for a custom type to specify its Typst formatting.
A setting is a value used in Julia, whose type varies across settings.
A parameter is passed directly to a Typst function and must be a [`TypstString`](@ref)
with the same name as in Typst, except that dashes are replaced with underscores.
Some settings, such as `block`, correspond with a parameter but may also be used in Julia.

See also the [Typst Formatting Examples](@ref).

!!! tip
    Please create an issue or pull-request to implement new methods.
""" show_typst

end # ShowTypst
