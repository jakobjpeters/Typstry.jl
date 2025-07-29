
module LaTeXStringsExtension

import Typstry: show_typst
using LaTeXStrings: LaTeXString, @L_str
using Typstry: TypstContext, compile_workload, show_raw

show_typst(io::IO, tc::TypstContext, x::LaTeXString) = show_raw(
    io, tc, MIME"text/latex"(), :latex, x
)

const examples = [L"a" => LaTeXString => [:backticks, :block, :depth, :indent, :mode]]

compile_workload(examples)

end # module
