
module LaTeXStringsExtension

import Typstry: lower

using LaTeXStrings: LaTeXString, @L_str
using Typstry: TypstRaw, Precompile.compile_workload

lower(latex_string::LaTeXString) = TypstRaw(MIME"text/latex"(), :latex, latex_string)

const examples = []

function __init__()
    push!(examples, L"a" => LaTeXString => [
        :block, :depth, :lang, :align, :syntaxes, :theme, :tab_size
    ])
    compile_workload(examples)
end

end # module
