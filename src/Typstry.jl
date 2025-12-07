
module Typstry

import Base:
    IOBuffer, IOContext, ==, copy, eltype, getkey, get, iterate, length,
    mergewith, merge!, merge, setindex!, show, sizehint!

using Base: MathConstants.catalan
using Dates:
    Date, DateTime, Day, Hour, Minute, Period, Second, Time, Week,
    day, hour, minute, month, second, year
using .Iterators: Stateful, repeated
using PrecompileTools: @compile_workload

include("contexts/contexts.jl")
export ContextError, DefaultIO, TypstContext

include("utilities.jl")

include("commands/Commands.jl")
using .Commands: TypstCommandError, TypstCommand, @run, @typst_cmd, julia_mono, Interface.run_typst
export TypstCommandError, TypstCommand, @run, @typst_cmd, julia_mono

include("strings/strings.jl")
export
    Mode, TypstFunction, TypstString, TypstText, Typst,
    @typst_str, code, context,
    markup, math, reset_context, show_typst

include("Render.jl")
using .Render: render
export render

include("Precompile.jl")

end # Typstry
