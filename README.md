
<p align="center"><img height="200px" src="docs/src/assets/logo.svg"/></p>

<div align="center">

[![Documentation dev](https://img.shields.io/badge/Documentation-dev-blue.svg)](https://jakobjpeters.github.io/Typstry.jl/dev/)
[![Codecov](https://codecov.io/gh/jakobjpeters/Typstry.jl/branch/main/graph/badge.svg?token=J38tlZ9wFs)](https://codecov.io/gh/jakobjpeters/Typstry.jl)
![License](https://img.shields.io/github/license/jakobjpeters/Typstry.jl)

[![Documentation](https://github.com/jakobjpeters/Typstry.jl/workflows/Documentation/badge.svg)](https://github.com/jakobjpeters/Typstry.jl/actions/documentation.yml)
[![Continuous Integration](https://github.com/jakobjpeters/Typstry.jl/workflows/Continuous%20Integration/badge.svg)](https://github.com/jakobjpeters/Typst.jl/actions/continuous_integration.yml)

<!-- ![Version](https://img.shields.io/github/v/release/jakobjpeters/Typstry.jl) -->
<!-- [![Downloads](https://shields.io/endpoint?url=https://pkgs.genieframework.com/api/v1/badge/Typstry)](https://pkgs.genieframework.com?packages=Typstry) -->

</div>

# Typstry.jl

A package to access the Typst command-line interface.

See also their [website](https://typst.app/),
[documentation](https://typst.app/docs/),
and [repository](https://github.com/typst/typst).

## Features

- Macros to construct Typst strings and commands
- Functions to construct and render documents

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

```
julia> document = typst"""
       #set page(width: 10cm, height: auto)
       #set heading(numbering: "1.")

       = Fibonacci sequence
       The Fibonacci sequence is defined through the recurrance relation
       $F_n = F_(n-1) + F_(n-2)$. It can also be expressed in _closed form:_

       $ F_n round(1 / sqrt(5) phi.alt^n), quad phi.alt = (1 + sqrt(5)) / 2 $

       #let count = 8
       #let nums = range(1, count + 1)
       #let fib(n) = (
           if n <= 2 { 1 }
           else { fib(n - 1) + fib(n - 2) }
       )

       The first #count numbers of the sequence are:

       #align(center, table(
           columns: count,
           ..nums.map(n => $F_#n$),
           ..nums.map(n => str(fib(n))),
       ))
       """;

julia> render(document);
```

![Showcase document](docs/src/assets/showcase.png)

## Related Projects

- [TypstGenerator.jl](https://github.com/onecalfman/TypstGenerator.jl)
- [LaTeXStrings.jl](https://github.com/JuliaStrings/LaTeXStrings.jl)
- [Latexify.jl](https://github.com/korsbo/Latexify.jl)
