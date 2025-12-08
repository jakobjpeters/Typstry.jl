
module Typstry

include("contexts/Contexts.jl")
using .Contexts: ContextError, DefaultIO, TypstContext, context, reset_context
export ContextError, DefaultIO, TypstContext, context, reset_context

include("Utilities.jl")

include("commands/Commands.jl")
using .Commands: TypstCommandError, TypstCommand, @run, @typst_cmd, julia_mono, Interface.run_typst
export TypstCommandError, TypstCommand, @run, @typst_cmd, julia_mono

include("strings/Strings.jl")
using .Strings:
    AbstractTypst, Mode, TypstFunction, TypstString, TypstText, Typst,
    @typst_str, code, markup, math, show_typst
export
    AbstractTypst, Mode, TypstFunction, TypstString, TypstText, Typst,
    @typst_str, code, markup, math, show_typst

include("Render.jl")
using .Render: render
export render

include("Precompile.jl")

end # Typstry
