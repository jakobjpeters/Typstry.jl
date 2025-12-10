
module ShowTypst

using Typstry: TypstContext, Contexts.TypstContexts.typst_context
using ..Strings: Utilities.show_image

export show_typst

const typst, gif, svg, png, jpg, webp = Iterators.map(MIME, ["text/typst", ("image/" .* (
    "gif", "svg+xml", "png", "jpg", "webp"
))...])

function show_typst(io::IO, ::TypstContext, value)
    if showable(typst, value) show(io, typst, value)
    elseif showable(gif, value) show_image(io, gif, value)
    elseif showable(svg, value) show_image(io, svg, value)
    elseif showable(png, value) show_image(io, png, value)
    elseif showable(jpg, value) show_image(io, jpg, value)
    elseif showable(webp, value) show_image(io, webp, value)
    else show_typst(io, repr(value))
    end
end
show_typst(_typst_context::TypstContext, value) = show_typst(
    typst_context(_typst_context, value)...
)
show_typst(io::IO, value; _typst_context...) = show_typst(
    typst_context(io, TypstContext(; _typst_context...), value)...
)
show_typst(value; _typst_context...) = show_typst(
    typst_context(TypstContext(; _typst_context...), value)...
)

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
