
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

include("commands/Commands.jl")
using .Commands: TypstCommandError, TypstCommand, @typst_cmd, julia_mono, run_typst, typst

include("strings/strings.jl")
include("render.jl")

_typst(value) = value
function _typst(value::Expr)
    (; head, args) = value

    if head == :$ only(args)
    elseif head == :macrocall value
    else :(Expr($(QuoteNode(head)), $(_typst.(args)...)))
    end
end
_typst(value::Symbol) = :((@isdefined $value) ? $value : ($(QuoteNode(value))))

"""
    (@typst value typst_context...)::TypstString

Transpile a subset of Julia to Typst.

The `value` is first processed, then passed to
[`TypstString`](@ref) with the `typst_context`.

# Examples

A symbol returns its assignment, if it exists, otherwise itself

```jldoctest
julia> x = 1;

julia> @typst x + y
typst"\$(1 + \\\"y\\\")\$"
```

Other literal values, macro call expressions, and interpolation
expressions are evaluated, returning the result

```jldoctest
julia> @typst "hi"
typst"#\\\"hi\\\""

julia> @typst typst"hi"
typst"hi"

julia> @typst \$(1 + 2)
typst"\$3\$"
```

All other expressions are processed recursively, returning an `Expr`

```jldoctest
julia> @typst (1 + im ^ 2) / f(3)
typst"\$((1 + (i ^ 2)) / (\\\"f\\\" (3)))\$"
```
"""
macro typst(value, typst_context...)
    :(TypstString($(esc(_typst(value))); $(esc.(typst_context)...)))
end

export @typst

export
    ContextError, DefaultIO, Mode, TypstCommandError, TypstCommand,
    TypstContext, TypstFunction, TypstString, TypstText, Typst,
    @typst_cmd, @typst_str, code, context, julia_mono,
    markup, math, render, reset_context, show_typst, typst

"""
    examples

A constant `Vector` of Julia values and their corresponding
`Type`s implemented for [`show_typst`](@ref).
"""
const examples = [
    Any[nothing, 1, 1.2, 1 // 2] => AbstractArray => [:block, :depth, :indent, :mode]
    Any[nothing 1; 1.2 1 // 2] => AbstractMatrix => [:block, :depth, :indent, :mode]
    'a' => AbstractChar => [:mode]
    1.2 => AbstractFloat => [:block, :mode]
    "a" => AbstractString => [:mode]
    true => Bool => [:mode]
    1 + 2im => Complex{<:Union{
        AbstractFloat, AbstractIrrational, Rational{<:Signed}, Signed
    }} => [:block, :mode, :parenthesize]
    false // true * im => Complex{<:Rational{<:Union{Bool, Unsigned}}} => [
        :block, :mode, :parenthesize
    ]
    im => Complex{<:Union{Bool, Unsigned}} => [:block, :mode, :parenthesize]
    html"<p>a</p>" => HTML => [:backticks, :block, :depth, :indent, :mode]
    π => Irrational{:π} => [:block, :mode]
    nothing => Nothing => [:mode]
    0:2:6 => OrdinalRange{<:Signed, <:Signed} => [:mode]
    true:true:true => OrdinalRange{<:Integer, <:Integer} => [:mode]
    1 // 2 => Rational{<:Signed} => [:block, :mode, :parenthesize]
    true // true => Rational{<:Union{Bool, Unsigned}} => [:mode, :parenthesize]
    r"[a-z]" => Regex => [:mode]
    1 => Signed => [:mode]
    StepRangeLen(0, 2, 4) => StepRangeLen{<:Signed, <:Signed, <:Signed, <:Signed} => [:mode]
    StepRangeLen(true, true, true) => StepRangeLen{
        <:Integer, <:Integer, <:Integer, <:Integer
    } => [:mode]
    :a => Symbol => [:block, :mode]
    text"[\"a\"]" => Text => [:mode]
    (true, 1, 1.2, 1 // 2) => Tuple => [:mode]
    TypstFunction(:+, (1, 2)) => TypstFunction => [:block, :mode]
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
