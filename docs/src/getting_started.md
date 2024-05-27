
# Getting Started

## Workflow

### Setup

```jldoctest 1
julia> import Base: show

julia> import Typstry: show_typst

julia> using Typstry
```

### Strings

At the base of Typstry.jl is the [`show_typst`](@ref) function,
which prints Julia values in Typst format.


This formatting may be customized with an `IOContext`


### Commands



## Examples

This Typst source file and corresponding document were generated from Julia using \
[`show(::IO, ::MIME"text/typst", ::Union{Typst, TypstString})`](@ref) to print Julia values
to Typst format and a [`TypstCommand`](@ref) to render it.

A [`Mode`](@ref) specifies the current Typst context.
The formatting of each type corresponds to the most useful Typst value for a given mode.
If no such value exists, it is formatted to render in a canonical representation.

!!! note
    Although many of the values are rendered similarly across modes,
    the generated Typst source code may differ between them.

```@eval
using Markdown: parse
parse("```typst\n" * read("assets/strings.typ", String) * "\n```")
```

![](assets/strings.svg)
