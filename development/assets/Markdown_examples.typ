#import "template.typ": module, template
#show: document => template(document)
#module("Markdown.jl", (
  "md\"# A\"", "MD", [`block`, `depth`, `lang`, `align`, `syntaxes`, `theme`, `tab_size`], raw(
  "#raw(\n  \"# A\",\n  block: false,\n  lang: \"markdown\"\n)",
  block: false,
  lang: "typst"
), [#raw(
  "# A",
  block: false,
  lang: "markdown"
)]
))
