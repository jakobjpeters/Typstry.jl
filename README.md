
# Typstry.jl

[![codecov](https://codecov.io/gh/jakobjpeters/Typstry.jl/branch/main/graph/badge.svg?token=J38tlZ9wFs)](https://codecov.io/gh/jakobjpeters/Typstry.jl)
[![Continuous Integration](https://github.com/jakobjpeters/Typstry.jl/workflows/Continuous%20Integration/badge.svg)](https://github.com/jakobjpeters/Typst.jl/actions/continuous_integration.yml)
![License](https://img.shields.io/github/license/jakobjpeters/Typstry.jl)

A package to access the `Typst` command-line interface.

## Showcase

```julia
julia> using Pkg

julia> Pkg.add(url = "https://github.com/jakobjpeters/Typstry.jl")

julia> using Typstry

julia> file_name = "example.typ";

julia> write(file_name, "Typst is cool");

julia> compile(file_name);
```

## Planned features

- Implement interpolation within `@T_str`
- Convert Julia values to Typst strings

## Related Projects

- [TypstGenerator.jl](https://github.com/onecalfman/TypstGenerator.jl)
