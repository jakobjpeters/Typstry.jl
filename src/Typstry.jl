
module Typstry

using PrecompileTools: @compile_workload

_unwrap(type, key, value::T) where T = value isa type ? value : throw(ContextError(type, T, key))

"""
    unwrap(io, type, key)
    unwrap(io, type, key, default)
"""
unwrap(io, type, key) = _unwrap(type, key, io[key])
unwrap(io, type, key, default) = _unwrap(type, key, get(io, key, default))

include("Strings.jl")
using .Strings: ContextError, Mode, Typst, TypstString, TypstText, @typst_str, code, markup, math, context, show_typst
export ContextError, Mode, Typst, TypstString, TypstText, @typst_str, code, markup, math, context, show_typst

include("Commands.jl")
using .Commands: TypstCommand, TypstError, @typst_cmd, julia_mono, preamble, render, set_preamble, typst
export TypstCommand, TypstError, @typst_cmd, julia_mono, preamble, render, set_preamble, typst

"""
    compile_workload(examples)

Given an iterable of value-type pairs, interpolate each value into
a `@typst_str` within a `PrecompileTools.@compile_workload` block.
"""
compile_workload(examples) = @compile_workload for (x, _) in examples
    typst"\(x)"
end

compile_workload(Strings.examples)

end # Typstry
