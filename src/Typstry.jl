
module Typstry

import Base: show, showerror
using .Iterators: Stateful
using PrecompileTools: @compile_workload

include("utilities.jl")

include("context_errors.jl")
export ContextError

include("Strings.jl")
using .Strings: Mode, Typst, TypstString, TypstText, @typst_str, code, markup, math, context, show_typst
export Mode, Typst, TypstString, TypstText, @typst_str, code, markup, math, context, show_typst

include("Commands.jl")
using .Commands: TypstCommand, TypstCommandError, @typst_cmd, julia_mono, preamble, render, set_preamble, typst
export TypstCommand, TypstCommandError, @typst_cmd, julia_mono, preamble, render, set_preamble, typst

compile_workload(Strings.examples)

end # Typstry
