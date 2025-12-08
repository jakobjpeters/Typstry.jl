
module LaTeXStringsExtension

import Typstry: show_typst
using LaTeXStrings: LaTeXString, @L_str
using Typstry: TypstContext, Precompile.compile_workload, Strings.show_raw

show_typst(io::IO, tc::TypstContext, x::LaTeXString) = show_raw(
    io, tc, MIME"text/latex"(), :latex, x
)

const examples = [L"a" => LaTeXString => [
    :block, :depth, :lang, :align, :syntaxes, :theme, :tab_size
]]

compile_workload(examples)

end # module
