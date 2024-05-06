
```@meta
DocTestSetup = :(using Typstry)
```

# Typstry.jl

A package to access the Typst command-line interface.

See also Typst's [website](https://typst.app/),
[documentation](https://typst.app/docs/),
and [repository](https://github.com/typst/typst).

## Features

- Write Typst strings
- Run Typst commands
- Construct and render documents

### Planned

- Convert Julia values to Typst strings
- Explore rendering
    - Unicode in the REPL?
    - Other environments?

## Installation

```julia
julia> using Pkg: add

julia> add(url = "https://github.com/jakobjpeters/Typstry.jl")

julia> using Typstry
```

## Showcase

```jldoctest
julia> typst"\(1 // 2)"
typst"$1 / 2$"
```

## Related Packages

### Typst

- [TypstGenerator.jl](https://github.com/onecalfman/TypstGenerator.jl)
- [Labelyst.jl](https://github.com/emanuel-kopp/Labelyst.jl)

### LaTeX

- [Latexify.jl](https://github.com/korsbo/Latexify.jl)
- [LaTeXStrings.jl](https://github.com/JuliaStrings/LaTeXStrings.jl)
- [LatexPrint.jl](https://github.com/scheinerman/LatexPrint.jl)
