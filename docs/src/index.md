
```@meta
DocTestSetup = :(using Typstry)
```

# Home

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

```jldoctest
julia> show_typst(IOContext(stdout, :mode => code), 'a')
"'a'"

julia> show(stdout, "text/typst", [true 1; 1.0 [Any[true 1; 1.0 nothing]]])
$ mat(
    "true", 1;
    1.0, mat(
        "true", 1;
        1.0, ""
    )
) $

julia> TypstString(1 // 2, :inline => true)
typst"$1 / 2$"

julia> typst"$ \(1 + 2im, :mode => math) $"
typst"$ 1 + 2i $"

julia> TypstCommand(["help"])
typst`help`

julia> addenv(typst`compile input.typ output.pdf`, "TYPST_FONT_PATHS" => julia_mono)
typst`compile input.typ output.pdf`
```

## Features

### Strings

- Convert Julia values to Typst format using `show(::IO, ::MIME"text/typst", ::Any)`
    - Specify Julia settings and Typst parameters in the `IOContext`
    - Implement `show_typst` for custom types
- Create and manipulate `TypstString`s
    - Interpolate formatted values using `@typst_str`
    - Render in Pluto.jl notebooks

### Commands

- Construct `TypstCommand`s with a `Vector{String}` or using `@typst_cmd`
- Render documents using the Typst compiler
    - Use the [JuliaMono](https://github.com/cormullion/juliamono) typeface

### Planned

- Implement `show_typst` for more types
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
