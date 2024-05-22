
<!-- This file is generated by `.github/workflows/readme.yml`; do not edit directly. -->

<p align="center"><img height="200px" src="docs/src/assets/logo.svg"/></p>

<div align="center">

[![Documentation stable](https://img.shields.io/badge/Documentation-stable-blue.svg)](https://jakobjpeters.github.io/Typstry.jl/)
[![Documentation development](https://img.shields.io/badge/Documentation-development-blue.svg)](https://jakobjpeters.github.io/Typstry.jl/development/)

[![Continuous Integration](https://github.com/jakobjpeters/Typstry.jl/workflows/Continuous%20Integration/badge.svg)](https://github.com/jakobjpeters/Typstry.jl/actions/workflows/continuous_integration.yml)
[![Documentation](https://github.com/jakobjpeters/Typstry.jl/workflows/Documentation/badge.svg)](https://github.com/jakobjpeters/Typstry.jl/actions/workflows/documentation.yml)

[![Codecov](https://codecov.io/gh/jakobjpeters/Typstry.jl/branch/main/graph/badge.svg?token=XFWU66WSD7)](https://codecov.io/gh/jakobjpeters/Typstry.jl)
[![Dependents](https://juliahub.com/docs/General/Typstry/stable/deps.svg)](https://juliahub.com/ui/Packages/General/Typstry?t=2)

</div>

# Typstry.jl

## Introduction

Typstry.jl is the interface to convert the computational power of Julia into
beautifully formatted [Typst](https://github.com/typst/typst) documents.

## Installation

```julia
julia> using Pkg: add

julia> add("Typstry")

julia> using Typstry
```

## Showcase

```julia
julia> show_typst(IOContext(stdout, :mode => code), 'a')
"'a'"

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

julia> addenv(typst`compile input.typ output.pdf`, "TYPST_FONT_PATHS" => julia_mono)
typst`compile input.typ output.pdf`
```

## Features

### Strings

- Convert Julia values to Typst format
    - Specify Julia settings and Typst parameters
    - Implement formatting for custom types
- Create and manipulate Typst formatted strings
    - Interpolate formatted values
    - Render in Pluto.jl notebooks

### Commands

- Construct Typst commands
- Render documents using the Typst compiler
    - Use the [JuliaMono](https://github.com/cormullion/juliamono) typeface

### Planned

- Implement Typst formatting for more types
    - `Base`
    - Standard Library
    - Package extensions
- Support rendering in more environments
    - IJulia.jl
    - Quarto?
    - REPL Unicode?
    - Other?

## Related Packages

### Typst

- [Labelyst.jl](https://github.com/emanuel-kopp/Labelyst.jl)
- [SummaryTables.jl](https://github.com/PumasAI/SummaryTables.jl)
- [TypstGenerator.jl](https://github.com/onecalfman/TypstGenerator.jl)
- [Typst_jll.jl](https://github.com/JuliaBinaryWrappers/Typst_jll.jl)

### LaTeX

- [Latexify.jl](https://github.com/korsbo/Latexify.jl)
- [LaTeXStrings.jl](https://github.com/JuliaStrings/LaTeXStrings.jl)
- [LatexPrint.jl](https://github.com/scheinerman/LatexPrint.jl)
