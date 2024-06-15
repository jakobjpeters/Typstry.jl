
# Interface

This tutorial illustrates the Julia to Typst interface.

## Setup

```jldoctest 1
julia> import Base: show

julia> import Typstry: context, show_typst

julia> using Typstry
```

## Implementation

Consider this custom type.

```jldoctest 1
julia> struct Reciprocal{N <: Number}
           n::N
       end
```

Implement a [`show_typst`](@ref) method to specify its Typst formatting. Remember to
[Annotate values taken from untyped locations](https://docs.julialang.org/en/v1/manual/performance-tips/#Annotate-values-taken-from-untyped-locations).

```jldoctest 1
julia> show_typst(io, r::Reciprocal) =
           if io[:mode]::Mode == markup
               print(io, "#let reciprocal(n) = \$1 / #n\$")
           else
               print(io, "reciprocal(")
               show(io, MIME"text/typst"(), Typst(round(r.n; digits = io[:digits]::Int)))
               print(io, ")")
           end;
```

Although custom formatting may be handled in `show_typst` with `get(io, key, default)`,
this may be repetitive when specifying defaults for multiple methods.
There is also no way to tell if the value has been
specified by the user or if it is a default.
Instead, implement a custom [`context`](@ref) which overrides default,
but not user specifications.

```jldoctest 1
julia> context(::Reciprocal) = Dict(:digits => 2);
```

Those two methods are a complete implementation of the Julia to Typst interface.
The following method is optional:

```jldoctest 1
julia> show(io::IO, m::MIME"text/typst", r::Reciprocal) = show(io, m, Typst(r));
```

Now, a `Reciprocal` is fully supported by Typstry.jl.

```jldoctest 1
julia> r = Reciprocal(π);

julia> println(TypstString(r))
#let reciprocal(n) = $1 / #n$

julia> println(TypstString(r; mode = math))
reciprocal(3.14)

julia> println(TypstString(r; mode = math, digits = 4))
reciprocal(3.1416)
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
julia> println(TypstString(1))
$1$

julia> println(TypstString(nothing))
#none

julia> println(TypstString(r"[a-z]"))
#regex("[a-z]")
```

### Choose the most semantically rich representation

- This may vary across `Mode`s and domains
    - Some modes may not have a meaningful representation, and should be formatted into a mode that does
- Both Julia and Typst support Unicode characters, except unknown variables in Typst's `code` mode

```jldoctest 1
julia> println(TypstString(π; mode = code))
3.141592653589793

julia> println(TypstString(π; mode = math))
π

julia> println(TypstString(π; mode = markup))
$π$
```

### Consider both the Typst source text and compiled document formatting

- A `Docs.Text` is documented to "render [its value] as plain text", and therefore corresponds to text in a rendered Typst document
- A `TypstString` represents Typst source text, and is printed directly

```jldoctest 1
julia> println(TypstString(text"[\"a\"]"))
["a"]

julia> println(TypstString(typst"[\"a\"]"))
["a"]
```

### Try to generate valid Typst source text

- A `TypstString` represents Typst source text, which may be invalid
- A `UnitRange{Int}` is formatted differently for each `Mode`, but is always valid

```jldoctest 1
julia> println(TypstString(1:4; mode = code))
range(1, 5)

julia> println(TypstString(1:4; mode = math))
vec(
  1, 2, 3, 4
)

julia> println(TypstString(1:4; mode = markup))
$vec(
  1, 2, 3, 4
)$
```

### Test for edge cases

- `#1 / 2` is valid Typst source text, but is parsed partially in `code` mode as `(#1) / 2`
- `1 / 2` may be ambiguous in a `math` mode expression
- `$1 / 2$` is not ambiguous in `markup` mode

```jldoctest 1
julia> println(TypstString(1 // 2; mode = code))
(1 / 2)

julia> println(TypstString(1 // 2; mode = math))
(1 / 2)

julia> println(TypstString(1 // 2; mode = markup))
$1 / 2$
```

### Format values in containers using `show` with the `text/typst` MIME type

- Values may require some of their `context`
- The `AbstractVector` method changes its `Mode` to `math` and increments its `depth`

```jldoctest 1
julia> println(TypstString([true, 1, Any[1.2, 1 // 2]]))
$vec(
  "true", 1, vec(
    1.2, 1 / 2
  )
)$
```

### Check parametric and abstract types

- Related Julia types may not be representable in the same Typst format

```jldoctest 1
julia> println(TypstString(0:2:6; mode = code))
range(0, 7, step: 2)

julia> println(TypstString(0:2.0:6; mode = code))
(0.0, 2.0, 4.0, 6.0)
```

### Prefer simplicity
