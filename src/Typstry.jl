
module Typstry

import Base:
    IOBuffer, IOContext, ==, copy, eltype, getkey, get, iterate, length,
    mergewith, merge!, merge, run, setindex!, show, sizehint!

using Base: MathConstants.catalan
using Dates:
    Date, DateTime, Day, Hour, Minute, Period, Second, Time, Week,
    day, hour, minute, month, second, year
using .Iterators: Stateful, repeated
using PrecompileTools: @compile_workload

include("contexts/contexts.jl")
include("utilities.jl")

include("commands/Commands.jl")
using .Commands: TypstCommandError, TypstCommand, @typst_cmd, julia_mono, run_typst, typst

include("strings/strings.jl")
include("render.jl")
include("Precompile.jl")

export
    ContextError, DefaultIO, Mode, TypstCommandError, TypstCommand,
    TypstContext, TypstFunction, TypstString, TypstText, Typst,
    @typst_cmd, @typst_str, code, context, julia_mono,
    markup, math, render, reset_context, show_typst, typst

end # Typstry
