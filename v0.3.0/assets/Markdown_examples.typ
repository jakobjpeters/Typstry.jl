#import "template.typ": f, template

#show: document => template(document)

= Markdown.jl

#f((
    "md\"# a\"", "MD", "```markdown # A ```", [#```markdown # A ```], "```markdown # A ```", [```markdown # A ```], "#```markdown # A ```", [$#```markdown # A ```$]
))

