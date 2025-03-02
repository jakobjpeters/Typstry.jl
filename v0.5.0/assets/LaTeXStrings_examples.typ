#import "template.typ": f, template

#show: document => template(document)

= LaTeXStrings.jl

#f((
    "L\"a\"", "LaTeXString", "```latex $a$ ```", [#```latex $a$ ```], "```latex $a$ ```", [```latex $a$ ```], "#```latex $a$ ```", [$#```latex $a$ ```$]
))

