
```@meta
DocTestSetup = :(using Typstry)
```

# Home

## Introduction

Typstry.jl is the interface to convert the computational power of Julia into beautifully formatted Typst documents.

### What is Typst?

Typst is an open-source and relatively new typesetting system (written in Rust 🦀🚀),
[designed to improve upon the performance and usability of LaTeX](https://typst.app/about).
See also the Typst [repository](https://github.com/typst/typst) and
[documentation](https://typst.app/docs) for examples and how to get started.

## Installation

```julia-repl
julia> using Pkg: add

julia> add("Typstry")

julia> using Typstry
```

## Showcase

```jldoctest
julia> show_typst(IOContext(stdout, :mode => code), true)
true

julia> show(stdout, "text/typst", Typst([true 1; 1.0 [Any[true 1; 1.0 nothing]]]))
$mat(
  "true", 1;
  1.0, mat(
    "true", 1;
    1.0, #none
  )
)$

julia> TypstString(1 // 2; block = true)
typst"$ 1 / 2 $"

julia> typst"$ \(1 + 2im; mode = math) $"
typst"$ (1 + 2i) $"

julia> TypstCommand(["help"])
typst`help`

julia> typst`compile input.typ output.pdf`
typst`compile input.typ output.pdf`
```

## Features

### Strings

- Print Julia values in Typst format
    - Specify Julia settings and Typst parameters
    - Implement formatting for custom types
- Construct Typst strings
    - Interpolate formatted values

### Commands

- Construct Typst commands
- Render documents using the Typst compiler
    - Display in IJulia.jl, Pluto.jl, and QuartoRunner.jl notebooks
    - Use the [JuliaMono](https://github.com/cormullion/juliamono) typeface

### Planned

- Support rendering in more environments
    - REPL Unicode?
    - Other?
- Default `auto::Mode`?
    - Automatically determine the Typst syntactic context
    - Use a tree-sitter grammar or jll package
- Documenter.jl backend and docstrings
    - Requires Typst to [output HTML](https://github.com/typst/typst/issues/721)
- Implement Typst formatting for more types
    - `Base`
        - `AbstractDict`
        - `AbstractIrrational`
        - `AbstractSet`
        - `Enum`
            - `Mode`
        - `Expr`
        - `Symbol`
    - Package extensions
        - Standard Library
            - LinearAlgebra.jl
    - A symbolic `TypstFunction`?
        - May faciliate partial Julia to Typst transpilation
        - Examples
            - `TypstString(TypstFunction(eval, :(1//2); mode = code)) == typst"eval("(1 / 2)", mode: \"code\")"`
            - `TypstString(TypstFunction(*, :a, :b; mode = math)) == typst"(a) (b)"`

## Similar Packages

### Typst

- [Labelyst.jl](https://github.com/emanuel-kopp/Labelyst.jl)
- [SummaryTables.jl](https://github.com/PumasAI/SummaryTables.jl)
- [TypstGenerator.jl](https://github.com/onecalfman/TypstGenerator.jl)
- [TypstJlyFish.jl](https://github.com/andreasKroepelin/TypstJlyfish.jl)
    - Interoperable with Typstry.jl
- [Typst_jll.jl](https://github.com/JuliaBinaryWrappers/Typst_jll.jl)
    - Dependency of Typstry.jl

### LaTeX

- [Latexify.jl](https://github.com/korsbo/Latexify.jl)
- [LaTeXEntities.jl](https://github.com/JuliaString/LaTeX_Entities.jl)
- [LaTeXStrings.jl](https://github.com/JuliaStrings/LaTeXStrings.jl)
- [LatexPrint.jl](https://github.com/scheinerman/LatexPrint.jl)
- [LibTeXPrintf.jl](https://github.com/JuliaStrings/LibTeXPrintf.jl)
- [MakieTeX.jl](https://github.com/JuliaPlots/MakieTeX.jl)
    - Dependent of Typstry.jl
- [MathJaxRenderer.jl](https://github.com/MichaelHatherly/MathJaxRenderer.jl)
- [MathTeXEngine.jl](https://github.com/Kolaru/MathTeXEngine.jl)
- [tectonic_jll.jl](https://github.com/JuliaBinaryWrappers/tectonic_jll.jl)
