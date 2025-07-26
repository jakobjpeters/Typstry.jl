
module Typstry

import Base:
    IOBuffer, ==, codeunit, copy, eltype, firstindex, getkey, get,
    isvalid, iterate, keys, lastindex, length, mergewith, merge!, merge, ncodeunits,
    pointer, read, repr, run, setindex!, showerror, show, sizehint!
using Dates:
    Date, DateTime, Day, Hour, Minute, Period, Second, Time, Week,
    day, hour, minute, month, second, year
using .Docs: HTML, Text
using .Iterators: Stateful, repeated
using .Meta: isexpr, parse
using PrecompileTools: @compile_workload

include("utilities.jl")
include("contexts/contexts.jl")
include("strings/strings.jl")

include("commands/Commands.jl")
using .Commands: TypstCommandError, TypstCommand, @typst_cmd, julia_mono, typst

include("render.jl")

export
    ContextError, DefaultIO, Mode, TypstCommandError, TypstCommand,
    TypstContext, TypstString, TypstText, Typst,
    @typst_cmd, @typst_str, code, context, julia_mono,
    markup, math, render, reset_context, show_typst, typst

"""
    examples

A constant `Vector` of Julia values and their corresponding
`Type`s implemented for [`show_typst`](@ref).
"""
const examples = [
    Any[true, 1, 1.2, 1 // 2] => AbstractArray
    'a' => AbstractChar
    1.2 => AbstractFloat
    Any[true 1; 1.2 1 // 2] => AbstractMatrix
    "a" => AbstractString
    true => Bool
    im => Complex{Bool}
    1 + 2im => Complex
    π => Irrational
    nothing => Nothing
    0:2:6 => OrdinalRange{<:Integer, <:Integer}
    1 // 2 => Rational
    r"[a-z]" => Regex
    1 => Signed
    StepRangeLen(0, 2, 4) => StepRangeLen{<:Integer, <:Integer, <:Integer}
    (true, 1, 1.2, 1 // 2) => Tuple
    Typst(1) => Typst
    typst"[\"a\"]" => TypstString
    TypstText([1, 2, 3, 4]) => TypstText
    0xff => Unsigned
    v"1.2.3" => VersionNumber
    html"<p>a</p>" => HTML
    text"[\"a\"]" => Text
    Date(1) => Date
    DateTime(1) => DateTime
    Day(1) => Period
    Time(0) => Time
]

compile_workload(examples)

end # Typstry
