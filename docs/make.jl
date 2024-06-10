
using Base: get_extension
using Dates: Dates
using Documenter: HTML, DocMeta.setdocmeta!, deploydocs, makedocs
using LaTeXStrings: LaTeXStrings, @L_str
using Luxor: Drawing, finish, julia_blue, julia_green, julia_purple, julia_red, rect, sethue
using Markdown: Markdown, @md_str
using Typstry
using Typstry: Typst, _show_typst, enclose, join_with, preamble, typst_mime

const assets = joinpath(@__DIR__, "src", "assets")
const examples = Pair{Any, Type}[]
const _examples = joinpath(assets, "examples.typ")
const logo = joinpath(assets, "logo.svg")
const modes = instances(Mode)
const width, height = 210, 297
const modules = [Typstry]

setdocmeta!(Typstry, :DocTestSetup, :(using Typstry); recursive = true)

for extension in [:Dates, :LaTeXStrings, :Markdown]
    _module = get_extension(Typstry, Symbol(extension, :Extension))
    setdocmeta!(_module, :DocTestSetup, :(using Typstry; using $extension); recursive = true)
    push!(modules, _module)
    append!(examples, _module.examples)
end

append!(examples, Typstry.examples)

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

open(_examples; truncate = true) do file
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

    join_with(file, examples, ",\n") do file, example
        v, t = example
        is_vector = v isa Vector

        print(file, "    ")
        show(file,
            if is_vector "[true, 1, Any[1.2, 1//2]]"
            elseif v isa Dates.Date "Dates.Date(1)"
            elseif v isa Dates.DateTime "Dates.DateTime(1)"
            elseif v isa Dates.Time "Dates.Time(1)"
            elseif v isa Docs.HTML "html\"<p>a</p>\""
            elseif v isa Docs.Text "text\"[\\\"a\\\"]\""
            elseif v isa LaTeXStrings.LaTeXString "L\"a\""
            elseif v isa Markdown.MD "md\"# a\""
            elseif v isa StepRangeLen "StepRangeLen(0, 2, 4)"
            elseif v isa Typst "Typst(1)"
            elseif v isa TypstText "TypstText([1, 2, 3, 4])"
            else repr(v)
            end
        )
        print(file, ", `")

        if v isa Docs.HTML print(file, "Docs.HTML")
        elseif v isa Docs.Text print(file, "Docs.Text")
        else print(file, t)
        end

        print(file, "`,", is_vector || v isa AbstractMatrix ? "\n        " : " ")
        join_with(file, modes, ", ") do file, mode
            enclose((file, v) -> _show_typst(IOContext(file, :mode => mode, :depth => 2), v),
                file, v, (mode == math ? ("\$", "\$") : ("[" * (mode == code ? "#" : ""), "]"))...)
        end
    end

    println(file, "\n)")
end

run(TypstCommand(["compile", "--font-path=" * julia_mono, "--format=svg", _examples]))

makedocs(; modules, sitename = "Typstry.jl", format = HTML(edit_link = "main"), pages = [
    "Home" => "index.md",
    "Getting Started" => "getting_started.md",
    "Tutorials" => ["Interface" => "tutorials/interface.md"],
    "Manual" => map(page -> uppercasefirst(page) => joinpath("manual", page * ".md"),
        ["strings", "commands", "extensions", "internals"])
])

deploydocs(;
    devbranch = "main",
    devurl = "development",
    repo = "github.com/jakobjpeters/Typstry.jl.git"
)
