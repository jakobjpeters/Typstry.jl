
module LaTeXStringsExtension

import Typstry: show_typst
using LaTeXStrings: LaTeXString, @L_str
using Typstry: TypstContext, compile_workload, show_raw

"""
    show_typst(::IO, ::TypstContext, ::LaTeXString)

Print a raw text block in Typst format.

See also [`TypstContext`](@ref Typstry.TypstContext).

| Type          | Settings                                 | Parameters |
|:--------------|:-----------------------------------------|:-----------|
| `LaTeXString` | `:block`, `:depth`, `:mode`, `:tab_size` |            |
"""
show_typst(io::IO, tc::TypstContext, x::LaTeXString) = show_raw(
    io, tc, MIME"text/latex"(), :latex, x
)

const examples = [L"a" => LaTeXString]

compile_workload(examples)

end # module
