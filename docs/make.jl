
import Dates, Documenter, LaTeXStrings, Markdown
using Base: get_extension
using Documenter: Docs, DocMeta, deploydocs, makedocs
using .Docs: HTML, Text
using .DocMeta: setdocmeta!
using LaTeXStrings: LaTeXString
using Luxor: Drawing, finish, julia_blue, julia_green, julia_purple, julia_red, rect, sethue
using Markdown: MD
using Typstry: TypstContext, context, enclose, examples, join_with, show_raw
using Typstry

const assets = joinpath(@__DIR__, "source", "assets")
const _examples = Vector{Pair{Any, Pair{Type, Vector{Symbol}}}}[]
const logo = joinpath(assets, "logo.svg")
const modes = instances(Mode)
const width, height = 210, 297
const modules = [Typstry]
const extensions = ["LaTeXStrings", "Markdown"]
const template = joinpath(assets, "template.typ")
const tc = mergewith!((x, _) -> x, TypstContext(; backticks = 4), context)

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

for (package, examples) in append!([("Typstry", examples)], zip(extensions, _examples))
    path = joinpath(assets, package * "_examples.typ")

    open(path; truncate = true) do file
        show_typst(file,
            typst"""
            #import "template.typ": module, template
            #show: document => template(document)
            #module(\(package * ".jl"; mode = code), (
            """
        )
        join_with(file, examples, ",\n") do file, (v, (t, cs))
            print(file, "    ")

            if v isa MD show_typst(file, "md\"# A\""; mode = code)
            else show_typst(file, repr(v); mode = code)
            end

            print(file, ", ")
            show_typst(file, repr(t); mode = code)
            print(file, ", [")
            join_with((file, c) -> print(file, '`', c, '`'), file, cs, ", ")
            print(file, "], ")
            show_raw(file, tc, MIME"text/typst"(), :typst, Typst(v))
            print(file, ", [")
            show_typst(file, v)
            print(file, ']')
#             print(file, "    ")
#             show(file,
#                 if v isa Dates.Date "Dates.Date(1)"
#                 elseif v isa Dates.DateTime "Dates.DateTime(1)"
#                 elseif v isa HTML "html\"<p>a</p>\""
#                 elseif v isa Text "text\"[\\\"a\\\"]\""
#                 elseif v isa LaTeXString "L\"a\""
#                 elseif v isa MD "md\"# a\""
#                 elseif v isa StepRangeLen "StepRangeLen(0, 2, 4)"
#                 elseif v isa Typst "Typst(1)"
#                 elseif v isa TypstText "TypstText([1, 2, 3, 4])"
#                 else repr(v)
#                 end
#             )
#             print(file, ", \"")

#             if v isa HTML print(file, "Docs.HTML")
#             elseif v isa Text print(file, "Docs.Text")
#             else print(file, t)
#             end

#             print(file, "\",", v isa Union{Vector, Matrix} ? "\n        " : " ")
#             join_with(file, modes, ", ") do file, mode
#                 show_typst(file, String(TypstString(v; mode)); mode = code)
#                 print(file, ", [")
#                 enclose(show_typst, file, TypstString(v; mode, depth = 2), (
#                     if mode == code; ("#", "")
#                     elseif mode == markup; ("", "")
#                     else ("\$", "\$")
#                     end
#                 )...)
#                 print(file, "]")
#             end
        end
        println(file, "\n))")
    end

    run(TypstCommand(["compile", "--font-path=" * julia_mono, "--format=svg", path]))
end

makedocs(; modules, format = Documenter.HTML(; edit_link = "main"), pages = [
    "Typstry.jl" => "index.md",
    pages("tutorials", ["getting_started"]),
    pages("guides", [
        "typst_formatting_examples",
        "the_julia_to_typst_interface",
        "package_interoperability",
        "updating_dependencies"
    ]), pages("references", [
        "commands", "contexts", "strings", "render", "package_extensions", "internals"
    ])
], sitename = "Typstry.jl", source = "source")

deploydocs(; devurl = "development", repo = "github.com/jakobjpeters/Typstry.jl.git")
