
# Internals

This reference documents non-public utilities.

!!! info
    A Dates.jl package extension would currently print warnings during precompilation.
    See also the [Julia issue #52511](https://github.com/JuliaLang/julia/issues/52511)

```@docs
Typstry.examples
```

## Utilities

```@docs
Typstry.compile_workload
Typstry.code_mode
Typstry.date_time
Typstry.dates
Typstry.duration
Typstry.enclose
Typstry.escape
Typstry.indent
Typstry.format
Typstry.join_with
Typstry.math_mode
Typstry.math_pad
Typstry.merge_contexts!
Typstry.show_array
Typstry.show_parameters
Typstry.show_raw
Typstry.show_vector
Typstry.typst_context
Typstry.unwrap
```

## Contexts

```@docs
Typstry.default_context
```

## Strings

```@docs
Typstry.backticks
Typstry.base_type
Typstry.block
Typstry.io_context
Typstry.default_io_context
Typstry.depth
Typstry.mode
Typstry.parenthesize
Typstry.preamble
Typstry.tab_size
```
