
```@meta
DocTestSetup = :(using Typstry)
```

# Typstry.jl

A package to access the Typst command-line interface.

See also their [website](https://typst.app/),
[documentation](https://typst.app/docs/),
and [repository](https://github.com/typst/typst).

## Features

- Write Typst code
- Create and run Typst commands
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
julia> typst"$1 / x$"
"\$1 / x\$"

julia> typst`compile input.typ output.pdf`;

julia> typst("help");
The Typst compiler

Usage: typst [OPTIONS] <COMMAND>

Commands:
  compile  Compiles an input file into a supported output format [aliases: c]
  watch    Watches an input file and recompiles on changes [aliases: w]
  query    Processes an input file to extract provided metadata
  fonts    Lists all discovered fonts in system and custom font paths
  update   Self update the Typst CLI (disabled)
  help     Print this message or the help of the given subcommand(s)

Options:
  -v, --verbosity...  Sets the level of logging verbosity: -v = warning & error, -vv = info, -vvv = debug, -vvvv = trace
      --cert <CERT>   Path to a custom CA certificate to use when making network requests [env: TYPST_CERT=]
  -h, --help          Print help
  -V, --version       Print version

julia> render(typst"""
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
       """);
```

![Showcase document](./assets/showcase.png)

## Related Packages

- [TypstGenerator.jl](https://github.com/onecalfman/TypstGenerator.jl)
- [Latexify.jl](https://github.com/korsbo/Latexify.jl)
- [LaTeXStrings.jl](https://github.com/JuliaStrings/LaTeXStrings.jl)
- [LatexPrint.jl](https://github.com/scheinerman/LatexPrint.jl)
