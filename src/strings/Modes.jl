
module Modes

using Typstry: Contexts.TypstContexts.default_context

export Mode, code, markup, math

"""
    Mode

An `Enum`erated type used to specify that the current Typst syntactical
context is [`code`](@ref), [`markup`](@ref), or [`math`](@ref).

# Examples

```jldoctest
julia> Mode
Enum Mode:
code = 0
markup = 1
math = 2
```
"""
@enum Mode code markup math

@doc """
    code

A Typst syntactical [`Mode`](@ref) prefixed by the number sign `#`.

# Examples

```jldoctest
julia> code
code::Mode = 0
```
""" code

@doc """
    markup

A Typst syntactical [`Mode`](@ref) at the top-level of
source text and enclosed within square brackets `[]`.

```jldoctest
julia> markup
markup::Mode = 1
```
""" markup

@doc """
    math

A Typst syntactical [`Mode`](@ref) enclosed within dollar signs `\$\$`.

```jldoctest
julia> math
math::Mode = 2
```
""" math

__init__() = (default_context[:mode] = markup)

end # Modes
