
module TestDocumenter

using Base: get_extension, disable_logging
using Dates: Dates
using Documenter: DocMeta.setdocmeta!, doctest
using Logging: Debug, Info, disable_logging
using ..TestTypstry: names, modules
using Typstry: Typstry

function _test(_module, x)
    setdocmeta!(_module, :DocTestSetup, :(using Typstry; $x); recursive = true)
    doctest(_module; manual = "source", testset = "`$_module` Doctests")
end

function test()
    disable_logging(Info)

    _test(Typstry, nothing)

    for (name, _module) in zip(names, modules)
        _test(_module, :(using $name))
    end

    disable_logging(Debug)
end

end # TestDocumenter
