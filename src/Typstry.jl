
module Typstry

import Base:
    IOBuffer, IOContext, ==, copy, eltype, getkey, get, iterate, length,
    mergewith, merge!, merge, read, run, setindex!, show, sizehint!

using Base: MathConstants.catalan
using Dates:
    Date, DateTime, Day, Hour, Minute, Period, Second, Time, Week,
    day, hour, minute, month, second, year
using .Docs: HTML, Text
using .Iterators: Stateful, repeated
using PrecompileTools: @compile_workload

include("contexts/contexts.jl")
include("utilities.jl")
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
    # Any[true, 1, 1.2, 1 // 2] => AbstractArray
    # Any[true 1; 1.2 1 // 2] => AbstractMatrix
    # Date(1) => Date
    # DateTime(1) => DateTime
    # Day(1) => Period
    # Time(0) => Time
    'a' => AbstractChar
    1.2 => AbstractFloat
    "a" => AbstractString
    true => Bool
    1 + 2im => Complex{Int}
    im => Complex{Bool}
    html"<p>a</p>" => HTML
    π => Irrational{:π}
    catalan => Irrational{:catalan}
    nothing => Nothing
    0:2:6 => OrdinalRange{<:Integer, <:Integer}
    1 // 2 => Rational{Int}
    true // true => Rational{Bool}
    r"[a-z]" => Regex
    1 => Signed
    StepRangeLen(0, 2, 4) => StepRangeLen{<:Integer, <:Integer, <:Integer}
    text"[\"a\"]" => Text
    (true, 1, 1.2, 1 // 2) => Tuple
    typst"[\"a\"]" => TypstString
    TypstText([1, 2, 3, 4]) => TypstText
    Typst(1) => Typst
    0xff => Unsigned
    v"1.2.3" => VersionNumber
]

compile_workload(examples)

end # Typstry
