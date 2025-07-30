#import "template.typ": module, template
#show: document => template(document)
#module("LaTeXStrings.jl", (
    "L\"$a$\"", "LaTeXString", [`backticks`, `block`, `depth`, `indent`, `mode`], ````typst ```latex $a$ ``` ````, [```latex $a$ ```]
))
