
module TypstContexts

import Base: eltype, get, iterate, length, show
using Preferences: @load_preference
using ..Strings: Utilities.set_preference, Typst, markup

"""
    TypstContext <: AbstractDict{Symbol, Any}
    TypstContext(; kwargs...)

Provide formatting data for [`show_typst`](@ref).

# Interfaces

This type implements the dictionary, iteration, interfaces.
However, it is immutable such that it does not support inserting, deleting, or setting a key-value pair.

- `eltype(::TypstContext)`
- `get(::TypstContext, ::Symbol, default)`
- `get(::Union{Function, Type}, ::TypstContext, ::Symbol)`
- `iterate(::TypstContext, state)`
- `iterate(::TypstContext)`
- `length(::TypstContext)`
- `show(::IO, ::TypstContext)`
"""
struct TypstContext <: AbstractDict{Symbol, Any}
    context::Dict{Symbol, Any}

    TypstContext(; kwargs...) = new(Dict(kwargs))
end

"""
    TypstContext(::Typst)

Return the `TypstContext` of the value wrapped in [`Typst`](@ref).
"""
TypstContext(x::Typst) = TypstContext(x.value)

"""
    TypstContext(::Any)

Implement a method of this constructor for a custom type to specify its custom settings and parameters.
"""
TypstContext(x) = TypstContext()

eltype(tc::TypstContext) = eltype(tc.context)

get(tc::TypstContext, key::Symbol, default) = get(tc.context, key, default)
get(f::Union{Function, Type}, tc::TypstContext, key::Symbol) = get(f, tc.context, key)

iterate(tc::TypstContext, state) = iterate(tc.context, state)
iterate(tc::TypstContext) = iterate(tc.context)

length(tc::TypstContext) = length(tc.context)

function show(io::IO, tc::TypstContext)
    print(io, TypstContext, "(")
    if !isempty(tc)
        print(io, "; ")
        join_with(io, tc, ", ") do io, (key, value)
            print(io, key, " = ")
            show(io, value)
        end
    end
    print(io, ")")
end

const default_context = TypstContext(;
    backticks = 3,
    block = false,
    depth = 0,
    mode = markup,
    parenthesize = true,
    tab_size = 2
)

"""
    merge_contexts(tc, context)
"""
merge_contexts!(tc, context) = mergewith!((x, _) -> x, tc.context, context)

"""
    context

A `const`ant [`TypstContext`](@ref) used default formatting data when calling [`show_typst`](@ref).

May be configured using [`set_context`](@ref).

# Examples

```jldoctest
julia> context
TypstContext with 6 entries:
  :mode         => markup
  :parenthesize => true
  :block        => false
  :tab_size     => 2
  :backticks    => 3
  :depth        => 0
```
"""
const context = let
    tc = @load_preference "context" TypstContext()
    merge_contexts!(tc, default_context)
    tc
end

set_context(tc::TypstContext) = set_preference("context", tc)
set_context() = set_preference("context")

"""
    set_context(::TypstContext)
    set_context()

Use Preferences.jl such that after restarting Julia,
the [`context`](@ref) is initialized to the given
[`TypstContext`](@ref) merged with default settings.

Specifying a key contained in the default settings will override it.
If a `TypstContext` is not provided, the `context` is reset to the default settings.

| Setting        | Default  | Type           | Description                                                                                                                                                                       |
|:---------------|:---------|:---------------|:----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `backticks`    | `3`      | `Int`          | The number of backticks to enclose raw text markup, which may be increased to disambiguiate nested raw text.                                                                      |
| `block`        | `false`  | `Bool`         | When `mode = math`, specifies whether the enclosing dollar signs are padded with a space to render the element inline or its own block.                                           |
| `depth`        | `0`      | `Int`          | The current level of nesting within container types to specify the degree of indentation by repeating the `tab_size`.                                                             |
| `mode`         | `markup` | [`Mode`](@ref) | The current Typst syntactical context where `code` follows the number sign, `markup` is at the top-level and enclosed in square brackets, and `math` is enclosed in dollar signs. |
| `parenthesize` | `true`   | `Bool`         | Whether to enclose some mathematical elements in parentheses to specify their operator precedence and avoid ambiguity.                                                            |
| `tab_size`     | `2`      | `Int`          | The number of spaces used by some elements with multi-line Typst formatting, which is repeated for each level of `depth`                                                          |
"""
set_context

end # TypstContexts
