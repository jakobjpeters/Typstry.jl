
```@meta
DocTestSetup = :(using Typstry)
```

# Home

## Introduction

Julia is a language designed for high-performance scientific computing.
[Typst](https://github.com/typst/typst) is a language designed for easy and precise typesetting.
Typstry.jl is the interface to convert the computational power of Julia into beautifully formatted Typst documents.

## Installation

```julia
julia> using Pkg: add

julia> add(; url = "https://github.com/jakobjpeters/Typstry.jl")

julia> using Typstry
```

## Showcase

```jldoctest
julia> show_typst(IOContext(stdout, :mode => code), 'a')
"'a'"

julia> show(stdout, "text/typst", [true 1; 1.0 [Any[true 1; 1.0 nothing]]])
$mat(
    "true", 1;
    1.0, mat(
        "true", 1;
        1.0, ""
    )
)$

julia> TypstString(1 // 2, :inline => false)
typst"$ 1 / 2 $"

julia> typst"$ \(1 + 2im, :mode => math) $"
typst"$ 1 + 2i $"

julia> TypstCommand(["help"])
typst`help`

julia> typst`compile input.typ output.pdf`
typst`compile input.typ output.pdf`
```

## Features

- Strings
    - Convert Julia values to Typst using `show` with the `"text/typst"` MIME type
        - Specify Julia settings and Typst parameters in the `IOContext`
        - Implement `show_typst` for custom types
    - Create and manipulate `TypstString`s
        - Interpolate formatted Julia values using `@typst_str`
- Commands
    - Render documents using the Typst command-line interface
    - Construct `TypstCommand`s with vectors of strings or using `@typst_cmd`

### Planned

- Implement `show_typst` for more types
    - `Base`
    - Standard Library
    - Package extensions
- Explore rendering environments
    - REPL Unicode
    - Notebooks
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
