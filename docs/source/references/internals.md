
# Internals

This reference documents non-public utilities.

!!! info
    A Dates.jl package extension would currently print warnings during precompilation.
    See also the [Julia issue #52511](https://github.com/JuliaLang/julia/issues/52511)

```@docs
Typstry.examples
```

## Contexts

```@docs
Typstry.default_context
```

## Utilities

```@docs
Typstry.compile_workload
Typstry.enclose
Typstry.join_with
Typstry.unwrap
```

## Strings

```@docs
Typstry.code_mode
Typstry.escape
Typstry.format
Typstry.indent
Typstry.math_mode
Typstry.math_pad
```
