#import "template.typ": f, template

#show: document => template(document)

= Typstry.jl

#f((
    "Any[true, 1, 1.2, 1//2]", "AbstractArray",
        "(true, 1, 1.2, 1 / 2)", [#(true, 1, 1.2, 1 / 2)], "$vec(\n  \"true\", 1, 1.2, 1 / 2\n)$", [$vec(
      "true", 1, 1.2, 1 / 2
    )$], "vec(\n  \"true\", 1, 1.2, 1 / 2\n)", [$vec(
      "true", 1, 1.2, 1 / 2
    )$],
    "'a'", "AbstractChar", "\"a\"", [#"a"], "\"a\"", ["a"], "\"a\\u{200b}\"", [$"a\u{200b}"$],
    "1.2", "AbstractFloat", "1.2", [#1.2], "$1.2$", [$1.2$], "1.2", [$1.2$],
    "Any[true 1; 1.2 1//2]", "AbstractMatrix",
        "(true, 1.2, 1, 1 / 2)", [#(true, 1.2, 1, 1 / 2)], "$mat(\n  \"true\", 1;\n  1.2, 1 / 2\n)$", [$mat(
      "true", 1;
      1.2, 1 / 2
    )$], "mat(\n  \"true\", 1;\n  1.2, 1 / 2\n)", [$mat(
      "true", 1;
      1.2, 1 / 2
    )$],
    "\"a\"", "AbstractString", "\"a\"", [#"a"], "\"a\"", ["a"], "\"a\\u{200b}\"", [$"a\u{200b}"$],
    "true", "Bool", "true", [#true], "true", [true], "\"true\"", [$"true"$],
    "im", "Complex{Bool}", "$i$", [#$i$], "$i$", [$i$], "i", [$i$],
    "1 + 2im", "Complex", "$1 + 2i$", [#$1 + 2i$], "$1 + 2i$", [$1 + 2i$], "(1 + 2i)", [$(1 + 2i)$],
    "π", "Irrational", "3.141592653589793", [#3.141592653589793], "$π$", [$π$], "π", [$π$],
    "nothing", "Nothing", "none", [#none], "#none", [#none], "#none", [$#none$],
    "0:2:6", "OrdinalRange{<:Integer, <:Integer}", "range(0, 7, step: 2)", [#range(0, 7, step: 2)], "$vec(\n  0, 2, 4, 6\n)$", [$vec(
      0, 2, 4, 6
    )$], "vec(\n  0, 2, 4, 6\n)", [$vec(
      0, 2, 4, 6
    )$],
    "1//2", "Rational", "(1 / 2)", [#(1 / 2)], "$1 / 2$", [$1 / 2$], "(1 / 2)", [$(1 / 2)$],
    "r\"[a-z]\"", "Regex", "regex(\"[a-z]\")", [#regex("[a-z]")], "#regex(\"[a-z]\")", [#regex("[a-z]")], "#regex(\"[a-z]\")", [$#regex("[a-z]")$],
    "1", "Signed", "1", [#1], "$1$", [$1$], "1", [$1$],
    "StepRangeLen(0, 2, 4)", "StepRangeLen{<:Integer, <:Integer, <:Integer}", "range(0, 7, step: 2)", [#range(0, 7, step: 2)], "$vec(\n  0, 2, 4, 6\n)$", [$vec(
      0, 2, 4, 6
    )$], "vec(\n  0, 2, 4, 6\n)", [$vec(
      0, 2, 4, 6
    )$],
    "(true, 1, 1.2, 1//2)", "Tuple", "(true, 1, 1.2, 1 / 2)", [#(true, 1, 1.2, 1 / 2)], "$vec(\n  \"true\", 1, 1.2, 1 / 2\n)$", [$vec(
      "true", 1, 1.2, 1 / 2
    )$], "vec(\n  \"true\", 1, 1.2, 1 / 2\n)", [$vec(
      "true", 1, 1.2, 1 / 2
    )$],
    "Typst(1)", "Typst", "1", [#1], "$1$", [$1$], "1", [$1$],
    "typst\"[\\\"a\\\"]\"", "TypstString", "[\"a\"]", [#["a"]], "[\"a\"]", [["a"]], "[\"a\"]", [$["a"]$],
    "TypstText([1, 2, 3, 4])", "TypstText", "[1, 2, 3, 4]", [#[1, 2, 3, 4]], "[1, 2, 3, 4]", [[1, 2, 3, 4]], "[1, 2, 3, 4]", [$[1, 2, 3, 4]$],
    "0xff", "Unsigned", "0xff", [#0xff], "#0xff", [#0xff], "#0xff", [$#0xff$],
    "v\"1.2.3\"", "VersionNumber", "version(1, 2, 3)", [#version(1, 2, 3)], "#version(1, 2, 3)", [#version(1, 2, 3)], "#version(1, 2, 3)", [$#version(1, 2, 3)$],
    "html\"<p>a</p>\"", "Docs.HTML", "```html <p>a</p> ```", [#```html <p>a</p> ```], "```html <p>a</p> ```", [```html <p>a</p> ```], "#```html <p>a</p> ```", [$#```html <p>a</p> ```$],
    "text\"[\\\"a\\\"]\"", "Docs.Text", "\"[\\\"a\\\"]\"", [#"[\"a\"]"], "#\"[\\\"a\\\"]\"", [#"[\"a\"]"], "#\"[\\\"a\\\"]\"", [$#"[\"a\"]"$],
    "Dates.Date(1)", "Dates.Date", "datetime(\n  year: 1,\n  month: 1,\n  day: 1\n)", [#datetime(
      year: 1,
      month: 1,
      day: 1
    )], "#datetime(\n  year: 1,\n  month: 1,\n  day: 1\n)", [#datetime(
      year: 1,
      month: 1,
      day: 1
    )], "#datetime(\n  year: 1,\n  month: 1,\n  day: 1\n)", [$#datetime(
      year: 1,
      month: 1,
      day: 1
    )$],
    "Dates.DateTime(1)", "Dates.DateTime", "datetime(\n  year: 1,\n  month: 1,\n  day: 1,\n  hour: 0,\n  minute: 0,\n  second: 0\n)", [#datetime(
      year: 1,
      month: 1,
      day: 1,
      hour: 0,
      minute: 0,
      second: 0
    )], "#datetime(\n  year: 1,\n  month: 1,\n  day: 1,\n  hour: 0,\n  minute: 0,\n  second: 0\n)", [#datetime(
      year: 1,
      month: 1,
      day: 1,
      hour: 0,
      minute: 0,
      second: 0
    )], "#datetime(\n  year: 1,\n  month: 1,\n  day: 1,\n  hour: 0,\n  minute: 0,\n  second: 0\n)", [$#datetime(
      year: 1,
      month: 1,
      day: 1,
      hour: 0,
      minute: 0,
      second: 0
    )$],
    "Dates.Day(1)", "Dates.Period", "duration(\n  days: 1\n)", [#duration(
      days: 1
    )], "#duration(\n  days: 1\n)", [#duration(
      days: 1
    )], "#duration(\n  days: 1\n)", [$#duration(
      days: 1
    )$],
    "Dates.Time(0)", "Dates.Time", "datetime(\n  hour: 0,\n  minute: 0,\n  second: 0\n)", [#datetime(
      hour: 0,
      minute: 0,
      second: 0
    )], "#datetime(\n  hour: 0,\n  minute: 0,\n  second: 0\n)", [#datetime(
      hour: 0,
      minute: 0,
      second: 0
    )], "#datetime(\n  hour: 0,\n  minute: 0,\n  second: 0\n)", [$#datetime(
      hour: 0,
      minute: 0,
      second: 0
    )$]
))

