
module TestDocumenter

using Base: get_extension, disable_logging
using Dates: Dates
using Documenter: DocMeta.setdocmeta!, doctest
using Logging: Debug, Info, disable_logging
using Markdown: Markdown
using LaTeXStrings: LaTeXStrings
using Preferences: set_preferences!
using Typstry

const extensions = [:Dates, :LaTeXStrings, :Markdown]

function _test(_module, x)
    setdocmeta!(_module, :DocTestSetup, quote
        using Preferences: set_preferences!
        using Typstry
        $x

        set_preferences!("Typstry", "instability_check" => "error")
    end; recursive = true)

    # TODO: errors print twice
    doctest(_module; manual = "source", testset = "`$_module` Doctests")
end

function test()
    set_preferences!("Typstry", "instability_check" => "error")
    disable_logging(Info)

    _test(Typstry, nothing)

    for extension in extensions
        _extension = Symbol(extension, "Extension")
        _module = get_extension(Typstry, _extension)

        _test(_module, :(using $extension))
    end

    disable_logging(Debug)
end

end # TestDocumenter
