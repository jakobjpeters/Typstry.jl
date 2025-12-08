
module TypstContexts

import Base:
    IOContext, copy, eltype, getkey, get, iterate, length,
    mergewith, merge, setindex!, show, sizehint!
import Typstry

export TypstContext, default_context, context, reset_context

"""
    TypstContext <: AbstractDict{Symbol, Any}
    TypstContext(::Any)
    TypstContext(; kwargs...)

Provide formatting data for [`show_typst`](@ref Typstry.show_typst).

Implement a method of this constructor for a custom type to specify its custom settings and parameters.

Calls to `show_typst` from the following methods:

- [`TypstString`](@ref Typstry.Strings.TypstStrings.TypstString)
- [`render`](@ref Typstry.Render.render)
- `show_typst(::IO,\u00A0::TypstContext,\u00A0x)`
- `show` with the `application/pdf`, `image/png`, `image/svg+xml`, and `text/typst`
    `MIME` types and a [`AbstractTypst`](@ref Typstry.Strings.AbstractTypsts.AbstractTypst) or [`TypstString`](@ref Typstry.Strings.TypstStrings.TypstString)

specify the [`TypstContext`](@ref) by combining the following contexts:

1. The context given by a `TypstContext` or keyword parameters, which are mutually exclusive
2. The context given by `IOContext(::IO, ::TypstContext)`
3. The `context` implicitly set when calling `show_typst` within `show_typst`
4. The type's default context, specified by implementing the `TypstContext` constructor
5. The global default [`context`](@ref Typstry.Contexts.TypstContexts.context)

Duplicate keys are handled such that each context is prioritized in order as listed.
In other words, keyword parameters and `TypstContext` parameters have the highest priority while the default `context` has the lowest priority.

# Interfaces

This type implements the dictionary and iteration interfaces.
However, it does not support removing mappings except through [`reset_context`](@ref).

- `IOContext(::IO, ::TypstContext)`
    - Equivalent to `IOContext(::IO,\u00A0:typst_context\u00A0=>\u00A0::TypstContext)`
- `copy(::TypstContext)`
- `eltype(::TypstContext)`
- `getkey(::TypstContext,\u00A0::Symbol,\u00A0::Any)`
- `get(::TypstContext,\u00A0::Symbol,\u00A0::Any)`
- `get(::Union{Function,\u00A0Type},\u00A0::TypstContext,\u00A0::Symbol)`
- `iterate(::TypstContext,\u00A0state)`
- `iterate(::TypstContext)`
- `length(::TypstContext)`
- `mergewith(::Any,\u00A0::TypstContext,\u00A0::AbstractDict...)`
- `merge(::TypstContext, ::AbstractDict...)`
- `setindex!(::TypstContext,\u00A0::Any,\u00A0::Symbol)`
- `show(::IO,\u00A0::TypstContext)`
- `sizehint!(::TypstContext,\u00A0::Any;\u00A0parameters...)`
"""
struct TypstContext <: AbstractDict{Symbol, Any}
    context::Dict{Symbol, Any}

    TypstContext(; typst_context...) = new(typst_context)
end

TypstContext(_) = TypstContext()

const default_context = TypstContext(; block = false, depth = 0, parenthesize = true, tab_size = 2)

