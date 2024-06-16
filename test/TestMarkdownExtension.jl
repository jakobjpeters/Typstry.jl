
module TestMarkdownExtension

using ..TestTypstry: test_modes, test_strings
using Markdown: Markdown
using Typstry

const markdown = Markdown.parse("a\\\nb")

function test()
    # test_modes(markdown, [
    #     "```markdown a\nb ```",
    #     "```markdown a\nb ```",
    #     "#```markdown a\nb ```"
    # ])

    # test_strings(markdown, "````markdown\n        a \n        b\n    `````";
    #     backticks = 4, block = true, depth = 2, indent_size = 4)
end

end # TestMarkdownExtension
