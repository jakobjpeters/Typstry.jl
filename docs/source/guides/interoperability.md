
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
using Logging: Info, Debug, Warn, disable_logging # hide
disable_logging(Warn) # hide
```

```@repl 1
using CairoMakie, MakieTeX, Typstry
disable_logging(Debug) # hide
f = Figure(; size = (100, 100));
LTeX(f[1, 1], TypstDocument(preamble * typst"$ 1 / x $"); scale = 2);
save("makie_tex.svg", f);
```

![MakieTeX.jl](makie_tex.svg)

### TypstJlyfish.jl

```````@eval
using Logging: Debug, Info, disable_logging
using Markdown: Markdown
using TypstJlyfish: compile
using Typstry: @typst_str, julia_mono, preamble
s = preamble * typst"""
#import "@preview/jlyfish:0.1.0": *
#read-julia-output(json("typst_jlyfish.json"))
#jl-pkg("Typstry")
#jl(`using Typstry; typst"$1 / x$"`)
"""
write("typst_jlyfish.typ", s)
disable_logging(Info)
redirect_stderr(() -> compile("typst_jlyfish.typ";
    evaluation_file = "typst_jlyfish.json",
    typst_compile_args = "--format=svg --font-path=$julia_mono"
), devnull)
disable_logging(Debug)
Markdown.parse("`````typst\n" * s * "\n`````")
```````

```julia-repl
julia> using TypstJlyfish, Typstry

julia> TypstJlyfish.compile("typst_jlyfish.typ";
           evaluation_file = "typst_jlyfish.json",
           typst_compile_args = "--format=svg --font-path=$julia_mono"
       )
```

![TypstJlyfish.jl](typst_jlyfish.svg)
