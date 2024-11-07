
module Typstry

include("utilities.jl")

include("Strings.jl")
using .Strings: ContextError, Mode, Typst, TypstString, TypstText, @typst_str, code, markup, math, context, show_typst
export ContextError, Mode, Typst, TypstString, TypstText, @typst_str, code, markup, math, context, show_typst

include("Commands.jl")
using .Commands: TypstCommand, TypstError, @typst_cmd, julia_mono, preamble, render, set_preamble, typst
export TypstCommand, TypstError, @typst_cmd, julia_mono, preamble, render, set_preamble, typst

compile_workload(Strings.examples)

end # Typstry
