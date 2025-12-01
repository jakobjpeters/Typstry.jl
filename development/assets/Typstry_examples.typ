#import "template.typ": module, template
#show: document => template(document)
#module("Typstry.jl", (
  "Any[nothing, TypstString(TypstText(\"\\$1\\$\")), TypstString(TypstText(\"\\$1.2\\$\")), 1//2]", "AbstractArray", [`block`, `depth`, `indent`, `mode`], raw(
  "#math.vec(\n  none,\n  $1$,\n  $1.2$,\n  $1 / 2$\n)",
  block: false,
  lang: "typst"
), [#math.vec(
  none,
  $1$,
  $1.2$,
  $1 / 2$
)],
  "Any[nothing 1; 1.2 1//2]", "AbstractMatrix", [`block`, `depth`, `indent`, `mode`], raw(
  "#math.mat(\n  (\n    none,\n    1\n  ),\n  (\n    1.2,\n    $1 / 2$\n  )\n)",
  block: false,
  lang: "typst"
), [#math.mat(
  (
    none,
    1
  ),
  (
    1.2,
    $1 / 2$
  )
)],
  "'a'", "AbstractChar", [`mode`], raw(
  "#\"a\"",
  block: false,
  lang: "typst"
), [#"a"],
  "1.2", "AbstractFloat", [`block`, `mode`], raw(
  "$1.2$",
  block: false,
  lang: "typst"
), [$1.2$],
  "\"a\"", "AbstractString", [`mode`], raw(
  "#\"a\"",
  block: false,
  lang: "typst"
), [#"a"],
  "true", "Bool", [`mode`], raw(
  "#true",
  block: false,
  lang: "typst"
), [#true],
  "1 + 2im", "Complex{<:Union{AbstractIrrational, AbstractFloat, Signed, Rational{<:Signed}}}", [`block`, `mode`, `parenthesize`], raw(
  "$1 + 2i$",
  block: false,
  lang: "typst"
), [$1 + 2i$],
  "false//true + false//true*im", "Complex{<:Rational{<:Union{Bool, Unsigned}}}", [`block`, `mode`, `parenthesize`], raw(
  "$(0 / 1) + (0 / 1)i$",
  block: false,
  lang: "typst"
), [$(0 / 1) + (0 / 1)i$],
  "im", "Complex{<:Union{Bool, Unsigned}}", [`block`, `mode`, `parenthesize`], raw(
  "$0 + 1i$",
  block: false,
  lang: "typst"
), [$0 + 1i$],
  "HTML{String}(\"<p>a</p>\")", "HTML", [`backticks`, `block`, `depth`, `indent`, `mode`], raw(
  "#raw(\n  \"<p>a</p>\",\n  block: false,\n  lang: \"html\"\n)",
  block: false,
  lang: "typst"
), [#raw(
  "<p>a</p>",
  block: false,
  lang: "html"
)],
  "π", "Irrational{:π}", [`block`, `mode`], raw(
  "$π$",
  block: false,
  lang: "typst"
), [$π$],
  "(a = 1, b = 2)", "NamedTuple", [`indent`, `depth`, `mode`], raw(
  "#(\n  a: 1,\n  b: 2\n)",
  block: false,
  lang: "typst"
), [#(
  a: 1,
  b: 2
)],
  "nothing", "Nothing", [`mode`], raw(
  "#none",
  block: false,
  lang: "typst"
), [#none],
  "0:2:6", "OrdinalRange{<:Signed, <:Signed}", [`mode`], raw(
  "#range(\n  0,\n  7,\n  step: 2\n)",
  block: false,
  lang: "typst"
), [#range(
  0,
  7,
  step: 2
)],
  "true:true:true", "OrdinalRange{<:Integer, <:Integer}", [`mode`], raw(
  "#range(\n  1,\n  2\n)",
  block: false,
  lang: "typst"
), [#range(
  1,
  2
)],
  "1//2", "Rational{<:Signed}", [`block`, `mode`, `parenthesize`], raw(
  "$1 / 2$",
  block: false,
  lang: "typst"
), [$1 / 2$],
  "true//true", "Rational{<:Union{Bool, Unsigned}}", [`mode`, `parenthesize`], raw(
  "$1 / 1$",
  block: false,
  lang: "typst"
), [$1 / 1$],
  "r\"[a-z]\"", "Regex", [`mode`], raw(
  "#regex(\n  \"[a-z]\"\n)",
  block: false,
  lang: "typst"
), [#regex(
  "[a-z]"
)],
  "1", "Signed", [`mode`], raw(
  "$1$",
  block: false,
  lang: "typst"
), [$1$],
  "0:2:6", "StepRangeLen{<:Signed, <:Signed, <:Signed, <:Signed}", [`mode`], raw(
  "#range(\n  0,\n  7,\n  step: 2\n)",
  block: false,
  lang: "typst"
), [#range(
  0,
  7,
  step: 2
)],
  "1:true:1", "StepRangeLen{<:Integer, <:Integer, <:Integer}", [`mode`], raw(
  "#range(\n  1,\n  2\n)",
  block: false,
  lang: "typst"
), [#range(
  1,
  2
)],
  ":a", "Symbol", [`block`, `mode`], raw(
  "$\"a\"$",
  block: false,
  lang: "typst"
), [$"a"$],
  "[\"a\"]", "Text", [`mode`], raw(
  "#\"[\\\"a\\\"]\"",
  block: false,
  lang: "typst"
), [#"[\"a\"]"],
  "(true, 1, 1.2, 1//2)", "Tuple", [`mode`], raw(
  "#(\n  true,\n  1,\n  1.2,\n  $1 / 2$\n)",
  block: false,
  lang: "typst"
), [#(
  true,
  1,
  1.2,
  $1 / 2$
)],
  "TypstFunction{Tuple{Tuple{Int64, Int64}, @NamedTuple{a::Int64, b::Int64}}}(0, markup, 2, TypstString(TypstText(\"arguments\")), ((1, 2), (a = 3, b = 4)), Base.Pairs{Symbol, Union{}, Nothing, @NamedTuple{}}())", "TypstFunction", [`depth`, `indent`, `mode`], raw(
  "#arguments(\n  (\n    1,\n    2\n  ),\n  (\n    a: 3,\n    b: 4\n  )\n)",
  block: false,
  lang: "typst"
), [#arguments(
  (
    1,
    2
  ),
  (
    a: 3,
    b: 4
  )
)],
  "TypstString(TypstText(\"[\\\"a\\\"]\"))", "TypstString", [], raw(
  "[\"a\"]",
  block: false,
  lang: "typst"
), [["a"]],
  "TypstText{Vector{Int64}}([1, 2, 3, 4])", "TypstText", [], raw(
  "[1, 2, 3, 4]",
  block: false,
  lang: "typst"
), [[1, 2, 3, 4]],
  "Typst{Int64}(1)", "Typst", [], raw(
  "$1$",
  block: false,
  lang: "typst"
), [$1$],
  "0xff", "Unsigned", [`mode`], raw(
  "#0xff",
  block: false,
  lang: "typst"
), [#0xff],
  "v\"1.2.3\"", "VersionNumber", [`mode`], raw(
  "#version(\n  1,\n  2,\n  3\n)",
  block: false,
  lang: "typst"
), [#version(
  1,
  2,
  3
)],
  "Dates.Date(\"0001-01-01\")", "Dates.Date", [`mode`], raw(
  "#datetime(\n  year: 1,\n  month: 1,\n  day: 1\n)",
  block: false,
  lang: "typst"
), [#datetime(
  year: 1,
  month: 1,
  day: 1
)],
  "Dates.DateTime(\"0001-01-01T00:00:00\")", "Dates.DateTime", [`mode`], raw(
  "#datetime(\n  year: 1,\n  month: 1,\n  day: 1,\n  hour: 0,\n  minute: 0,\n  second: 0\n)",
  block: false,
  lang: "typst"
), [#datetime(
  year: 1,
  month: 1,
  day: 1,
  hour: 0,
  minute: 0,
  second: 0
)],
  "Dates.Day(1)", "Dates.Period", [`mode`], raw(
  "#duration(\n  days: 1\n)",
  block: false,
  lang: "typst"
), [#duration(
  days: 1
)],
  "Dates.Time(0)", "Dates.Time", [`mode`], raw(
  "#datetime(\n  hour: 0,\n  minute: 0,\n  second: 0\n)",
  block: false,
  lang: "typst"
), [#datetime(
  hour: 0,
  minute: 0,
  second: 0
)]
))
