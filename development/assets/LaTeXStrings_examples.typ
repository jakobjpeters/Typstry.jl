#import "template.typ": module, template
#show: document => template(document)
#module("LaTeXStrings.jl", (
  "L\"$a$\"", "LaTeXString", [`block`, `depth`, `lang`, `align`, `syntaxes`, `theme`, `tab_size`], raw(
  "#raw(\n  \"$a$\",\n  block: false,\n  lang: \"latex\"\n)",
  block: false,
  lang: "typst"
), [#raw(
  "$a$",
  block: false,
  lang: "latex"
)]
))
