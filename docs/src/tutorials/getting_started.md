
```@meta
DocTestSetup = :(using Typstry)
```

# Getting Started

This tutorial demonstrates the basic features of Typstry.jl and how to use them.

## Strings

Print Julia values in [`Typst`](@ref) format using `show` with the `text/typst` MIME type.
This formatting is also used to construct a [`TypstString`](@ref).

```jldoctest 1
julia> show(stdout, "text/typst", Typst(π))
$π$

julia> TypstString(π)
typst"$π$"
```

Formatting may be configured in `show` using an `IOContext` and in `TypstString` using keyword parameters.

```jldoctest 1
julia> show(IOContext(stdout, TypstContext(; mode = markup)), "text/typst", Typst(π))
$π$

julia> TypstString(π; mode = math)
typst"π"
```

Use [`@typst_str`](@ref) to directly write Typst source text.
This also supports formatted interpolation by calling the `TypstString` constructor.

```jldoctest 1
julia> typst"$ \(π; mode = math) approx \(Float64(π); mode = math) $"
typst"$ π approx 3.141592653589793 $"
```

## Commands

Use the Typst command-line interface by `run`ning a
[`TypstCommand`](@ref) created with its constructor or [`@typst_cmd`](@ref).

```jldoctest 1
julia> TypstCommand(["help"])
typst`help`

julia> typst`compile input.typ output.pdf`
typst`compile input.typ output.pdf`
```

Easily generate a Typst source file and compile it into a document using [`render`](@ref).

```jldoctest 1
julia> render(Any[true 1; 1.2 1 // 2]);
```
