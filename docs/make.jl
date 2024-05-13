
using Documenter: HTML, DocMeta.setdocmeta!, deploydocs, makedocs
using Luxor: Drawing, finish, julia_blue, julia_green, julia_purple, julia_red, rect, sethue
using Typstry
using Typstry: enclose, examples, join_with, preamble, typst_mime

const assets = joinpath(@__DIR__, "src", "assets")
const strings = joinpath(assets, "strings")
const logo = joinpath(assets, "logo.svg")
const modes = instances(Mode)
const width, height = 210, 297

mkpath(assets)
Drawing(width, height, :svg, logo)

for (color, (x_min, y_min)) in zip(
    (julia_purple, julia_green, julia_red, julia_blue),
    map(i -> ((0.3 - i) * width, i * height), 0:0.1:0.3)
)
    sethue(color)
    rect(x_min, y_min, 0.7 * width, 0.7 * height; action = :fill)
end

finish()

open(strings * ".typ"; truncate = true) do file
    println(file, "#import table: cell, header\n\n", preamble)
    join_with(print, file, [
        "#show cell: c => align(horizon, box(inset: 8pt,",
        "if c.y < 2 { strong(c) }",
        "else if c.x == 0 { raw(c.body.text, lang: \"julia\") }",
        "else { c }\n))\n\n#table(columns: 5,",
        "header(\n"
    ], "\n    ")

    for s in [
        "cell(rowspan: 2)[Value]",
        "cell(rowspan: 2)[Type]",
        "cell(colspan: 3, align: center)[`Mode`]"
    ]
        println(file, "        ", s, ",")
    end

    print(file, "        ")
    join(file, map(mode -> "`$mode`", modes), ", ")
    println(file, "\n    ),")

    join_with(file, examples, ",\n") do file, (v, t)
        is_matrix = t <: AbstractMatrix
        is_range = t <: AbstractRange
        is_vector = t <: AbstractVector && !is_range

        print(file, "    ")

        if is_vector print(file, "\"[true [1]]\"")
        elseif is_matrix print(file, "\"[true 1; 1.0 [Any[\\n    true 1; 1.0 nothing\\n]]]\"")
        elseif t <: Text print(file, "\"Text(\\\"[\\\\\\\"a\\\\\\\"]\\\")\"")
        elseif t <: StepRangeLen print(file, "\"StepRangeLen(0, 2, 4)\"")
        else show(file, repr(v))
        end

        print(file, ", `", t, "`,", is_vector || is_matrix ? "\n        " : " ")
        join_with(file, modes, ", ") do file, mode
            enclose((file, v) ->
                show(IOContext(file, :mode => mode, :depth => 2), typst_mime, v),
            file, v, (
                if mode == math; ("\$",)
                else ("[" * (mode == code ? "#" : ""), "]")
                end
            )...)
        end
    end

    println(file, "\n)")
end

run(TypstCommand(["compile", "--font-path=" * julia_mono, strings * ".typ", strings * ".svg"]))

setdocmeta!(
    Typstry,
    :DocTestSetup,
    :(using Typstry),
    recursive = true
)

makedocs(;
    sitename = "Typstry.jl",
    format = HTML(edit_link = "main"),
    modules = [Typstry],
    pages = ["Home" => "index.md", "Getting Started" => "getting_started.md", "Manual" => map(
        page -> uppercasefirst(page) => joinpath("manual", page * ".md"),
    ["strings", "commands", "internals"])]
)

deploydocs(
    repo = "github.com/jakobjpeters/Typstry.jl.git",
    devbranch = "main"
)
