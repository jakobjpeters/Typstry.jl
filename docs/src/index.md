
# Typstry.jl

A package to access the `Typst` command-line interface.

## Showcase

```julia
julia> using Pkg: add

julia> add(url = "https://github.com/jakobjpeters/Typstry.jl")

julia> using Typstry

julia> file_name = "example.typ"

julia> write(file_name, "Typst is cool")

julia> compile(file_name)
```

## Planned features

- Convert Julia values to Typst strings
- Explore rendering
    - Unicode in the REPL?
    - Other environments?

## Related Projects

- [TypstGenerator.jl](https://github.com/onecalfman/TypstGenerator.jl)
