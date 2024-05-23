
# Interface

This tutorial illustrates the Julia to Typst interface.

## Setup

```jldoctest 1
julia> import Base: show

julia> import Typstry: show_typst

julia> using Base: Docs.Text

julia> using Typstry
```

## Implementation

Consider this new type.

```jldoctest 1
julia> struct Greeting
           subject::String
       end
```

To specify its Typst formatting, implement the [`show_typst`](@ref) function.
Remember to [Annotate values taken from untyped locations](https://docs.julialang.org/en/v1/manual/performance-tips/#Annotate-values-taken-from-untyped-locations).

```jldoctest 1
julia> show_typst(io, g::Greeting) =
           print(io, "Hi ", g.subject, get(io, :excited, true)::Bool ? "!" : ".");
```

Now that the interface has been implemented for `Greeting`, it is fully supported by Typstry.jl.

```jldoctest 1
julia> g = Greeting("everyone");

julia> show_typst(IOContext(stdout, :excited => false), g)
Hi everyone.

julia> show(stdout, "text/typst", Typst(g))
Hi everyone!

julia> TypstString(g; excited = false)
typst"Hi everyone."

julia> typst"\(g)"
typst"Hi everyone!"
```

## Guidelines

While the interface itself only requires implementing a single method,
it may be more challenging to determine how a Julia value should be
represented in a Typst source file and its corresponding rendered document.
Julia and Typst are distinct languages and differ in both syntax and semantics,
so there may be multiple meaningful formats to choose from.

### Make the obvious choice, if available

- There is a clear correspondence between these Julia and Typst values

```jldoctest 1
julia> println(TypstString(1))
1

julia> println(TypstString(nothing))
#none

julia> println(TypstString(r"[a-z]"))
#regex("[a-z]")
```

### Choose the most meaningful and semantically rich representation

- This may vary across `Mode`s and domains
- Both Julia and Typst support Unicode characters, except in Typst's `code` mode

```jldoctest 1
julia> println(TypstString(π; mode = code))
3.141592653589793

julia> println(TypstString(π; mode = math))
π
```

### Consider both the Typst source text and rendered document formatting

- A `TypstString` represents Typst source text, and is printed directly
- A `String` is meaningful in different ways for each Typst mode
- A `Text` is documented to render as plain text, and therefore corresponds to text in the rendered Typst document

```jldoctest 1
julia> println(TypstString(typst"[\"a\"]"))
["a"]

julia> println(TypstString("[\"a\"]"))
"[\"a\"]"

julia> println(TypstString(text"[\"a\"]"))
#"[\"a\"]"
```

### Try to ensure that the formatting is valid Typst source text

- A `TypstString` represents Typst source text, so it may be invalid
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

### Consider edge cases

- `#1 / 2` is valid Typst source text, but is parsed as `(#1) / 2`
- `1 / 2` may be ambiguous in a mathematical expression
- `$1 / 2$` is not ambiguous

```jldoctest 1
julia> println(TypstString(1 // 2; mode = code))
(1 / 2)

julia> println(TypstString(1 // 2; mode = math))
(1 / 2)

julia> println(TypstString(1 // 2; mode = markup))
$1 / 2$
```

### Remember to update the context

- This nested `AbstractVector` changes its `Mode` to `math` and increments its `depth`

```jldoctest 1
julia> println(TypstString([true, 1, Any[1.2, 1 // 2]]))
$vec(
    "true", 1, vec(
        1.2, 1 / 2
    )
)$
```

### Check parametric and abstract types

- Similar Julia types may not be representable in the same Typst format

```jldoctest 1
julia> println(TypstString(1:2:6; mode = code))
range(1, 6, step: 2)

julia> println(TypstString(1:2.0:6; mode = code))
(1.0, 3.0, 5.0)
```
