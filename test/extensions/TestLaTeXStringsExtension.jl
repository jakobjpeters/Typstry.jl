
module TestLaTeXStringsExtension

using ..TestTypstry: test_modes, test_strings
using LaTeXStrings: @L_str
using Typstry

const latex = L"a"

test_modes(latex, [
    "```latex \$a\$ ```",
    "```latex \$a\$ ```",
    "#```latex \$a\$ ```"
])

test_strings(latex, "````latex\n        \$a\$\n    ````";
    backticks = 4, block = true, depth = 1, tab_size = 4)

end # TestLaTeXStringsExtension
