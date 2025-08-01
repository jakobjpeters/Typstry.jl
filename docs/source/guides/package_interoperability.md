
# Package Interoperability

This guide illustrates how to use Typstry.jl in compatible notebooks and packages.

## Notebooks

IJulia.jl, Pluto.jl, and QuartoNotebookRunner.jl each display
[`TypstString`](@ref)s, [`TypstText`](@ref)s, and [`Typst`](@ref)s using
`show` with the `application/pdf`, `image/png`, and `image/svg+xml` `MIME` types.

!!! tip
    Set mappings in [`context`](@ref) to customize the default formatting in these environments.

## Typst Packages

Compiling a document which imports a Typst package can be achieved in exactly the
same manner as compiling a standard Typst source file with the command-line interface.
For example:

```julia
typst"#import \"@namespace/name:version\""
```

## Julia Packages

### Literate.jl

### Luxor.jl

```julia-repl
julia> using Luxor: @svg, O, text

julia> using Typstry: @typst_str

julia> @svg text(typst\"Hi cormullion!\", O)
```

### MakieTeX.jl

!!! note
    This package re-exports [`@typst_str`](@ref) and [`TypstString`](@ref).

`````@eval
using Markdown: Markdown
Markdown.parse("""```julia-repl
julia> using CairoMakie, MakieTeX

julia> f = Figure(; size = (100, 100))

julia> LTeX(f[1, 1], TypstDocument(typst"Hi Anshul Singhvi!"))

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
#jl(`using Typstry; typst"Hi Andreas Kröpelin!"`)
```
```julia-repl
julia> using TypstJlyfish, Typstry

julia> TypstJlyfish.compile("typst_jlyfish.typ"; evaluation_file = "typst_jlyfish.json")
```
""")
`````
