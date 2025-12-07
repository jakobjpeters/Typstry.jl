
module Typstry

# TODO:
using Base: MathConstants.catalan
using Dates:
    Date, DateTime, Day, Hour, Minute, Period, Second, Time, Week,
    day, hour, minute, month, second, year
using .Iterators: repeated

include("contexts/Contexts.jl")
using .Contexts: ContextError, DefaultIO, TypstContext, context, reset_context
export ContextError, DefaultIO, TypstContext, context, reset_context

include("Utilities.jl")
using .Utilities: enclose, typst_context, unwrap

include("commands/Commands.jl")
using .Commands: TypstCommandError, TypstCommand, @run, @typst_cmd, julia_mono, Interface.run_typst
export TypstCommandError, TypstCommand, @run, @typst_cmd, julia_mono

include("strings/strings.jl")
export
    Mode, TypstFunction, TypstString, TypstText, Typst,
    @typst_str, code, markup, math, show_typst

include("Render.jl")
using .Render: render
export render

include("Precompile.jl")

end # Typstry
