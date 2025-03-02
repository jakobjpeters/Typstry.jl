
"""
    TypstContext <: AbstractDict{Symbol, Any}
    TypstContext(::Any)
    TypstContext(; kwargs...)

Provide formatting data for [`show_typst`](@ref).

Implement a method of this constructor for a custom type to specify its custom settings and parameters.

Calls to [`show_typst`](@ref) from the following methods:

- [`TypstString`](@ref)
- [`render`](@ref)
- `show_typst(::IO,\u00A0::TypstContext,\u00A0x)`
- `show` with the `application/pdf`, `image/png`, `image/svg+xml`, and `text/typst`
    `MIME` types and a `TypstString`, `TypstText`, and `Typst` value

specify the [`TypstContext`](@ref) by combining the following contexts:

1. The [`context`](@ref)
2. Any context specified by implementing the `TypstContext` constructor for the given type
3. The context specified in the call by keyword parameters,
    a given `TypstContext`, or the `IOContext` key `:typst_context`,
    depending on the calling method
4. Any context specified by a recursive call in `show_typst` to format values,
    such as elements from a container

Duplicate keys are handled such that each successive context overwrites
those of previous contexts, prioritized in order as listed.
In other words, the default `context` has the lowest priority while
recursive calls to `show_typst` have the highest priority.

# Interfaces

This type implements the dictionary and iteration interfaces.
However, it does not support removing mappings.

- `copy(::TypstContext)`
- `eltype(::TypstContext)`
- `getkey(::TypstContext, ::Any, ::Any)`
- `get(::TypstContext,\u00A0::Any,\u00A0::Any)`
- `get(::Union{Function, Type},\u00A0::TypstContext,\u00A0::Any)`
- `iterate(::TypstContext,\u00A0state)`
- `iterate(::TypstContext)`
- `length(::TypstContext)`
- `mergewith(::Any, ::TypstContext, ::AbstractDict...)`
- `merge!(::TypstContext, ::AbstractDict...)`
- `merge(::TypstContext, ::AbstractDict...)`
- `setindex!(::TypstContext, ::Any, ::Any)`
- `show(::IO,\u00A0::TypstContext)`
- `sizehint!(::TypstContext, ::Any)`
"""
struct TypstContext <: AbstractDict{Symbol, Any}
    context::Dict{Symbol, Any}

    TypstContext(; kwargs...) = new(Dict(kwargs))
end

TypstContext(_) = TypstContext()

copy(tc::TypstContext) = merge!(TypstContext(), tc)

eltype(tc::TypstContext) = eltype(tc.context)

getkey(tc::TypstContext, key, default) = getkey(tc.context, key, default)

get(tc::TypstContext, key, default) = get(tc.context, key, default)
get(f::Union{Function, Type}, tc::TypstContext, key) = get(f, tc.context, key)

iterate(tc::TypstContext, state) = iterate(tc.context, state)
iterate(tc::TypstContext) = iterate(tc.context)

length(tc::TypstContext) = length(tc.context)

mergewith(combine, tc::TypstContext, ds::AbstractDict...) = mergewith!(combine, copy(tc), ds)

merge!(tc::TypstContext, ds::AbstractDict...) = (merge!(tc.context, ds...); tc)

merge(tc::TypstContext, ds::AbstractDict...) = merge!(copy(tc), ds...)

setindex!(tc::TypstContext, value, key) = (tc.context[key] = value; tc)

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

sizehint!(tc::TypstContext, n) = sizehint!(tc.context, n)

"""
    default_context
"""
const default_context = TypstContext()

"""
    context

A `const`ant [`TypstContext`](@ref) used to provide
default formatting data when calling [`show_typst`](@ref).

See also [`reset_context`](@ref).

!!! tip
    Set mappings in this dictionary to customize the default formatting
    in environments that display values using `show` with the
    `application/pdf`, `image/png`, and `image/svg+xml` `MIME` types.

| Setting        | Type                  | Description                                                                                                                                                                       |
|:---------------|:----------------------|:----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `backticks`    | `Int`                 | The number of backticks to enclose raw text markup, which may be increased to disambiguiate nested raw text.                                                                      |
| `block`        | `Bool`                | When `mode = math`, specifies whether the enclosing dollar signs are padded with a space to render the element inline or its own block.                                           |
| `depth`        | `Int`                 | The current level of nesting within container types to specify the degree of indentation by repeating the `tab_size`.                                                             |
| `mode`         | [`Mode`](@ref)        | The current Typst syntactical context where `code` follows the number sign, `markup` is at the top-level and enclosed in square brackets, and `math` is enclosed in dollar signs. |
| `parenthesize` | `Bool`                | Whether to enclose some mathematical elements in parentheses to specify their operator precedence and avoid ambiguity.                                                            |
| `preamble`     | [`TypstString`](@ref) | Used at the beginning of Typst source files generated by [`render`](@ref) and some `show` methods.                                                                                |
| `tab_size`     | `Int`                 | The number of spaces used by some elements with multi-line Typst formatting, which is repeated for each level of `depth`                                                          |

# Examples

```jldoctest
julia> context
TypstContext with 7 entries:
  :mode         => markup
  :parenthesize => true
  :block        => false
  :preamble     => TypstString(TypstText("#set page(margin: 1em, height: auto, …
  :tab_size     => 2
  :backticks    => 3
  :depth        => 0
```
"""
const context = TypstContext()

"""
    reset_context()

Remove any custom mappings from the [`context`](@ref)
such that it is returned to its default state.

# Examples

```jldoctest
julia> reset_context()
TypstContext with 7 entries:
  :mode         => markup
  :parenthesize => true
  :block        => false
  :preamble     => TypstString(TypstText("#set page(margin: 1em, height: auto, …
  :tab_size     => 2
  :backticks    => 3
  :depth        => 0
```
"""
function reset_context()
    _context = context.context
    merge!(empty!(_context), default_context)
    context
end
