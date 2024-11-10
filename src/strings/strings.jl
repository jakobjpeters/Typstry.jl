
include("mode.jl")
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

"""
    default_io_context
"""
const default_io_context = Dict{Symbol, Any}(:compact => true)

base_type(::TypstText) = TypstText
base_type(::Typst) = Typst

@doc """
    base_type(x)
""" base_type

merge!(default_context, TypstContext(;
    backticks = 3,
    block = false,
    depth = 0,
    io_context = default_io_context,
    mode = markup,
    parenthesize = true,
    preamble = TypstString(TypstText(
    "#set page(margin: 1em, height: auto, width: auto, fill: white)\n#set text(16pt, font: \"JuliaMono\")\n")),
    tab_size = 2
))
reset_context()

for (key, value) in pairs(context)
    @eval begin
        $key(tc) = unwrap(tc, $(typeof(value)), $(QuoteNode(key)))
        @doc "$($key)" $key
    end
end
