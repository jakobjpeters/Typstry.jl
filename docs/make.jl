
using Documenter: HTML, DocMeta.setdocmeta!, deploydocs, makedocs
using Luxor: Drawing, finish, julia_blue, julia_green, julia_purple, julia_red, rect, sethue
using Typstry
using Typstry: examples, join_with, preamble

const assets = joinpath(@__DIR__, "src", "assets")
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

open(joinpath(@__DIR__, "strings.typ"); truncate = true) do file
    print(file, preamble,"\n#let julia(s) = raw(s, lang: \"julia\")\n\n")

    for s in [
        "#table(align: horizon, columns: 5, inset: 8pt",
        "table.cell(rowspan: 2)[*Value*]",
        "table.cell(rowspan: 2)[*Type*]",
        "table.cell(colspan: 3, align: center)[*`Mode`*]"
    ]
        print(file, s, ",\n    ")
    end

    join(file, map(mode -> "[*`$mode`*]", modes), ", ")
    println(file, ",")

    join_with(file, examples, ",\n") do file, (v, t)
        is_matrix, is_vector = t <: AbstractMatrix, t <: AbstractVector && !(t <: OrdinalRange)

        print(file, "    julia(")

        if is_vector print(file, "\"[true [1]]\"")
        elseif is_matrix print(file, "\"[true 1; 1.0 [Any[\\n    true 1; 1.0 nothing\\n]]]\"")
        elseif t <: Text print(file, "\"Text(\\\"[\\\\\\\"a\\\\\\\"]\\\")\"")
        elseif t <: AbstractString print(file, "\"typst_text(\\\"[\\\\\\\"a\\\\\\\"]\\\")\"")
        else show(file, repr(v))
        end

        print(file, "), `", t, "`,", is_vector || is_matrix ? "\n        " : " ")

        join_with(file, modes, ", ") do file, mode
            s = TypstString(v, :mode => mode, :depth => 2)

            if mode == math print(file, "\$", s, "\$")
            else
                print(file, "[")
                mode == code && print(file, "#")
                print(file, s, "]")
            end
        end
    end

    println(file, "\n)")
end

run(TypstCommand([
    "compile",
    "--font-path=" * julia_mono,
    joinpath(@__DIR__, "strings.typ"),
    joinpath(assets, "strings.svg")
]))

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
    pages = ["Home" => "index.md", "Manual" => map(
        page -> uppercasefirst(page) => joinpath("manual", page * ".md"),
    ["strings", "commands", "internals"])]
)

deploydocs(
    repo = "github.com/jakobjpeters/Typstry.jl.git",
    devbranch = "main"
)
