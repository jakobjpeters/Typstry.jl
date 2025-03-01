
"""
    TypstContext <: AbstractDict{Symbol, Any}
    TypstContext(x)
    TypstContext(; kwargs...)

Provide formatting data for
[`show(::IO,\u00A0::MIME"text/typst",\u00A0::Typst)`](@ref).

Implement this function for a custom type to specify its custom settings and parameters.
Passing a value wrapped in [`Typst`](@ref) will `merge!` its custom context with defaults,
such that the defaults may be overwritten.
To be compatible with merging contexts and constructing an `IOContext`,
methods must return an `AbstractDict{Symbol}`.

# Interfaces

This type implements the dictionary, iteration, interfaces.
However, it is immutable such that it does not support inserting, deleting, or setting a key-value pair.
"""
struct TypstContext <: AbstractDict{Symbol, Any}
    context::Dict{Symbol, Any}

    TypstContext(; kwargs...) = new(Dict(kwargs))
end

"""
    TypstContext(::Typst)

See also [`Typst`](@ref), [`TypstString`](@ref), and [`TypstText`](@ref).
"""
TypstContext(x::Typst) = TypstContext(x.value)
TypstContext(x) = TypstContext()

Base.iterate(tc::TypstContext, state) = iterate(tc.context, state)
Base.iterate(tc::TypstContext) = iterate(tc.context)
Base.length(tc::TypstContext) = length(tc.context)
Base.eltype(tc::TypstContext) = eltype(tc.context)
Base.get(f::Union{Function, Type}, tc::TypstContext, key::Symbol) = get(f, tc.context, key)
Base.get(tc::TypstContext, key::Symbol, default) = get(tc.context, key, default)
function Base.show(io::IO, tc::TypstContext)
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

merge_contexts!(tc, context) = mergewith!((x, _) -> x, tc.context, context)

"""
    context

A constant [`TypstContext`](@ref) used in
[`show(::IO,\u00A0::MIME"text/typst",\u00A0::Union{})`](@ref).

May be configured using [`set_context`](@ref).

| Setting         | Default  | Type           | Description                                                                                                                                                                       |
|:----------------|:---------|:---------------|:----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `:backticks`    | `3`      | `Int`          | The number of backticks to enclose raw text markup, which may be increased to disambiguiate nested raw text.                                                                      |
| `:block`        | `false`  | `Bool`         | When `:mode => math`, specifies whether the enclosing dollar signs are padded with a space to render the element inline or its own block.                                         |
| `:depth`        | `0`      | `Int`          | The current level of nesting within container types to specify the degree of indentation.                                                                                         |
| `:mode`         | `markup` | [`Mode`](@ref) | The current Typst syntactical context where `code` follows the number sign, `markup` is at the top-level and enclosed in square brackets, and `math` is enclosed in dollar signs. |
| `:parenthesize` | `true`   | `Bool`         | Whether to enclose some mathematical elements in parentheses to specify their operator precedence and avoid ambiguity.                                                            |
| `:tab_size`     | `2`      | `Int`          | The number of spaces used by some elements with multi-line Typst formatting, which is repeated for each level of `depth`                                                          |

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

"""
    set_context(::TypstContext)
    set_context()

Use Preferences.jl such that after restarting Julia,
the [`context`](@ref) is initialized to the given [`TypstContext`](@ref).

If the `TypstContext` is not provided, reset the `context` to its default value.
"""
set_context(tc::TypstContext) = set_preference("context", tc)
set_context() = set_preference("context")

for (key, value) in pairs(default_context)
    @eval begin
        $key(context) = unwrap(context, $(QuoteNode(key)), $value)
        @doc "$($key)" $key
    end
end
