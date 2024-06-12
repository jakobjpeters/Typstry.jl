#import "template.typ": f, template

#show: document => template(document)

= LaTeXStrings.jl

#f((
    "L\"a\"", `LaTeXString`, ````typc ```latex $a$ ``` ````, [#```latex $a$ ```], ````typ ```latex $a$ ``` ````, [```latex $a$ ```], ````typc #```latex $a$ ``` ````, [$#```latex $a$ ```$]
))

