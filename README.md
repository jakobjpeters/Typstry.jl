
# Typstry.jl

<p align="center"><img width="200px" src="docs/src/assets/logo.svg"/></p>

<div align="center">

[![Documentation dev](https://img.shields.io/badge/Documentation-dev-blue.svg)](https://jakobjpeters.github.io/Typstry.jl/dev/)
[![Codecov](https://codecov.io/gh/jakobjpeters/Typstry.jl/branch/main/graph/badge.svg?token=J38tlZ9wFs)](https://codecov.io/gh/jakobjpeters/Typstry.jl)
![License](https://img.shields.io/github/license/jakobjpeters/Typstry.jl)

[![Documentation](https://github.com/jakobjpeters/Typstry.jl/workflows/Documentation/badge.svg)](https://github.com/jakobjpeters/Typstry.jl/actions/documentation.yml)
[![Continuous Integration](https://github.com/jakobjpeters/Typstry.jl/workflows/Continuous%20Integration/badge.svg)](https://github.com/jakobjpeters/Typst.jl/actions/continuous_integration.yml)

<!-- ![Version](https://img.shields.io/github/v/release/jakobjpeters/Typstry.jl) -->
<!-- [![Downloads](https://shields.io/endpoint?url=https://pkgs.genieframework.com/api/v1/badge/Typstry)](https://pkgs.genieframework.com?packages=Typstry) -->

</div>

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
