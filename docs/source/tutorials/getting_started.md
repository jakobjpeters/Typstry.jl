
```@meta
DocTestSetup = :(using Typstry)
```

# Getting Started

This tutorial demonstrates the basic features of Typstry.jl and how to use them.

## Strings

Print Julia values in [`Typst`](@ref) format using `show` with the `text/typst` MIME type.
This formatting is also used to create a [`TypstString`](@ref).

```jldoctest 1
julia> show(stdout, "text/typst", Typst(π))
$π$

julia> TypstString(π)
typst"$π$"
```

Methods of [`show_typst`](@ref) are used to specify the Typst formatting,
which may use Julia settings and Typst parameters.
A setting is a value used in Julia, whereas a parameter is passed directly to a Typst function.
Settings each have a default value, whereas the default values of parameters are handled by Typst functions.
This [`context`](@ref) may instead be specified in `show` using an `IOContext` and in `TypstString` using keyword parameters.

```jldoctest 1
julia> show(IOContext(stdout, :mode => code), "text/typst", Typst(π))
3.141592653589793

julia> TypstString(π; mode = code)
typst"3.141592653589793"
```

Use [`@typst_str`](@ref) to directly write Typst source text.
This also supports formatted interpolation by calling the `TypstString` constructor.

```jldoctest 1
julia> typst"$ \(pi; mode = math) approx \(pi; mode = code) $"
typst"$ π approx 3.141592653589793 $"
```

## Commands

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
