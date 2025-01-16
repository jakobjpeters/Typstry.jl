
module LaTeXStringsExtension

import Typstry: show_typst
using LaTeXStrings: LaTeXString, @L_str
using Typstry: compile_workload, show_raw
import Typstry: show_raw, backticks, indent, block, mode, enclose, math

"""
    show_typst(::IO, ::TypstContext, ::LaTeXString)

Print a raw text block in Typst format.

See also [`TypstContext`](@ref Typstry.TypstContext).

| Type          | Settings                                 | Parameters |
|:--------------|:-----------------------------------------|:-----------|
| `LaTeXString` | `:block`, `:depth`, `:mode`, `:tab_size` |            |
"""
show_typst(io, tc, x::LaTeXString) = show_raw(print, io, tc, x, "latex")

"""
    show_raw(f, io, tc, x, language)
"""
function show_raw(f, io, tc, x::LaTeXString, language)
    _backticks, _block = "`" ^ backticks(tc), block(tc)

    print(io, "#mi(")
    print(io, _backticks, language)

    if _block
        _indent, _depth = indent(tc), depth(tc)

        print(io, "\n")

        for line in eachsplit(sprint(f, x), "\n")
            println(io, _indent ^ (_depth + 1), line)
        end

        print(io, _indent ^ _depth)
    else enclose(f, io, x, " ")
    end

    print(io, _backticks)
    print(io, ")")
end

const examples = [L"a" => LaTeXString]

compile_workload(examples)

end # module
