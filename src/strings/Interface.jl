
module Interface

import ..Strings: lower, show_typst

using .Docs: HTML, Text
using ..Strings:
    AbstractTypst, TypstImage, TypstMode, TypstRaw, TypstString, TypstText, Typst,
    @typst_str, code, math
using Typstry: TypstContext

lower(character::AbstractChar) = string(character)
function lower(float::AbstractFloat)
    text = begin
        if isinf(float) "float.inf"
        elseif isnan(float) "float.nan"
        else string(float)
        end
    end
    TypstMode(code, TypstText(text))
end
lower(text::AbstractString) = TypstMode(code, TypstText(escape_string(text, '"')))
lower(boolean::Bool) = TypstMode(code, TypstText(boolean))
function lower(complex::Complex{<:Union{Bool, Unsigned}})
    Complex(signed(real(complex)), signed(imag(complex)))
end
lower(complex::Complex{<:Rational{<:Union{Bool, Unsigned}}}) = Complex(
    lower(real(complex)), lower(imag(complex))
)
lower(html::HTML) = TypstRaw(MIME"text/html"(), :html, html)
lower(::Nothing) = TypstMode(code, typst"none")
function lower(rational::Rational{<:Union{Bool, Unsigned}})
    signed(numerator(rational)) // signed(denominator(rational))
end
lower(regex::Regex) = TypstFunction(:regex, @view sprint(show, regex)[3:(end - 1)])
lower(signed::Signed) = TypstMode(code, TypstText(signed))
lower(symbol::Symbol) = TypstMode(math, string(symbol))
lower(text::Text) = TypstMode(code, string(text))
lower(unsigned::Unsigned) = TypstMode(code, repr(unsigned))
lower(version_number::VersionNumber) = TypstFunction(
    :version, parse.(Int, eachsplit(string(version_number)))...
)
lower(range::Union{
    OrdinalRange{<:Integer, <:Integer},
    StepRangeLen{<:Integer, <:Integer, <:Integer, <:Integer}
}) = signed(first(range)):signed(step(range)):signed(last(range))

function show_typst(io::IO, irrational::AbstractIrrational)
    text = string(irrational)

    if length(text) == 1 show_typst(io, TypstMode(math, TypstText(text)))
    else show_typst(io, TypstMode(math, text))
    end
end

end # Interface
