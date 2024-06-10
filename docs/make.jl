
using Base: Docs.HTML, Docs.Text, get_extension
using Dates: Dates, Date, DateTime, Time
using Documenter: Documenter, DocMeta.setdocmeta!, deploydocs, makedocs
using LaTeXStrings: LaTeXStrings, LaTeXString, @L_str
using Luxor: Drawing, finish, julia_blue, julia_green, julia_purple, julia_red, rect, sethue
using Markdown: Markdown, MD, @md_str
using Typstry
using Typstry: Typst, _show_typst, enclose, join_with, preamble, typst_mime

const assets = joinpath(@__DIR__, "src", "assets")
const examples = Vector{Pair{Any, Type}}[]
const logo = joinpath(assets, "logo.svg")
const modes = instances(Mode)
const width, height = 210, 297
const modules = [Typstry]
const extensions = ["Dates", "LaTeXStrings", "Markdown"]
const template = joinpath(assets, "template.typ")

setdocmeta!(Typstry, :DocTestSetup, :(using Typstry); recursive = true)

for extension in extensions
    _module = get_extension(Typstry, Symbol(extension, :Extension))
    setdocmeta!(_module, :DocTestSetup, :(using Typstry; using $extension); recursive = true)
    push!(modules, _module)
    push!(examples, _module.examples)
end

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

open(template; truncate = true) do file
    println(file, "#import table: cell, header\n\n#let template(document) = {")

    for x in split(preamble, "\n")
        println(file, "    ", x[2:end])
    end

    join_with(print, file, [
        "    show cell: c => align(horizon, box(inset: 8pt,",
        "    if c.y < 2 { strong(c) }",
        "    else if c.x == 0 { raw(c.body.text, lang: \"julia\") }",
        "    else { c }",
        "))\n",
        "document\n"
    ], "\n    ")
    println(file, "}\n\n#let f(examples) = table(columns: 8, header(")

    for s in [
        "cell(colspan: 2)[Julia]",
        "cell(colspan: 6)[Typst]",
        "[Value]",
        "[Type]"
    ]
        println(file, "    ", s, ",")
    end

    print(file, "    ")
    join(file, map(mode -> "cell(colspan: 2)[`$mode`]", modes), ", ")
    println(file, "\n), ..examples)")
end

for (package, examples) in append!([("Typstry", Typstry.examples)], zip(extensions, examples))
    path = joinpath(assets, package * "_examples.typ")

    open(path; truncate = true) do file
        println(file, "#import \"template.typ\": f, template\n\n#show: document => template(document)\n\n= ", package, ".jl\n\n#f((")
        join_with(file, examples, ",\n") do file, example
            v, t = example
            is_vector = v isa Vector

            print(file, "    ")
            show(file,
                if v isa Date "Date(1)"
                elseif v isa DateTime "DateTime(1)"
                elseif v isa HTML "html\"<p>a</p>\""
                elseif v isa Text "text\"[\\\"a\\\"]\""
                elseif v isa LaTeXString "L\"a\""
                elseif v isa MD "md\"# a\""
                elseif v isa StepRangeLen "StepRangeLen(0, 2, 4)"
                elseif v isa Typst "Typst(1)"
                elseif v isa TypstText "TypstText([1, 2, 3, 4])"
                else repr(v)
                end
            )
            print(file, ", `")

            if v isa HTML print(file, "Docs.HTML")
            elseif v isa Text print(file, "Docs.Text")
            else print(file, t)
            end

            print(file, "`,", v isa Union{Vector, Matrix} ? "\n        " : " ")
            join_with(file, modes, ", ") do file, mode
                ts = TypstString(v; mode, depth = 2)

                print(file, "````typ")
                mode == markup || print(file, "c")
                print(file, " ")
                _show_typst(file, ts)
                print(file, " ````, [")
                enclose(_show_typst, file, ts, (
                    if mode == code; ("#", "")
                    elseif mode == markup; ("", "")
                    else ("\$", "\$")
                    end
                )...)
                print(file, "]")
            end
        end

        println(file, "\n))\n")
    end

    run(TypstCommand(["compile", "--font-path=" * julia_mono, "--format=svg", path]))
end

makedocs(; modules, sitename = "Typstry.jl", format = Documenter.HTML(edit_link = "main"), pages = [
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
