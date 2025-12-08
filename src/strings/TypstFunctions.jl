
module TypstFunctions

import Base: ==, show
import ..Strings: show_typst

using Base: Pairs
using ..Strings: AbstractTypst, Mode, TypstString, code, depth, mode, tab_size
using Typstry: TypstContext
using Typstry.Utilities: enclose, join_with

export TypstFunction

"""
    TypstFunction{P <: Tuple}(
        typst_context::TypstContext,
        callable::Symbol,
        parameters::P...;
        keyword_parameters...
    ) <: AbstractTypst

A wrapper representing a Typst function.

This uses the `depth::Int`, `mode::Mode`, and `tab_size::Int` keys from the [`TypstContext`](@ref).

Subtype of [`AbstractTypst`](@ref).

See also [`Mode`](@ref).

# Interface

- `==(::TypstFunction,\u00A0::TypstFunction)`
- `show_typst(::IO,\u00A0::TypstContext,\u00A0::TypstFunction)`
- `show(::IO,\u00A0::TypstFunction)`

# Examples

```jldoctest
julia> show_typst(TypstFunction(context, typst"arguments", 1, 2; a = 3, b = 4))
#arguments(
  1,
  2,
  a: 3,
  b: 4
)
```
"""
struct TypstFunction{P <: Tuple} <: AbstractTypst
    depth::Int
    mode::Mode
    tab_size::Int
    callable::TypstString
    parameters::P
    keyword_parameters::Pairs

    TypstFunction(
        typst_context::TypstContext, callable::TypstString, parameters...; keyword_parameters...
    ) = new{typeof(parameters)}(
        depth(typst_context),
        mode(typst_context),
        tab_size(typst_context),
        callable,
        parameters,
        keyword_parameters
    )
end

==(typst_function_1::TypstFunction, typst_function_2::TypstFunction) = (
    typst_function_1.depth == typst_function_2.depth &&
    typst_function_1.mode == typst_function_2.mode &&
    typst_function_1.tab_size == typst_function_2.tab_size &&
    typst_function_1.callable == typst_function_2.callable &&
    typst_function_1.parameters == typst_function_2.parameters &&
    typst_function_1.keyword_parameters == typst_function_2.keyword_parameters
)

function show_typst(io::IO, typst_context::TypstContext, typst_function::TypstFunction)
    typst_function.mode == code || print(io, "#")
    show_typst(io, typst_function.callable)
    enclose(io, typst_function, '(', ')') do io, typst_function
        parameters = typst_function.parameters
        keyword_parameters = typst_function.keyword_parameters
        no_parameters, no_keyword_parameters = isempty(parameters), isempty(keyword_parameters)

        if !(no_parameters && no_keyword_parameters)
            (; tab_size, depth) = typst_function
            indent = ' ' ^ tab_size
            next_depth = depth + 1
            spacing = indent ^ next_depth

            join_with(io, parameters, ',') do io, parameter
                print(io, '\n', spacing)
                show_typst(io, parameter; depth = next_depth, mode = code)
            end

            no_parameters || no_keyword_parameters || print(io, ',')

            join_with(io, keyword_parameters, ',') do io, (key, value)
                print(io, '\n', spacing)
                print(io, key)
                print(io, ": ")
                show_typst(io, value; depth = next_depth, mode = code)
            end

            print(io, '\n', indent ^ depth)
        end
    end
end

function show(io::IO, typst_function::TypstFunction)
    (; depth, mode, tab_size, callable, parameters, keyword_parameters) = typst_function

    print(
        io,
        TypstFunction,
        '(',
        TypstContext,
        "(; depth = ",
        depth,
        ", mode = ",
        mode,
        ", tab_size = ",
        tab_size,
        "), "
    )
    show(io, typst_function.callable)

    if !isempty(parameters)
        print(io, ", ")
        join_with(io, parameters, ", ") do io, parameter
            show(io, parameter)
        end
    end

    if !isempty(keyword_parameters)
        print(io, "; ")
        join_with(io, typst_function.keyword_parameters, ", ") do io, (key, value)
            print(io, key, " = ")
            show(io, value)
        end
    end

    print(io, ')')
end

end # TypstFunctions
