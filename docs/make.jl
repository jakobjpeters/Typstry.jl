
using Documenter: DocMeta.setdocmeta!, makedocs, HTML, deploydocs
using Typstry

const directory = (@__DIR__) * "/src/assets/"
if !ispath(directory * "logo.svg")
    include("logo.jl")
    make_logo(directory)
end

setdocmeta!(
    Typstry,
    :DocTestSetup,
    :(using Typstry),
    recursive = true,
)

makedocs(
    sitename = "Typstry.jl",
    format = HTML(edit_link = "main"),
    modules = [Typstry],
    pages = [
        "Home" => "index.md",
        "Manual" => "manual.md"
    ],
)

deploydocs(
    repo = "github.com/jakobjpeters/Typstry.jl.git",
    devbranch = "main"
)
