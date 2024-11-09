
include("show_typst.jl")
include("typst_text.jl")
include("typst.jl")
include("typst_string.jl")

_show(io::IOContext, x) = _show_typst(io, typst_context(io), x)
_show(io::IO, x) = _show_typst(io, x)

show(io::IO, ::MIME"text/typst", x::Union{Typst, TypstString, TypstText}) =
    _show(io, x)

function show(io::IO, x::Union{TypstText, Typst})
    print(io, base_type(x), "(")
    show(io, x.value)
    print(io, ")")
end

base_type(::TypstText) = TypstText
base_type(::Typst) = Typst

@doc """
    base_type(x)
""" base_type

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
