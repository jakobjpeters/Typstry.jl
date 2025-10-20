
module TypstFunctions

import Base: show
import ..Typstry: TypstContext, TypstString, math, math_mode, join_with, show_typst, typst_context
using Base: isoperator

export TypstFunction

"""
    TypstFunction{C, P <: Tuple}

A wrapper representing a Typst function.

The default implementation formats the values in [`math`](@ref) mode,
but [`show_typst`](@ref) may be implemented for custom
types to format them in [`code`](@ref) mode too.

# Fields

- `callable::C`
- `parameters::P`

# Interface

- `show_typst(::IO,\u00A0::TypstContext,\u00A0::TypstFunction{String})`
    - Format in call notation `callable(parameters...)`.
- `show_typst(::IO,\u00A0::TypstContext,\u00A0::TypstFunction{Symbol})`
    - If the predicates `Base.isoperator(callable)` and `0 < length(parameters) < 3`
        are satisfied, format in infix notation `parameter_1 callable parameter_2`.
        Otherwise, fallback to call notation `callable(parameters...)`.
- `show_typst(::IO,\u00A0::TypstContext,\u00A0::TypstFunction{<:Union{DataType,\u00A0Function}})`
    - Fallback to `show_typst(::IO,\u00A0::TypstContext,\u00A0::TypstFunction{Symbol})`
- `show_typst(::IO,\u00A0::TypstContext,\u00A0::TypstFunction)`
    - Fallback to `show_typst(::IO,\u00A0::TypstContext,\u00A0::TypstFunction{TypstString})`

See also [`TypstString`](@ref).
"""
struct TypstFunction{C, P <: Tuple}
    callable::C
    parameters::P
end

show_typst(
    io::IO, typst_context::TypstContext, typst_function::TypstFunction{TypstString}
) = math_mode(io, typst_context, typst_function) do io, typst_context, typst_function
    show_typst(io, typst_function.callable)
    print(io, '(')
    join_with(show_typst, io, typst_function.parameters, ", "; mode = math)
    print(io, ')')
end
function show_typst(io::IO, typst_context::TypstContext, typst_function::TypstFunction{Symbol})
    (; callable, parameters) = typst_function

    if isoperator(callable) && 0 < (arity = length(parameters)) < 3
        math_mode(io, typst_context, typst_function) do io, typst_context, typst_function
            if arity == 1
                print(io, callable)
                show_typst(io, only(parameters); mode = math)
            elseif arity == 2
                show_typst(io, parameters[1]; mode = math)
                print(io, ' ', callable, ' ')
                show_typst(io, parameters[2]; mode = math)
            else error("unreachable reached")
            end
        end
    else show_typst(io, TypstFunction(string(callable), parameters))
    end
end
show_typst(
    io::IO, ::TypstContext, typst_function::TypstFunction{<:Union{DataType, Function}}
) = show_typst(io, TypstFunction(nameof(typst_function.callable), typst_function.parameters))
show_typst(io::IO, ::TypstContext, typst_function::TypstFunction) = show_typst(
    io, TypstFunction(TypstString(
        setindex!(copy(typst_context(io)), math, :mode), typst_function.callable
    ), typst_function.parameters)
)

show(io::IO, ::MIME"text/typst", typst_function::TypstFunction) = show_typst(io, typst_function)
show(io::IO, mime::Union{
    MIME"application/pdf", MIME"image/png", MIME"image/svg+xml"
}, typst_function::TypstFunction) = show_render(io, mime, typst_function)

end # TypstFunctions
