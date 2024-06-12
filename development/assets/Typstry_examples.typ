#import "template.typ": f, template

#show: document => template(document)

= Typstry.jl

#f((
    "html\"<p>a</p>\"", `Docs.HTML`, ````typc ```html <p>a</p> ``` ````, [#```html <p>a</p> ```], ````typ ```html <p>a</p> ``` ````, [```html <p>a</p> ```], ````typc #```html <p>a</p> ``` ````, [$#```html <p>a</p> ```$],
    "text\"[\\\"a\\\"]\"", `Docs.Text`, ````typc "\"[\\\"a\\\"]\"" ````, [#"\"[\\\"a\\\"]\""], ````typ "[\\\"a\\\"]" ````, ["[\\\"a\\\"]"], ````typc "\"[\\\"a\\\"]\"" ````, [$"\"[\\\"a\\\"]\""$],
    "Any[true, 1, 1.2, 1//2]", `AbstractArray`,
        ````typc (true, 1, 1.2, 1 / 2) ````, [#(true, 1, 1.2, 1 / 2)], ````typ $vec(
      "true", 1, 1.2, 1 / 2
    )$ ````, [$vec(
      "true", 1, 1.2, 1 / 2
    )$], ````typc vec(
      "true", 1, 1.2, 1 / 2
    ) ````, [$vec(
      "true", 1, 1.2, 1 / 2
    )$],
    "'a'", `AbstractChar`, ````typc "'a'" ````, [#"'a'"], ````typ 'a' ````, ['a'], ````typc 'a' ````, [$'a'$],
    "1.2", `AbstractFloat`, ````typc 1.2 ````, [#1.2], ````typ 1.2 ````, [1.2], ````typc 1.2 ````, [$1.2$],
    "Any[true 1; 1.2 1//2]", `AbstractMatrix`,
        ````typc (true, 1.2, 1, 1 / 2) ````, [#(true, 1.2, 1, 1 / 2)], ````typ $mat(
      "true", 1;
      1.2, 1 / 2
    )$ ````, [$mat(
      "true", 1;
      1.2, 1 / 2
    )$], ````typc mat(
      "true", 1;
      1.2, 1 / 2
    ) ````, [$mat(
      "true", 1;
      1.2, 1 / 2
    )$],
    "\"a\"", `AbstractString`, ````typc "a" ````, [#"a"], ````typ "a" ````, ["a"], ````typc "a" ````, [$"a"$],
    "true", `Bool`, ````typc true ````, [#true], ````typ #true ````, [#true], ````typc "true" ````, [$"true"$],
    "im", `Complex{Bool}`, ````typc $i$ ````, [#$i$], ````typ $i$ ````, [$i$], ````typc (i) ````, [$(i)$],
    "1 + 2im", `Complex`, ````typc $1 + 2i$ ````, [#$1 + 2i$], ````typ $1 + 2i$ ````, [$1 + 2i$], ````typc (1 + 2i) ````, [$(1 + 2i)$],
    "π", `Irrational`, ````typc 3.141592653589793 ````, [#3.141592653589793], ````typ π ````, [π], ````typc π ````, [$π$],
    "nothing", `Nothing`, ````typc none ````, [#none], ````typ #none ````, [#none], ````typc #none ````, [$#none$],
    "0:2:6", `OrdinalRange{<:Integer, <:Integer}`, ````typc range(0, 7, step: 2) ````, [#range(0, 7, step: 2)], ````typ $vec(
      0, 2, 4, 6
    )$ ````, [$vec(
      0, 2, 4, 6
    )$], ````typc vec(
      0, 2, 4, 6
    ) ````, [$vec(
      0, 2, 4, 6
    )$],
    "1//2", `Rational`, ````typc (1 / 2) ````, [#(1 / 2)], ````typ $1 / 2$ ````, [$1 / 2$], ````typc (1 / 2) ````, [$(1 / 2)$],
    "r\"[a-z]\"", `Regex`, ````typc regex("[a-z]") ````, [#regex("[a-z]")], ````typ #regex("[a-z]") ````, [#regex("[a-z]")], ````typc #regex("[a-z]") ````, [$#regex("[a-z]")$],
    "1", `Signed`, ````typc 1 ````, [#1], ````typ 1 ````, [1], ````typc 1 ````, [$1$],
    "StepRangeLen(0, 2, 4)", `StepRangeLen{<:Integer, <:Integer, <:Integer}`, ````typc range(0, 7, step: 2) ````, [#range(0, 7, step: 2)], ````typ $vec(
      0, 2, 4, 6
    )$ ````, [$vec(
      0, 2, 4, 6
    )$], ````typc vec(
      0, 2, 4, 6
    ) ````, [$vec(
      0, 2, 4, 6
    )$],
    "(true, 1, 1.2, 1//2)", `Tuple`, ````typc (true, 1, 1.2, 1 / 2) ````, [#(true, 1, 1.2, 1 / 2)], ````typ $vec(
      "true", 1, 1.2, 1 / 2
    )$ ````, [$vec(
      "true", 1, 1.2, 1 / 2
    )$], ````typc vec(
      "true", 1, 1.2, 1 / 2
    ) ````, [$vec(
      "true", 1, 1.2, 1 / 2
    )$],
    "Typst(1)", `Typst`, ````typc 1 ````, [#1], ````typ 1 ````, [1], ````typc 1 ````, [$1$],
    "typst\"[\\\"a\\\"]\"", `TypstString`, ````typc ["a"] ````, [#["a"]], ````typ ["a"] ````, [["a"]], ````typc ["a"] ````, [$["a"]$],
    "TypstText([1, 2, 3, 4])", `TypstText`, ````typc [1, 2, 3, 4] ````, [#[1, 2, 3, 4]], ````typ [1, 2, 3, 4] ````, [[1, 2, 3, 4]], ````typc [1, 2, 3, 4] ````, [$[1, 2, 3, 4]$],
    "0xff", `Unsigned`, ````typc 0xff ````, [#0xff], ````typ #0xff ````, [#0xff], ````typc #0xff ````, [$#0xff$],
    "v\"1.2.3\"", `VersionNumber`, ````typc version(1, 2, 3) ````, [#version(1, 2, 3)], ````typ #version(1, 2, 3) ````, [#version(1, 2, 3)], ````typc #version(1, 2, 3) ````, [$#version(1, 2, 3)$]
))

