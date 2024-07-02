
module Typstry

using PrecompileTools: @compile_workload

include("Strings.jl")
using .Strings: Mode, Typst, TypstString, TypstText, @typst_str, code, markup, math, context, show_typst
export Mode, Typst, TypstString, TypstText, @typst_str, code, markup, math, context, show_typst

include("Commands.jl")
using .Commands: TypstCommand, TypstError, @typst_cmd, julia_mono, render
export TypstCommand, TypstError, @typst_cmd, julia_mono, render

"""
    compile_workload(examples)
"""
compile_workload(examples) = @compile_workload for (x, _) in examples
    typst"\(x)"
end

compile_workload(Strings.examples)

end # Typstry
