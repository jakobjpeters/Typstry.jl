#import "template.typ": module, template
#show: document => template(document)
#module("Markdown.jl", (
    "md\"# A\"", "MD", [`backticks`, `block`, `depth`, `indent`, `mode`], ````typst ```markdown # A ``` ````, [```markdown # A ```]
))
