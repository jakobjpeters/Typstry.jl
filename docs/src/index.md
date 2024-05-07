
```@meta
DocTestSetup = :(using Typstry)
```

# Typstry.jl

See also Typst's [website](https://typst.app/),
[documentation](https://typst.app/docs/),
and [repository](https://github.com/typst/typst).

## Features

- Write Typst strings
    - Convert Julia values
- Run Typst commands

### Planned

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

## Related Packages

### Typst

- [TypstGenerator.jl](https://github.com/onecalfman/TypstGenerator.jl)
- [Labelyst.jl](https://github.com/emanuel-kopp/Labelyst.jl)
- [SummaryTables.jl](https://github.com/PumasAI/SummaryTables.jl)

### LaTeX

- [Latexify.jl](https://github.com/korsbo/Latexify.jl)
- [LaTeXStrings.jl](https://github.com/JuliaStrings/LaTeXStrings.jl)
- [LatexPrint.jl](https://github.com/scheinerman/LatexPrint.jl)
