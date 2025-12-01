
module TestLaTeXStringsExtension

using ..TestTypstry: test_modes, test_strings
using LaTeXStrings: @L_str

const latex = L""

test_modes(latex, [
    """raw(
      "\$\$",
      block: false,
      lang: "latex"
    )"""
    """#raw(
      "\$\$",
      block: false,
      lang: "latex"
    )"""
    """#raw(
      "\$\$",
      block: false,
      lang: "latex"
    )"""
])

test_strings(
    latex,
    """#raw(
        "\$\$",
        block: true,
        lang: "latex"
    )""";
    block = true,
    tab_size = 4
)
const latex = L"a"

end # TestLaTeXStringsExtension
