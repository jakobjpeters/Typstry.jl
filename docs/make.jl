
using Base: Docs.Text, get_extension
using Dates: Dates
using Documenter: HTML, DocMeta.setdocmeta!, deploydocs, makedocs
using LaTeXStrings: LaTeXStrings
using Luxor: Drawing, finish, julia_blue, julia_green, julia_purple, julia_red, rect, sethue
using Typstry
using Typstry: Typst, enclose, examples, join_with, preamble, typst_mime

const assets = joinpath(@__DIR__, "src", "assets")
const strings = joinpath(assets, "strings")
const logo = joinpath(assets, "logo.svg")
const modes = instances(Mode)
const width, height = 210, 297
const modules = [Typstry]

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
        is_vector = v isa Vector

        print(file, "    ")

        if is_vector print(file, "\"[true, 1, Any[1.2, 1//2]]\"")
        elseif v isa StepRangeLen print(file, "\"StepRangeLen(0, 2, 4)\"")
        elseif v isa Text print(file, "\"text\\\"[\\\\\\\"a\\\\\\\"]\\\"\"")
        elseif v isa Typst print(file, "\"Typst(1)\"")
        elseif v isa TypstText print(file, "\"TypstText([1, 2, 3, 4])\"")
        else show(file, repr(v))
        end

        print(file, ", `", v isa Text ? "Docs.Text" : t, "`,", is_vector || v isa AbstractMatrix ? "\n        " : " ")
        join_with(file, modes, ", ") do file, mode
            enclose((file, v) ->
                show(IOContext(file, :mode => mode, :depth => 2), typst_mime, Typst(v)),
            file, v, (mode == math ? ("\$", "\$") : ("[" * (mode == code ? "#" : ""), "]"))...)
        end
    end

    println(file, "\n)")
end

run(TypstCommand(["compile", "--font-path=" * julia_mono, strings * ".typ", strings * ".svg"]))

setdocmeta!(Typstry, :DocTestSetup, :(using Typstry); recursive = true)

for extension in [:Dates, :LaTeXStrings, :Markdown]
    _module = get_extension(Typstry, Symbol(extension, :Extension))
    setdocmeta!(_module, :DocTestSetup, :(using Typstry; using $extension); recursive = true)
    push!(modules, _module)
end

makedocs(;
    modules,
    sitename = "Typstry.jl",
    format = HTML(edit_link = "main"),
    pages = [
        "Home" => "index.md",
        "Getting Started" => "getting_started.md",
        "Tutorials" => ["Interface" => "tutorials/interface.md"],
        "Manual" => map(page -> uppercasefirst(page) => joinpath("manual", page * ".md"),
            ["strings", "commands", "extensions", "internals"])
    ]
)

deploydocs(
    devbranch = "main",
    devurl = "development",
    repo = "github.com/jakobjpeters/Typstry.jl.git"
)
