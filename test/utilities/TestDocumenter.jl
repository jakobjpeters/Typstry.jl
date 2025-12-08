
module TestDocumenter

import Dates, Typstry
using Base: get_extension, disable_logging
using Documenter: DocMeta.setdocmeta!, doctest
using Logging: Debug, Warn, disable_logging
using ..TestTypstry: names, modules

function test(_module, x)
    setdocmeta!(_module, :DocTestSetup, :(using Typstry; using $x: $x); recursive = true)
    doctest(_module; testset = "`$_module` Doctests")
end

disable_logging(Warn)

test(Typstry, :Dates)

for (name, _module) in zip(names, modules)
    test(_module, name)
end

disable_logging(Debug)

end # TestDocumenter
