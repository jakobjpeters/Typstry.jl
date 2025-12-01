
module TestMarkdownExtension

using ..TestTypstry: test_modes, test_strings
using Markdown: @md_str

const markdown = md"a"

test_modes(markdown, [
    """raw(
      "a",
      block: false,
      lang: "markdown"
    )"""
    """#raw(
      "a",
      block: false,
      lang: "markdown"
    )"""
    """#raw(
      "a",
      block: false,
      lang: "markdown"
    )"""
])

test_strings(
    markdown,
    """#raw(
        "a",
        block: true,
        lang: "markdown"
    )""";
    block = true,
    tab_size = 4
)

end # TestMarkdownExtension
