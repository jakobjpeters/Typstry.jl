
module Typstry

import Base: show, showerror
using .Iterators: Stateful
using PrecompileTools: @compile_workload
using Preferences: @delete_preferences!, @load_preference, @set_preferences!

include("utilities.jl")

include("context_errors.jl")
export ContextError

include("Strings.jl")
using .Strings:
    Mode, Typst, TypstContext, TypstString, TypstText, @typst_str,
    code, context, markup, math, set_context, show_typst
export
    Mode, Typst, TypstContext, TypstString, TypstText, @typst_str,
    code, context, markup, math, set_context, show_typst

include("Commands.jl")
using .Commands:
    TypstCommand, TypstCommandError, @typst_cmd,
    julia_mono, preamble, render, set_preamble, typst
export
    TypstCommand, TypstCommandError, @typst_cmd,
    julia_mono, preamble, render, set_preamble, typst

compile_workload(Strings.examples)

end # Typstry
