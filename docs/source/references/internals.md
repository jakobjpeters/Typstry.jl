
# Internals

This reference documents non-public utilities.

```@docs
Typstry.compile_workload
```

## Strings

```@docs
Typstry.Strings
Typstry.Strings.examples
Typstry.Strings.typst_mime
Typstry.Strings.backticks
Typstry.Strings.block
Typstry.Strings.code_mode
Typstry.Strings.depth
Typstry.Strings.enclose
Typstry.Strings.indent
Typstry.Strings.join_with
Typstry.Strings.math_mode
Typstry.Strings.math_pad
Typstry.Strings.maybe_wrap
Typstry.Strings.mode
Typstry.Strings.parenthesize
Typstry.Strings.show_array
Typstry.Strings.show_parameters
Typstry.Strings.show_raw
Typstry.Strings.show_vector
Typstry.Strings.escape
```

### Dates.jl

!!! info
    A Dates.jl package extension would currently print warnings during precompilation.
    See also the [Julia issue #52511](https://github.com/JuliaLang/julia/issues/52511)

```@docs
Typstry.Strings.date_time
Typstry.Strings.duration
Typstry.Strings.dates
```

## Commands

```@docs
Typstry.Commands
Typstry.Commands.typst_compiler
Typstry.Commands.apply
Typstry.Commands.format
```
