
module LaTeXStringsExtension

import Typstry: show_typst
using LaTeXStrings: LaTeXString
using Typstry: show_raw

"""
    show_typst(io, ::LaTeXString)

Print in Typst format for LaTeXStrings.jl.

| Type          | Settings | Parameters |
|:--------------|:---------|:-----------|
| `LaTeXString` | `:mode`  | `:block`   |
"""
show_typst(io, x::LaTeXString) = show_raw(print, io, x, "latex")

end # module
