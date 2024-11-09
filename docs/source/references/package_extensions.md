
# Package Extensions

This reference documents the lazily-loaded implementations of
[`show_typst`](@ref) for types defined in external packages.

## LaTeXStrings.jl

```@docs
show_typst(::IO, ::TypstContext, ::LaTeXStrings.LaTeXString)
```

## Markdown.jl

```@docs
show_typst(::IO, ::TypstContext, ::Markdown.MD)
```
