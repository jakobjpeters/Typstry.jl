
module Typstry

import Base:
    IOBuffer, ==, addenv, codeunit, detach, eltype, firstindex, getindex, get, hash, ignorestatus, isvalid, iterate,
    keys, lastindex, length, ncodeunits, pointer, repr, run, setcpuaffinity, setenv, showerror, show
import Typst_jll
using Artifacts: @artifact_str
using Dates:
    Date, DateTime, Day, Hour, Minute, Period, Second, Time, Week,
    day, hour, minute, month, second, year
using .Docs: HTML, Text
using .Iterators: Stateful
using .Meta: isexpr, parse
using PrecompileTools: @compile_workload
using Preferences: @load_preference, @set_preferences!

include("utilities/utilities.jl")
include("strings/strings.jl")
include("commands/commands.jl")

export
    ContextError, Mode, TypstCommandError, TypstCommand,
    TypstContext, TypstString, TypstText, Typst,
    @typst_cmd, @typst_str, code, context, julia_mono,
    markup, math, render, set_context, show_typst, typst

compile_workload(examples)

end # Typstry
