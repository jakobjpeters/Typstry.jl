
# Package Interoperability

This guide illustrates how to use Typstry.jl in compatible notebooks and packages.

## Notebooks

IJulia.jl, Pluto.jl, and QuartoNotebookRunner.jl each [`render`](@ref) [`Typst`](@ref)s and [`TypstText`](@ref)s.
Pluto.jl and QuartoNotebookRunner.jl also `render` [`TypstString`](@ref)s,
whereas IJulia.jl will support them in its next feature release.
See also this [pull request](https://github.com/JuliaLang/IJulia.jl/pull/1114).

## Packages

### MakieTeX.jl

!!! note
    This package re-exports [`@typst_str`](@ref) and [`TypstString`](@ref).

`````@eval
using Markdown: Markdown
module X
include("../scripts/include_makie_tex.jl")
const s = read("../../../scripts/makie_tex.jl", String)
end
Markdown.parse("```julia-repl$(join(map(s -> "\njulia> " * s, split(strip(X.s), "\n")), "\n"))\n```")
`````

![MakieTeX.jl](makie_tex.svg)

### TypstJlyfish.jl

`````@eval
module X
using Markdown: Markdown
include("../scripts/typst_jlyfish.jl")
const md = Markdown.parse("```typst\n$ts```\n```julia-repl\njulia> $_using\n\njulia> $compile\n```")
end
X.md
`````

![TypstJlyfish.jl](typst_jlyfish.svg)
