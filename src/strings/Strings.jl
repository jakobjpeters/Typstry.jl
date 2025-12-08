
module Strings

using Typstry: Contexts.TypstContexts, DefaultIO, TypstContext, Utilities.unwrap
using .TypstContexts: context, default_context, reset_context

function show_typst end
export show_typst

include("Utilities.jl")

include("Modes.jl")
using .Modes: Mode, code, markup, math
export Mode, code, markup, math

include("TypstTexts.jl")
using .TypstTexts: TypstText
export TypstText

include("TypstStrings.jl")
using .TypstStrings: TypstString, @typst_str
export TypstString, @typst_str

include("Typsts.jl")
using .Typsts: Typst
export Typst

include("ShowTypst.jl")
include("Dates.jl")

merge!(default_context, TypstContext(;
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
    end
end

include("TypstFunctions.jl")
using .TypstFunctions: TypstFunction
export TypstFunction

end # Strings
