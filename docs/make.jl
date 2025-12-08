
import Dates, Documenter, LaTeXStrings, Markdown
using Base: get_extension
using Documenter: Docs, DocMeta, deploydocs, makedocs
using .Docs: HTML, Text
using .DocMeta: setdocmeta!
using LaTeXStrings: LaTeXString
using Markdown: MD
using Typstry: Utilities, context, Precompile.examples, Strings.show_raw
using .Utilities: enclose, join_with
using Typstry

const assets = joinpath(@__DIR__, "source", "assets")
const _examples = Vector{Pair{Any, Pair{Type, Vector{Symbol}}}}[]
const modes = instances(Mode)
const modules = [Typstry]
const extensions = ["LaTeXStrings", "Markdown"]
const template = joinpath(assets, "template.typ")
const typst_context = mergewith!((x, _) -> x, TypstContext(; mode = code), context)

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
            print(file, "  ")

            if v isa MD show_typst(file, "md\"# A\""; mode = code)
            else show_typst(file, repr(v); mode = code)
            end

            print(file, ", ")
            show_typst(file, repr(t); mode = code)
            print(file, ", [")
            join_with((file, c) -> print(file, '`', c, '`'), file, cs, ", ")
            print(file, "], ")
            show_raw(file, typst_context, MIME"text/typst"(), :typst, Typst(v))
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
        "package_interoperability",
        "terminal_images",
        "the_julia_to_typst_interface",
        "typst_formatting_examples",
        "updating_dependencies"
    ]), pages("references", [
        "commands", "contexts", "strings", "render", "package_extensions", "internals"
    ])
], sitename = "Typstry.jl", source = "source")

deploydocs(; devurl = "development", repo = "github.com/jakobjpeters/Typstry.jl.git")
