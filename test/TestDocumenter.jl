
module TestDocumenter

using Base: get_extension, disable_logging
using Dates: Dates
using Documenter: DocMeta.setdocmeta!, doctest
using Logging: Debug, Warn, disable_logging
using ..TestTypstry: names, modules
using Typstry: Typstry

function test(_module, x)
    setdocmeta!(_module, :DocTestSetup, :(using Typstry; using $x: $x); recursive = true)
    doctest(_module; manual = "source", testset = "`$_module` Doctests")
end

disable_logging(Warn)

test(Typstry, :Dates)

for (name, _module) in zip(names, modules)
    test(_module, name)
end

disable_logging(Debug)

end # TestDocumenter
