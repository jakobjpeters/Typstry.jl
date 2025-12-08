
module AbstractTypsts

export AbstractTypst

"""
    AbstractTypst

Supertype of [`TypstFunction`](@ref Typstry.Strings.TypstFunctions.TypstFunction),
[`TypstText`](@ref Typstry.Strings.TypstTexts.TypstText),
and [`Typst`](@ref Typstry.Strings.Typsts.Typst).

# Interface

- `repr(::MIME"text/typst",\u00A0::AbstractTypst)`
- `show(::IO,\u00A0::Union{MIME"application/pdf",\u00A0MIME"image/png",\u00A0MIME"image/svg+xml"},\u00A0::AbstractTypst)`
    - Accepts `IOContext(::IO,\u00A0::TypstContext)`
    - Uses the `preamble` in [`context`](@ref Typstry.Contexts.TypstContexts.context)
    - Supports the [`julia_mono`](@ref Typstry.Commands.JuliaMono.julia_mono) typeface
- `show(::IO,\u00A0::MIME"text/typst",\u00A0::AbstractTypst)`
    - Accepts `IOContext(::IO,\u00A0::TypstContext)`
"""
abstract type AbstractTypst end

end # AbstractTypsts
