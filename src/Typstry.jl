
module Typstry

include("utilities/Utilities.jl")
using .Utilities: ContextErrors.ContextError

include("strings/Strings.jl")
using .Strings:
    TypstContexts, TypstStrings.TypstString, Mode, TypstText, Typst,
    ShowTypst.show_typst, @typst_str, code, markup, math
using .TypstContexts: TypstContext, context, set_context

include("commands/Commands.jl")
using .Commands: Preamble, TypstCommandErrors.TypstCommandError, TypstCommands.TypstCommand,
    @typst_cmd, julia_mono, render, typst
using .Preamble: preamble, set_preamble

export
    ContextError, Mode, TypstCommandError, TypstCommand, TypstContext, TypstString, TypstText, Typst,
    @typst_cmd, @typst_str,
    code, context, julia_mono, markup, math, preamble, render, set_context, set_preamble, show_typst, typst

Strings.compile_workload(Strings.examples)

end # Typstry
