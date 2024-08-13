
# Package Interoperability

This guide illustrates how to use Typstry.jl in compatible notebooks and packages.

## Notebooks

IJulia.jl, Pluto.jl, and QuartoNotebookRunner.jl each [`render`](@ref) [`Typst`](@ref)s and [`TypstText`](@ref)s.
Pluto.jl and QuartoNotebookRunner.jl also `render` [`TypstString`](@ref)s,
whereas IJulia.jl will support them in its next feature release.

## Packages

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
using Markdown: Markdown
using Typstry:  preamble
Markdown.parse("""```typst
$preamble#import "@preview/jlyfish:0.1.0": *
#read-julia-output(json("typst_jlyfish.json"))
#jl-pkg("Typstry")
#jl(`using Typstry; typst"\$1 / x\$"`)
```

```julia-repl
julia> using TypstJlyfish, Typstry

julia> TypstJlyfish.compile("typst_jlyfish.typ";
           evaluation_file = "typst_jlyfish.json",
           typst_compile_args = "--format=svg --font-path=\$julia_mono"
       )
```""")
`````
