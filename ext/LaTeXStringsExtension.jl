
module LaTeXStringsExtension

import Typstry: show_typst
using LaTeXStrings: LaTeXString, @L_str
using Typstry: Strings
using .Strings: ShowTypst.show_raw, compile_workload

# Strings

"""
    show_typst(io, ::LaTeXString)

Print in Typst format for LaTeXStrings.jl.

| Type          | Settings                                 | Parameters |
|:--------------|:-----------------------------------------|:-----------|
| `LaTeXString` | `:block`, `:depth`, `:mode`, `:tab_size` |            |
"""
show_typst(io, tc, x::LaTeXString) = show_raw(print, io, tc, x, "latex")

# Internals

const examples = [L"a" => LaTeXString]

compile_workload(examples)

end # module
