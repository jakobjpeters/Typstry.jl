
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
    Any[nothing, 1, 1.2, 1 // 2] => AbstractArray => [:depth, :indent, :mode]
    Any[nothing 1; 1.2 1 // 2] => AbstractMatrix => [:depth, :indent, :mode]
    'a' => AbstractChar => [:mode]
    1.2 => AbstractFloat => [:mode]
    "a" => AbstractString => [:mode]
    true => Bool => [:mode]
    1 + 2im => Complex{<:Union{
        AbstractFloat, AbstractIrrational, Rational{<:Signed}, Signed
    }} => [:mode, :parenthesize]
    false // true * im => Complex{<:Rational{<:Union{Bool, Unsigned}}} => [:mode, :parenthesize]
    im => Complex{<:Union{Bool, Unsigned}} => [:mode, :parenthesize]
    html"<p>a</p>" => HTML => [:backticks, :block, :depth, :indent, :mode]
    π => Irrational{:π} => [:mode]
    nothing => Nothing => [:mode]
    0:2:6 => OrdinalRange{<:Signed, <:Signed} => [:mode]
    true:true:true => OrdinalRange{<:Integer, <:Integer} => [:mode]
    1 // 2 => Rational{<:Signed} => [:mode, :parenthesize]
    true // true => Rational{<:Union{Bool, Unsigned}} => [:mode, :parenthesize]
    r"[a-z]" => Regex => [:mode]
    1 => Signed => [:mode]
    StepRangeLen(0, 2, 4) => StepRangeLen{<:Signed, <:Signed, <:Signed, <:Signed} => [:mode]
    StepRangeLen(true, true, true) => StepRangeLen{
        <:Integer, <:Integer, <:Integer, <:Integer
    } => [:mode]
    text"[\"a\"]" => Text => [:mode]
    (true, 1, 1.2, 1 // 2) => Tuple => [:mode]
    typst"[\"a\"]" => TypstString => Symbol[]
    TypstText([1, 2, 3, 4]) => TypstText => Symbol[]
    Typst(1) => Typst => Symbol[]
    0xff => Unsigned => [:mode]
    v"1.2.3" => VersionNumber => [:mode]
    Date(1) => Date => [:mode]
    DateTime(1) => DateTime => [:mode]
    Day(1) => Period => [:mode]
    Time(0) => Time => [:mode]
]

compile_workload(examples)

end # Typstry
