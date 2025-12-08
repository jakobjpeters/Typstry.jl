
module Strings

using Typstry: Contexts.TypstContexts, TypstContext, Utilities.unwrap
using .TypstContexts: TypstContext, default_context, context, reset_context

include("Utilities.jl")
using .Utilities: typst_context

show_typst(io::IO, value; context...) = show_typst(
    typst_context(io, TypstContext(; context...), value)...
)
export show_typst

include("Modes.jl")
using .Modes: Mode, code, markup, math
export Mode, code, markup, math

include("TypstStrings.jl")
using .TypstStrings: TypstString, @typst_str
export TypstString, @typst_str

include("AbstractTypsts.jl")
using .AbstractTypsts: AbstractTypst, TypstFunction, TypstText, Typst
export AbstractTypst, TypstFunction, TypstText, Typst

include("ShowTypst.jl")
include("Dates.jl")

function __init__()
    default_context[:preamble] = TypstString(TypstText("""
    #set page(margin: 1em, height: auto, width: auto, fill: white)
    #set text(16pt, font: \"JuliaMono\")
    """))
    reset_context()
end

end # Strings
