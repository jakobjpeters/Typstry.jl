#import "template.typ": f, template

#show: document => template(document)

= Markdown.jl

#f((
    "md\"# a\"", `MD`, ````typc ```markdown # A ``` ````, [#```markdown # A ```], ````typ ```markdown # A ``` ````, [```markdown # A ```], ````typc #```markdown # A ``` ````, [$#```markdown # A ```$]
))

