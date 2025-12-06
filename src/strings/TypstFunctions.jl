
module TypstFunctions

import Base: ==, show
import Typstry: show_typst

using Base: Pairs
using Typstry: Mode, TypstContext, TypstString, TypstText, code, depth, enclose, join_with, mode, show_render, tab_size

export TypstFunction

"""
    TypstFunction{P <: Tuple}(
        typst_context::TypstContext,
        callable::Symbol,
        parameters::P...;
        keyword_parameters...
    )

A wrapper representing a Typst function.

This uses the `depth::Int`, `mode::Mode`, and `tab_size::Int` keys from the [`TypstContext`](@ref).

See also [`Mode`](@ref).

# Interface

- `repr(::MIME"text/typst\u00A0::TypstFunction; context = nothing)`
- `show_typst(::IO,\u00A0::TypstContext,\u00A0::TypstFunction)`
- `show(::IO,\u00A0::MIME"text/typst",\u00A0::TypstFunction)`
    - Accepts `IOContext(::IO,\u00A0::TypstContext)`
- `show(::IO,\u00A0::Union{MIME"application/pdf",\u00A0MIME"image/png",\u00A0MIME"image/svg+xml"},\u00A0::TypstFunction)`
    - Accepts `IOContext(::IO,\u00A0::TypstContext)`
    - Uses the `preamble` in [`context`](@ref Typstry.context)
    - Supports the [`julia_mono`](@ref Typstry.Commands.julia_mono) typeface

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
struct TypstFunction{P <: Tuple}
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

repr(mime::MIME"text/typst", typst_function::TypstFunction; context = nothing) = TypstString(
    TypstText(sprint(show, mime, typst_function; context))
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

==(typst_function_1::TypstFunction, typst_function_2::TypstFunction) = (
    typst_function_1.depth == typst_function_2.depth &&
    typst_function_1.mode == typst_function_2.mode &&
    typst_function_1.tab_size == typst_function_2.tab_size &&
    typst_function_1.callable == typst_function_2.callable &&
    typst_function_1.parameters == typst_function_2.parameters &&
    typst_function_1.keyword_parameters == typst_function_2.keyword_parameters
)

show(io::IO, ::MIME"text/typst", typst_function::TypstFunction) = show_typst(io, typst_function)
show(io::IO, mime::Union{
    MIME"application/pdf", MIME"image/png", MIME"image/svg+xml"
}, typst_function::TypstFunction) = show_render(io, mime, typst_function)
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
