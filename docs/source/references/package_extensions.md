
# Package Extensions

This reference documents the lazily-loaded implementations of
[`show_typst`](@ref) for types defined in external packages.

## LaTeXStrings.jl

```jldoctest
julia> using LaTeXStrings, Typstry

julia> show_typst(L"")
#raw(
  "$$",
  block: false,
  lang: "latex"
)
```

## Markdown.jl

```jldoctest
julia> using Markdown, Typstry

julia> show_typst(md"a")
#raw(
  "a",
  block: false,
  lang: "markdown"
)
```
