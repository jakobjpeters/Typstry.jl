
module Strings

using Typstry: Contexts.TypstContexts.default_context, reset_context

include("Utilities.jl")

include("Modes.jl")
using .Modes: Mode, code, markup, math
export Mode, code, markup, math

include("AbstractTypsts.jl")
using .AbstractTypsts:
    AbstractTypst, TypstFunction, TypstImage, TypstMode, TypstRaw, TypstText, Typst,
    lower, show_typst
export
    AbstractTypst, TypstFunction, TypstImage, TypstMode, TypstRaw, TypstText, Typst,
    lower, show_typst

include("TypstStrings.jl")
using .TypstStrings: TypstString, @typst_str
export TypstString, @typst_str

include("Interface.jl")
# include("Dates.jl")

end # Strings
