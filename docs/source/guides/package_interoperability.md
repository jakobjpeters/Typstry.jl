
# Package Interoperability

This guide illustrates how to use Typstry.jl in compatible notebooks and packages.

## Notebooks

IJulia.jl, Pluto.jl, and QuartoNotebookRunner.jl each [`render`](@ref) [`Typst`](@ref)s and [`TypstText`](@ref)s.
Pluto.jl and QuartoNotebookRunner.jl also `render` [`TypstString`](@ref)s,
whereas IJulia.jl will support them in its next feature release.

## Typst Packages

Compiling a document which imports a Typst package can be achieved in exactly the
same manner as compiling a standard Typst source file with the command-line interface.
For example, `typst"#import \"@namespace/name:version\""`.

## Julia Packages

### Literate.jl

### MakieTeX.jl

!!! note
    This package re-exports [`@typst_str`](@ref) and [`TypstString`](@ref).

`````@eval
using Markdown: Markdown
Markdown.parse("""```julia-repl
julia> using CairoMakie, MakieTeX

julia> f = Figure(; size = (100, 100))

julia> LTeX(f[1, 1], TypstDocument(typst"\$ 1 / x \$"))

julia> save("makie_tex.svg", f)
```""")
`````

### TypstJlyfish.jl

`````@eval
import Markdown
Markdown.parse("""
```typst
#import "@preview/jlyfish:0.1.0": *
#read-julia-output(json("typst_jlyfish.json"))
#jl-pkg("Typstry")
#jl(`using Typstry; typst"\$1 / x\$"`)
```
```julia-repl
julia> using TypstJlyfish, Typstry

julia> TypstJlyfish.compile("typst_jlyfish.typ"; evaluation_file = "typst_jlyfish.json")
```
""")
`````
