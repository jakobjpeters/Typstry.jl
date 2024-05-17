#import table: cell, header

#set page(margin: 1em, height: auto, width: auto, fill: white)
#set text(16pt, font: "JuliaMono")

#show cell: c => align(horizon, box(inset: 8pt,
    if c.y < 2 { strong(c) }
    else if c.x == 0 { raw(c.body.text, lang: "julia") }
    else { c }
))

#table(columns: 5,
    header(
        cell(rowspan: 2)[Value],
        cell(rowspan: 2)[Type],
        cell(colspan: 3, align: center)[`Mode`],
        `code`, `markup`, `math`
    ),
    "'a'", `AbstractChar`, [#"'a'"], ['a'], $'a'$,
    "1.2", `AbstractFloat`, [#1.2], [1.2], $1.2$,
    "[true 1; 1.0 [Any[\n    true 1; 1.0 nothing\n]]]", `AbstractMatrix`,
        [#$ mat(
            "true", 1;
            1.0, mat(
                "true", 1;
                1.0, ""
            )
        ) $], [$ mat(
            "true", 1;
            1.0, mat(
                "true", 1;
                1.0, ""
            )
        ) $], $mat(
            "true", 1;
            1.0, mat(
                "true", 1;
                1.0, ""
            )
        )$,
    "\"a\"", `AbstractString`, [#"\"a\""], ["a"], $"\"a\""$,
    "[true [1]]", `AbstractVector`,
        [#$ vec(
            "true", vec(
                1
            )
        ) $], [$ vec(
            "true", vec(
                1
            )
        ) $], $vec(
            "true", vec(
                1
            )
        )$,
    "true", `Bool`, [#true], [#true], $"true"$,
    "1 + 2im", `Complex`, [#$ 1 + 2i $], [$ 1 + 2i $], $1 + 2i$,
    "π", `Irrational`, [#3.141592653589793], [π], $π$,
    "nothing", `Nothing`, [#""], [], $""$,
    "0:2:6", `OrdinalRange{<:Integer, <:Integer}`, [#range(0, 7, step: 2)], [#range(0, 7, step: 2)], $#range(0, 7, step: 2)$,
    "1//2", `Rational`, [#(1 / 2)], [$ 1 / 2 $], $1 / 2$,
    "r\"[a-z]\"", `Regex`, [#regex("[a-z]")], [#regex("[a-z]")], $#regex("[a-z]")$,
    "1", `Signed`, [#1], [1], $1$,
    "StepRangeLen(0, 2, 4)", `StepRangeLen{<:Integer, <:Integer, <:Integer}`, [#range(0, 7, step: 2)], [#range(0, 7, step: 2)], $#range(0, 7, step: 2)$,
    "text\"[\\\"a\\\"]\"", `Text`, [#"[\"a\"]"], [#"[\"a\"]"], $#"[\"a\"]"$,
    "typst\"[\\\"a\\\"]\"", `TypstString`, [#["a"]], [["a"]], $["a"]$
)
