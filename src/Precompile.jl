
module Precompile

using Dates: DateTime, Date, Day, Period, Time
using .Docs: HTML, Text
using PrecompileTools: @compile_workload
using Typstry: TypstFunction, TypstString, TypstText, Typst, @typst_str, context, render

export examples, compile_workload

const examples = [
    Any[nothing, typst"$1$", typst"$1.2$", 1 // 2] => AbstractArray => [:block, :depth, :indent, :mode]
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
    (; a = 1, b = 2) => NamedTuple => [:indent, :depth, :mode]
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
    TypstFunction(context, typst"") => TypstFunction => [:depth, :indent, :mode, :tab_size]
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

"""
    compile_workload(examples)
"""
compile_workload(examples) = @compile_workload for example ∈ examples
    render(first(example); open = false)
end

compile_workload(examples)

end # Precompile
