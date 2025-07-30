
# Package Extensions

This reference documents the lazily-loaded implementations of
[`show_typst`](@ref) for types defined in external packages.

## LaTeXStrings.jl

`````julia-repl
julia> using LaTeXStrings, Typstry

julia> show_typst(L"$a$")
```latex $a$```
`````

## Markdown.jl

`````julia-repl
julia> using Markdown, Typstry

julia> show_typst(md"# A")
```markdown # A```
`````
