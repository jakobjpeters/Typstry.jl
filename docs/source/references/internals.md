
# Internals

This reference documents implementation details.

!!! info
    A Dates.jl package extension would currently print warnings during precompilation.
    See also the [Julia issue #52511](https://github.com/JuliaLang/julia/issues/52511)

## Precompile

```@docs
Typstry.Precompile.compile_workload
```

## Strings

```@docs
Typstry.Strings.Utilities.escape
Typstry.Strings.Utilities.format
```

## Utilities

```@docs
Typstry.Utilities.enclose
Typstry.Utilities.join_with
```
