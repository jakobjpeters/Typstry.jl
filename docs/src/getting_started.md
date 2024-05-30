
```@meta
DocTestSetup = :(using Typstry)
```

# Getting Started

## Basics

### Strings

Print Julia values in [`Typst`](@ref) format using `show` with the `text/typst` MIME type.

```jldoctest 1
julia> show(stdout, "text/typst", Typst(π))
π
```

Some methods use an `IOContext` to configure the formatting.

```jldoctest 1
julia> show(IOContext(stdout, :mode => code), "text/typst", Typst(π))
3.141592653589793
```

Instead of printing, create a [`TypstString`](@ref) using its constructor or
[`@typst_str`](@ref) with formatted interpolation.

```jldoctest 1
julia> TypstString(π)
typst"π"

julia> TypstString(π; mode = code)
typst"3.141592653589793"

julia> typst"$ \(pi) approx \(pi; mode = code) $"
typst"$ π approx 3.141592653589793 $"
```

### Commands

Use [`render`](@ref) to easily generate a Typst source file and compile it into a document.

```jldoctest 1
julia> render(Any[true 1; 1.2 1 // 2]);
```

Compile source files by `run`ning a [`TypstCommand`](@ref) created using its constructor or [`@typst_cmd`](@ref).

```jldoctest 1
julia> TypstCommand(["help"])
typst`help`

julia> run(typst`compile input.typ output.pdf`);
```

## Examples

This Typst source file was generated from Julia using `show` with the
`text/typst` MIME type and compiled using a `TypstCommand`.

!!! note
    Although many of the values are rendered similarly across modes,
    the generated Typst source code may differ between them.

```@eval
using Markdown: parse
parse("```typst\n" * read("assets/strings.typ", String) * "\n```")
```

![](assets/strings.svg)
