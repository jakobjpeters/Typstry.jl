
include("types.jl")
include("typst_context.jl")
include("typst_string.jl")
include("show_typst.jl")

"""
    show(::IO, ::MIME"text/typst", ::Union{Typst, TypstString, TypstText})

Print in Typst format using [`show_typst`](@ref) and
formatting data specified by a [`TypstContext`](@ref).

The formatting data is given by combining the [`context`](@ref),
the `TypstContext` constructor implemented for the given type,
and the `IOContext` key `:typst_context` such that each successive
context overwrites duplicate keys in previous contexts.

See also [`TypstString`](@ref) and [`TypstText`](@ref).
"""
show(io::IO, ::MIME"text/typst", t::Union{Typst, TypstString, TypstText}) =
    _show_typst(io, t)
show(io::IOContext, ::MIME"text/typst", t::Union{Typst, TypstString, TypstText}) =
    _show_typst(io, typst_context(io), t)

function show(io::IO, x::T) where T <: Union{TypstText, Typst}
    print(io, nameof(T), "(")
    show(io, x.value)
    print(io, ")")
end

get!(context.context, :preamble, typst"""
#set page(margin: 1em, height: auto, width: auto, fill: white)
#set text(16pt, font: "JuliaMono")
""")

for (key, value) in pairs(context)
    @eval begin
        $key(tc) = unwrap(tc, $(typeof(value)), $(QuoteNode(key)))
        @doc "$($key)" $key
    end
end
