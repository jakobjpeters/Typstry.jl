
# The Julia to Typst Interface

This guide illustrates how to implement Typst formatting for custom types.

!!! warning
    This interface is in active development and will receive breaking changes.

## Setup

```jldoctest 1
julia> import Base: repr, show

julia> import Typstry: TypstContext, show_typst

julia> using Typstry
```

## Implementation

Consider this custom type.

```jldoctest 1
julia> struct Hi end
```

Implement a [`show_typst`](@ref) method to specify its Typst formatting. Remember to
[Annotate values taken from untyped locations](https://docs.julialang.org/en/v1/manual/performance-tips/#Annotate-values-taken-from-untyped-locations).

```jldoctest 1
julia> show_typst(io::IO, typst_context::TypstContext, ::Hi) = print(
           io, "Hi", '!' ^ typst_context[:excitement]::Int
       );
```

Although custom formatting may be handled in `show_typst`
with `get(::TypstContext, ::Symbol, default)`,
this may be repetitive when specifying defaults for multiple methods.
There is also no way to tell if the value has been
specified by the user or if it is a default.
Instead, implement a custom [`TypstContext`](@ref) which overrides default,
but not user specifications.

```jldoctest 1
julia> TypstContext(::Hi) = TypstContext(; excitement = 0);
```

Those two methods are a complete implementation of the Julia to Typst interface.
The following methods are optional,
but enable interoperability with packages that do not know about Typstry.jl.

```jldoctest 1
julia> repr(mime::MIME"text/typst", hi::Hi; context = nothing) = TypstString(
            TypstText(sprint(show, mime, hi; context))
       );

julia> show(io::IO, mime::Union{
           MIME"application/pdf",
           MIME"image/png",
           MIME"image/svg+xml",
           MIME"text/typst"
       }, hi::Hi) = show(io, mime, Typst(hi));
```

Now, `Hi` is fully supported by Typstry.jl and implements the `show` interface.

```jldoctest 1
julia> hi = Hi();

julia> show_typst(hi)
Hi

julia> TypstString(hi; excitement = 1)
typst"Hi!"

julia> typst"\(hi; excitement = 2)"
typst"Hi!!"

julia> show(IOContext(stdout, TypstContext(; excitement = 3)), "text/typst", hi)
Hi!!!
```

## Guidelines

While implementing the interface only requires two methods,
it may be more challenging to determine how a Julia value should be
represented in a Typst source file and its corresponding compiled document.
Julia and Typst are distinct languages that differ in both syntax and semantics,
so there may be multiple meaningful formats to choose from.

### Make the obvious choice, if available

- There is a clear correspondence between these Julia and Typst values

```jldoctest 1
julia> show_typst(1)
$1$

julia> show_typst(nothing)
#none

julia> show_typst(r"[a-z]")
#regex(
  "[a-z]"
)
```

### Consider both the Typst source text and compiled document formatting

- A `Docs.Text` is documented to "render [its value] as plain text", and therefore corresponds to text in a rendered Typst document
- A `TypstString` represents Typst source text, and is printed directly

```jldoctest 1
julia> show_typst(text"[\"a\"]")
#"[\"a\"]"

julia> show_typst(typst"[\"a\"]")
["a"]
```

### Try to generate valid Typst source text

- A `TypstString` represents Typst source text, which may be invalid
- A `UnitRange{Int}` is formatted differently for each `Mode`, but is always valid

```jldoctest 1
julia> show_typst(1:4)
#range(
  1,
  5
)

julia> show_typst(1:4; mode = code)
range(
  1,
  5
)
```

### Test for edge cases

- `$1 / 2$` is not ambiguous in `markup` mode
- `1 / 2` may be ambiguous in `math` mode expressions, and should be parenthesized

```jldoctest 1
julia> show_typst(1 // 2)
$1 / 2$

julia> show_typst(1 // 2; mode = math)
(1 / 2)
```

### Format values in containers using `show_typst`

- Values may require their `TypstContext`
- The `AbstractVector` method
    - Encloses source text in dollar signs, so it changes its `Mode` to `math`
    - Formats its elements with an indent, so it increments its `depth`

```jldoctest 1
julia> show_typst([true, Any[1, 1.2]])
#math.vec(
  true,
  math.vec(
    1,
    1.2
  )
)
```

### Check parametric and abstract types

- Similar Julia types may not be representable in the same Typst format

```jldoctest 1
julia> show_typst(0:2:6)
#range(
  0,
  7,
  step: 2
)

julia> show_typst(0:2.0:6)
#math.vec(
  0.0,
  2.0,
  4.0,
  6.0
)
```

### Prefer to perform computation in Julia, rather than Typst code mode

### Choose the most semantically rich representation

### Each method of `show_typst` should correspond to the same rendering in a compiled document
