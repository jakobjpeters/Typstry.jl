
# Interoperability

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

```@setup 1
using Logging: Debug, Warn, disable_logging
disable_logging(Warn)
```

```@repl 1
using CairoMakie, MakieTeX
disable_logging(Debug) # hide
f = Figure(; size = (100, 100));
LTeX(f[1, 1], TypstDocument(typst"$1 / x$"); scale = 5);
save("makie_tex.svg", f);
```

![MakieTeX.jl](makie_tex.svg)

### TypstJlyfish.jl

```````@eval
using Markdown, Typstry
s = preamble * typst"""
#import "@preview/jlyfish:0.1.0": *
#read-julia-output(json("typst_jlyfish.json"))
#jl-pkg("Typstry")
#jl(`using Typstry; typst"$1 / x$"`)
"""
write("typst_jlyfish.typ", s)
Markdown.parse("`````typst\n" * s * "\n`````")
```````

```@repl
using TypstJlyfish
TypstJlyfish.compile("typst_jlyfish.typ";
    evaluation_file = "typst_jlyfish.json",
    typst_compile_args = "--format=svg"
)
```

![TypstJlyfish.jl](typst_jlyfish.svg)
