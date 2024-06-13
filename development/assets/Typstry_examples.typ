#import "template.typ": f, template

#show: document => template(document)

= Typstry.jl

#f((
    "html\"<p>a</p>\"", "Docs.HTML", "```html <p>a</p> ```", [#```html <p>a</p> ```], "```html <p>a</p> ```", [```html <p>a</p> ```], "#```html <p>a</p> ```", [$#```html <p>a</p> ```$],
    "text\"[\\\"a\\\"]\"", "Docs.Text", "\"[\\\"a\\\"]\"", [#"[\"a\"]"], "#\"[\\\"a\\\"]\"", [#"[\"a\"]"], "\"[\\\"a\\\"]\"", [$"[\"a\"]"$],
    "Any[true, 1, 1.2, 1//2]", "AbstractArray",
        "(true, 1, 1.2, 1 / 2)", [#(true, 1, 1.2, 1 / 2)], "$vec(\n  \"true\", 1, 1.2, 1 / 2\n)$", [$vec(
      "true", 1, 1.2, 1 / 2
    )$], "vec(\n  \"true\", 1, 1.2, 1 / 2\n)", [$vec(
      "true", 1, 1.2, 1 / 2
    )$],
    "'a'", "AbstractChar", "\"a\"", [#"a"], "#\"a\"", [#"a"], "\"a\"", [$"a"$],
    "1.2", "AbstractFloat", "1.2", [#1.2], "1.2", [1.2], "1.2", [$1.2$],
    "Any[true 1; 1.2 1//2]", "AbstractMatrix",
        "(true, 1.2, 1, 1 / 2)", [#(true, 1.2, 1, 1 / 2)], "$mat(\n  \"true\", 1;\n  1.2, 1 / 2\n)$", [$mat(
      "true", 1;
      1.2, 1 / 2
    )$], "mat(\n  \"true\", 1;\n  1.2, 1 / 2\n)", [$mat(
      "true", 1;
      1.2, 1 / 2
    )$],
    "\"a\"", "AbstractString", "\"a\"", [#"a"], "#\"a\"", [#"a"], "\"a\"", [$"a"$],
    "true", "Bool", "true", [#true], "#true", [#true], "\"true\"", [$"true"$],
    "im", "Complex{Bool}", "$i$", [#$i$], "$i$", [$i$], "(i)", [$(i)$],
    "1 + 2im", "Complex", "$1 + 2i$", [#$1 + 2i$], "$1 + 2i$", [$1 + 2i$], "(1 + 2i)", [$(1 + 2i)$],
    "π", "Irrational", "3.141592653589793", [#3.141592653589793], "π", [π], "π", [$π$],
    "nothing", "Nothing", "none", [#none], "#none", [#none], "#none", [$#none$],
    "0:2:6", "OrdinalRange{<:Integer, <:Integer}", "range(0, 7, step: 2)", [#range(0, 7, step: 2)], "$vec(\n  0, 2, 4, 6\n)$", [$vec(
      0, 2, 4, 6
    )$], "vec(\n  0, 2, 4, 6\n)", [$vec(
      0, 2, 4, 6
    )$],
    "1//2", "Rational", "(1 / 2)", [#(1 / 2)], "$1 / 2$", [$1 / 2$], "(1 / 2)", [$(1 / 2)$],
    "r\"[a-z]\"", "Regex", "regex(\"[a-z]\")", [#regex("[a-z]")], "#regex(\"[a-z]\")", [#regex("[a-z]")], "#regex(\"[a-z]\")", [$#regex("[a-z]")$],
    "1", "Signed", "1", [#1], "#1", [#1], "1", [$1$],
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
    "Typst(1)", "Typst", "1", [#1], "#1", [#1], "1", [$1$],
    "typst\"[\\\"a\\\"]\"", "TypstString", "[\"a\"]", [#["a"]], "[\"a\"]", [["a"]], "[\"a\"]", [$["a"]$],
    "TypstText([1, 2, 3, 4])", "TypstText", "[1, 2, 3, 4]", [#[1, 2, 3, 4]], "[1, 2, 3, 4]", [[1, 2, 3, 4]], "[1, 2, 3, 4]", [$[1, 2, 3, 4]$],
    "0xff", "Unsigned", "0xff", [#0xff], "#0xff", [#0xff], "#0xff", [$#0xff$],
    "v\"1.2.3\"", "VersionNumber", "version(1, 2, 3)", [#version(1, 2, 3)], "#version(1, 2, 3)", [#version(1, 2, 3)], "#version(1, 2, 3)", [$#version(1, 2, 3)$]
))

