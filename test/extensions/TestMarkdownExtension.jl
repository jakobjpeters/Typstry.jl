
module TestMarkdownExtension

using ..TestTypstry: test_modes, test_strings
using Markdown: @md_str

const markdown = md"""a\
b"""

test_modes(markdown, [
    "```markdown a\nb ```"
    "```markdown a\nb ```"
    "#```markdown a\nb ```"
])

test_strings(
    markdown,
    "````markdown\n    a\n    b\n    ````";
    backticks = 4,
    block = true,
    depth = 1,
    tab_size = 4
)

end # TestMarkdownExtension
