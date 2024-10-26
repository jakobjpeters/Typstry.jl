
using Base: get_extension
using Dates: Dates
using Documenter: Documenter, Docs, DocMeta, deploydocs, makedocs
using .Docs: HTML, Text
using .DocMeta: setdocmeta!
using LaTeXStrings: LaTeXStrings, LaTeXString
using Luxor: Drawing, finish, julia_blue, julia_green, julia_purple, julia_red, rect, sethue
using Markdown: Markdown, MD
using Typstry: Strings, preamble
using .Strings: examples, _show_typst, enclose, join_with, typst_mime
using Typstry

const assets = joinpath(@__DIR__, "source", "assets")
const _examples = Vector{Pair{Any, Type}}[]
const logo = joinpath(assets, "logo.svg")
const modes = instances(Mode)
const width, height = 210, 297
const modules = [Typstry]
const extensions = ["LaTeXStrings", "Markdown"]
const template = joinpath(assets, "template.typ")

pages(folder, names) = titlecase(replace(folder, "_" => " ")) => map(name -> joinpath(folder, name * ".md"), names)

_setdocmeta!(_module, x) = setdocmeta!(_module, :DocTestSetup, quote
    using Typstry
    using $x: $x
end; recursive = true)

_setdocmeta!(Typstry, :Dates)

for extension in extensions
    _module = get_extension(Typstry, Symbol(extension, :Extension))
    _setdocmeta!(_module, Symbol(extension))
    push!(modules, _module)
    push!(_examples, _module.examples)
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
    println(file, "\n#import table: cell, header\n\n#let template(document) = {")

    for x in split(preamble, "\n")
        println(file, "    ", x[2:end])
    end

    join_with(print, file, [
        "    show cell: c => align(horizon, box(inset: 8pt,",
        "    if c.y < 2 { strong(c) }",
        "    else {",
        "        let x = c.x",
        "        if x in (3, 5, 7) { c }",
        "        else { raw({ c.body.text }, lang: {",
        "            if x < 2 { \"julia\" } else if x == 2 { \"typc\" } else if x == 4 { \"typ\" } else { \"typm\" }",
        "        } ) }",
        "    }",
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
    join(file, map(mode -> "cell(colspan: 2)[$(uppercasefirst(string(mode)))]", modes), ", ")
    println(file, "\n), ..examples)")
end

for (package, examples) in append!([("Typstry", examples)], zip(extensions, _examples))
    path = joinpath(assets, package * "_examples.typ")

    open(path; truncate = true) do file
        println(file, "#import \"template.typ\": f, template\n\n#show: document => template(document)\n\n= ", package, ".jl\n\n#f((")
        join_with(file, examples, ",\n") do file, (v, t)
            print(file, "    ")
            show(file,
                if v isa Dates.Date "Dates.Date(1)"
                elseif v isa Dates.DateTime "Dates.DateTime(1)"
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
            print(file, ", \"")

            if v isa HTML print(file, "Docs.HTML")
            elseif v isa Text print(file, "Docs.Text")
            else print(file, t)
            end

            print(file, "\",", v isa Union{Vector, Matrix} ? "\n        " : " ")
            join_with(file, modes, ", ") do file, mode
                _show_typst(IOContext(file, :mode => code), String(TypstString(v; mode)))
                print(file, ", [")
                enclose(_show_typst, file, TypstString(v; mode, depth = 2), (
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

makedocs(; modules,
    format = Documenter.HTML(edit_link = "main"),
    pages = [
        "Typstry.jl" => "index.md",
        pages("tutorials", ["getting_started"]),
        pages("guides", ["typst_formatting_examples", "the_julia_to_typst_interface", "package_interoperability"]),
        pages("references", ["strings", "commands", "package_extensions", "internals"])
    ],
    sitename = "Typstry.jl",
    source = "source"
)

deploydocs(; devurl = "development", repo = "github.com/jakobjpeters/Typstry.jl.git")
