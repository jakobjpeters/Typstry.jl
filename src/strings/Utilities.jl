
module Utilities

using .Iterators: repeated
using Typstry: Strings, Typstry, TypstContext, Utilities.enclose, Utilities.typst_context

export code_mode, escape, format, math_mode, math_pad, show_parameters, show_image, show_raw

code_mode(io::IO, tc) = if Strings.mode(tc) ≠ Strings.code print(io, "#") end

"""
    escape(io::IO, count::Int)

Print `\\` to `io` `count` times.

# Examples

```jldoctest
julia> using Typstry: Strings.Utilities.escape

julia> escape(stdout, 1)
\\

julia> escape(stdout, 2)
\\\\
```
"""
escape(io::IO, count::Int) = join(io, repeated('\\', count))

format(::MIME"application/pdf") = "pdf"
format(::MIME"image/gif") = "gif"
format(::MIME"image/jpg") = "jpg"
format(::MIME"image/png") = "png"
format(::MIME"image/svg+xml") = "svg"
format(::MIME"image/webp") = "webp"

@doc """
    format(::Union{
        MIME"application/pdf",
        MIME"image/gif",
        MIME"image/jpg",
        MIME"image/png",
        MIME"image/svg+xml",
        MIME"image/webp"
    })

Return the image format acronym corresponding to the given `MIME`.

# Examples

```jldoctest
julia> using Typstry: Strings.Utilities.format

julia> format(MIME"application/pdf"())
"pdf"

julia> format(MIME"image/png"())
"png"

julia> format(MIME"image/svg+xml"())
"svg"
```
""" format

function math_mode(f, io::IO, tc, x; kwargs...)
    _tc = setindex!(copy(tc), Strings.math, :mode)
    _io = IOContext(io, :typst_context => _tc)

    enclose((io, x; kwargs...) -> f(_io, _tc, x; kwargs...), _io, x, math_pad(tc); kwargs...)
end

function math_pad(typst_context::TypstContext)
    if Strings.mode(typst_context) == Strings.math ""
    else Strings.block(typst_context) ? "\$ " : "\$"
    end
end

show_parameters(
    io::IO, typst_context::TypstContext, callable, x, keys::Vector{Symbol}
) = Typstry.show_typst(io, Typstry.TypstFunction(typst_context, callable, x...; Iterators.map(
    Iterators.filter(key -> haskey(typst_context, key), keys)
) do key
    key => typst_context[key]
end...))

function show_image(io::IO, mime::Union{
    MIME"image/gif", MIME"image/svg+xml", MIME"image/png", MIME"image/jpg", MIME"image/webp"
}, value)
    _typst_context = typst_context(io, value)[2]
    path = tempname() * '.' * format(mime)

    open(path; write = true) do file
        show(IOContext(file, _typst_context), mime, value)
    end

    show_parameters(io, _typst_context, Typstry.TypstString(Typstry.TypstString.TypstText(:image)), (path,), [
        :alt, :fit, :format, :height, :icc, :page, :scaling, :width
    ])
end

show_raw(io::IO, typst_context::TypstContext, mime::MIME, language::Symbol, x) = show_parameters(
    io,
    setindex!(typst_context, string(language), :lang),
    Typstry.TypstString(Typstry.TypstText(:raw)),
    (show_raw(io, mime, x),),
    [:block, :lang, :align, :syntaxes, :theme]
)
show_raw(context::IO, mime::MIME"text/markdown", value) = @view sprint(
    show, mime, value; context
)[begin:(end - 1)]
show_raw(context::IO, mime::MIME, value) = sprint(show, mime, value; context)

end # Utilities