"""
    context

A `const`ant [`TypstContext`](@ref) used to provide
default formatting data when calling [`show_typst`](@ref Typstry.Strings.show_typst).

See also [`reset_context`](@ref).

!!! tip
    Set mappings in this dictionary to customize the
    default formatting in other packages and environments.

!!! warning
    This should only be mutated by users.
    Mutating this in a package may result in conflicts.

| Setting | Type | Description |
|:--------|:-----|:------------|
| `backticks` | `Int` | The number of backticks to enclose raw text markup, which may be increased to disambiguiate nested raw text. |
| `block` | `Bool` | When `mode = math`, specifies whether the enclosing dollar signs are padded with a space to render the element inline or its own block. |
| `context` | `TypstContext` | This is set implicitly by combining the context given by a `TypstContext` or keyword parameters with that given by an `IO`. It is used when calling `show_typst` from within `show_typst`. For example, formatting values in containers or changing the type of the input. This is necessary to construct a new combined context with the nested type-level default values, rather than the root type-level default values.
| `depth` | `Int` | The current level of nesting within container types to specify the degree of indentation by repeating the `tab_size`. |
| `io` | [`DefaultIO`](@ref Typstry.Contexts.DefaultIOs.DefaultIO) | A function with the signature `io()::IO`, which is used by `show_typst` when an `IO` is not otherwise specified. This is implemented as a function to avoid initialization errors. |
| `mode` | [`Mode`](@ref Typstry.Strings.Modes.Mode) | The current Typst syntactical context where [`code`](@ref Typstry.Strings.Modes.code) follows the number sign, [`markup`](@ref Typstry.Strings.Modes.markup) is at the top-level and enclosed in square brackets, and [`math`](@ref Typstry.Strings.Modes.math) is enclosed in dollar signs. |
| `parenthesize` | `Bool` | Whether to enclose some mathematical elements in parentheses to specify their operator precedence and avoid ambiguity. |
| `preamble` | [`TypstString`](@ref Typstry.Strings.TypstStrings.TypstString) | Used at the beginning of Typst source files generated by [`render`](@ref Typstry.Render.render) and some `show` methods. |
| `tab_size` | `Int` | The number of spaces used by some elements with multi-line Typst formatting, which is repeated for each level of `depth` |

# Examples

```jldoctest
julia> context
TypstContext with 7 entries:
  :parenthesize => true
  :mode         => markup
  :block        => false
  :preamble     => TypstString(TypstText("#set page(margin: 1em, height: auto, …
  :io           => (() -> IOContext(stdout, :compact => true))::DefaultIO
  :tab_size     => 2
  :depth        => 0
```
"""
const context = TypstContext()

"""
    reset_context()::TypstContext

Remove any custom mappings from the [`context`](@ref)
such that it is returned to its default state.

See also [`TypstContext`](@ref).

# Examples

```jldoctest
julia> reset_context()
TypstContext with 7 entries:
  :parenthesize => true
  :mode         => markup
  :block        => false
  :preamble     => TypstString(TypstText("#set page(margin: 1em, height: auto, …
  :io           => (() -> IOContext(stdout, :compact => true))::DefaultIO
  :tab_size     => 2
  :depth        => 0
```
"""
reset_context() = (merge!(empty!(context.context), default_context); context)

IOContext(io::IO, typst_context::TypstContext) = IOContext(io, :typst_context => typst_context)

copy(typst_context::TypstContext) = merge!(TypstContext(), typst_context)

eltype(::TypstContext) = Any

getkey(typst_context::TypstContext, key::Symbol, default) = getkey(
    typst_context.context, key, default
)

get(typst_context::TypstContext, key::Symbol, default) = get(typst_context.context, key, default)
get(callback::Union{Function, Type}, typst_context::TypstContext, key::Symbol) = get(
    callback, typst_context.context, key
)

iterate(typst_context::TypstContext, state) = iterate(typst_context.context, state)
iterate(typst_context::TypstContext) = iterate(typst_context.context)

length(typst_context::TypstContext) = length(typst_context.context)

mergewith(combine, typst_context::TypstContext, dictionaries::AbstractDict...) = mergewith!(
    combine, copy(typst_context), dictionaries...
)

merge(typst_context::TypstContext, dictionaries::AbstractDict...) = merge!(
    copy(typst_context), dictionaries...
)

function setindex!(typst_context::TypstContext, value, key::Symbol)
    typst_context.context[key] = value
    typst_context
end

function show(io::IO, typst_context::TypstContext)
    print(io, TypstContext, '(')

    if !isempty(typst_context)
        print(io, "; ")
        Typstry.join_with(io, typst_context, ", ") do io, (key, value)
            print(io, key, " = ")
            show(io, value)
        end
    end

    print(io, ')')
end

sizehint!(typst_context::TypstContext, size; parameters...) = TypstContext(
    sizehint!(typst_context.context, size; parameters...)
)

end # TypstContexts
