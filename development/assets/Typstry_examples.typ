#import "template.typ": module, template
#show: document => template(document)
#module("Typstry.jl", (
    "Any[nothing, 1, 1.2, 1//2]", "AbstractArray", [`block`, `depth`, `indent`, `mode`], ````typst $vec(
  #none, 1, 1.2, 1 / 2
)$ ````, [$vec(
  #none, 1, 1.2, 1 / 2
)$],
    "Any[nothing 1; 1.2 1//2]", "AbstractMatrix", [`block`, `depth`, `indent`, `mode`], ````typst $mat(
  #none, 1;
  1.2, 1 / 2
)$ ````, [$mat(
  #none, 1;
  1.2, 1 / 2
)$],
    "'a'", "AbstractChar", [`mode`], ````typst #"a" ````, [#"a"],
    "1.2", "AbstractFloat", [`block`, `mode`], ````typst $1.2$ ````, [$1.2$],
    "\"a\"", "AbstractString", [`mode`], ````typst #"a" ````, [#"a"],
    "true", "Bool", [`mode`], ````typst #true ````, [#true],
    "1 + 2im", "Complex{<:Union{AbstractIrrational, AbstractFloat, Signed, Rational{<:Signed}}}", [`block`, `mode`, `parenthesize`], ````typst $1 + 2i$ ````, [$1 + 2i$],
    "false//true + false//true*im", "Complex{<:Rational{<:Union{Bool, Unsigned}}}", [`block`, `mode`, `parenthesize`], ````typst $(0 / 1) + (0 / 1)i$ ````, [$(0 / 1) + (0 / 1)i$],
    "im", "Complex{<:Union{Bool, Unsigned}}", [`mode`, `parenthesize`], ````typst $0 + 1i$ ````, [$0 + 1i$],
    "HTML{String}(\"<p>a</p>\")", "HTML", [`backticks`, `block`, `depth`, `indent`, `mode`], ````typst ```html <p>a</p> ``` ````, [```html <p>a</p> ```],
    "π", "Irrational{:π}", [`block`, `mode`], ````typst $π$ ````, [$π$],
    "nothing", "Nothing", [`mode`], ````typst #none ````, [#none],
    "0:2:6", "OrdinalRange{<:Signed, <:Signed}", [`mode`], ````typst #range(0, 7, step: 2) ````, [#range(0, 7, step: 2)],
    "true:true:true", "OrdinalRange{<:Integer, <:Integer}", [`mode`], ````typst #range(1, 2) ````, [#range(1, 2)],
    "1//2", "Rational{<:Signed}", [`block`, `mode`, `parenthesize`], ````typst $1 / 2$ ````, [$1 / 2$],
    "true//true", "Rational{<:Union{Bool, Unsigned}}", [`mode`, `parenthesize`], ````typst $1 / 1$ ````, [$1 / 1$],
    "r\"[a-z]\"", "Regex", [`mode`], ````typst #regex("[a-z]") ````, [#regex("[a-z]")],
    "1", "Signed", [`mode`], ````typst $1$ ````, [$1$],
    "0:2:6", "StepRangeLen{<:Signed, <:Signed, <:Signed, <:Signed}", [`mode`], ````typst #range(0, 7, step: 2) ````, [#range(0, 7, step: 2)],
    "1:true:1", "StepRangeLen{<:Integer, <:Integer, <:Integer}", [`mode`], ````typst #range(1, 2) ````, [#range(1, 2)],
    ":a", "Symbol", [`block`, `mode`], ````typst $"a"$ ````, [$"a"$],
    "[\"a\"]", "Text", [`mode`], ````typst #"[\"a\"]" ````, [#"[\"a\"]"],
    "(true, 1, 1.2, 1//2)", "Tuple", [`mode`], ````typst #(true, 1, $1.2$, $1 / 2$) ````, [#(true, 1, $1.2$, $1 / 2$)],
    "typst\"[\\\"a\\\"]\"", "TypstString", [], ````typst ["a"] ````, [["a"]],
    "TypstText{Vector{Int64}}([1, 2, 3, 4])", "TypstText", [], ````typst [1, 2, 3, 4] ````, [[1, 2, 3, 4]],
    "Typst{Int64}(1)", "Typst", [], ````typst $1$ ````, [$1$],
    "0xff", "Unsigned", [`mode`], ````typst #0xff ````, [#0xff],
    "v\"1.2.3\"", "VersionNumber", [`mode`], ````typst #version(1, 2, 3) ````, [#version(1, 2, 3)],
    "Dates.Date(\"0001-01-01\")", "Dates.Date", [`mode`], ````typst #datetime(
  year: 1,
  month: 1,
  day: 1
) ````, [#datetime(
  year: 1,
  month: 1,
  day: 1
)],
    "Dates.DateTime(\"0001-01-01T00:00:00\")", "Dates.DateTime", [`mode`], ````typst #datetime(
  year: 1,
  month: 1,
  day: 1,
  hour: 0,
  minute: 0,
  second: 0
) ````, [#datetime(
  year: 1,
  month: 1,
  day: 1,
  hour: 0,
  minute: 0,
  second: 0
)],
    "Dates.Day(1)", "Dates.Period", [`mode`], ````typst #duration(
  days: 1
) ````, [#duration(
  days: 1
)],
    "Dates.Time(0)", "Dates.Time", [`mode`], ````typst #datetime(
  hour: 0,
  minute: 0,
  second: 0
) ````, [#datetime(
  hour: 0,
  minute: 0,
  second: 0
)]
))
