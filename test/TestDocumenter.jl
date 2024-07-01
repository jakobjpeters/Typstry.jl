
module TestDocumenter

using Base: get_extension, disable_logging
using Dates: Dates
using Documenter: DocMeta.setdocmeta!, doctest
using Logging: Debug, Info, disable_logging
using Markdown: Markdown
using LaTeXStrings: LaTeXStrings
using Typstry: Typstry

function _test(_module, x)
    setdocmeta!(_module, :DocTestSetup, :(using Typstry; $x); recursive = true)
    doctest(_module; manual = "source", testset = "`$_module` Doctests")
end

function test()
    disable_logging(Info)
    _test(Typstry, nothing)

    for extension in [:LaTeXStrings, :Markdown]
        _extension = Symbol(extension, "Extension")
        _module = get_extension(Typstry, _extension)

        _test(_module, :(using $extension))
    end

    disable_logging(Debug)
end

end # TestDocumenter
