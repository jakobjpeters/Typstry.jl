
import Base: repr

include("utilities.jl")

include("Modes.jl")

using .Modes: Mode, code, markup, math

include("show_typst.jl")

include("TypstTexts.jl")

using .TypstTexts: TypstText

include("Typsts.jl")

using .Typsts: Typst

include("TypstStrings.jl")

using .TypstStrings: TypstString, @typst_str

include("TypstFunctions.jl")
using .TypstFunctions: TypstFunction

repr(::MIME"text/typst", typst_text::TypstText; context = nothing) = TypstString(typst_text)

merge!(default_context, TypstContext(;
    backticks = 3,
    block = false,
    depth = 0,
    io = DefaultIO(),
    mode = markup,
    parenthesize = true,
    preamble = TypstString(TypstText(
        "#set page(margin: 1em, height: auto, width: auto, fill: white)\n#set text(16pt, font: \"JuliaMono\")\n"
    )),
    tab_size = 2
))
reset_context()

for (key, value) in pairs(context)
    @eval begin
        $key(tc) = unwrap(tc, $(typeof(value)), $(QuoteNode(key)))
        @doc "$($key)(tc, type, key)" $key
    end
end
