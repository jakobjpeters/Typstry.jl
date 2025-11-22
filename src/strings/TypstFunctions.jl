
module TypstFunctions

import Base: repr, show
import ..Typstry: TypstContext, TypstString, math_mode, join_with, show_typst, typst_context
import ..Typstry: show_typst

using Base: isoperator
using ..Typstry: TypstContext, TypstString, math, enclose, join_with, math_mode, parenthesize, typst_context, show_render

export TypstFunction

"""
    TypstFunction{C, P <: Tuple}

A wrapper representing a Typst function.

The default implementation formats the values in [`math`](@ref) mode,
but [`show_typst`](@ref) may be implemented for custom
types to format them in [`code`](@ref Typstry.code) mode too.

# Fields

- `callable::C`
- `parameters::P`

# Interface

- `repr(::MIME"text/typst",\u00A0, ::TypstFunction)`
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

repr(::MIME"text/typst", typst_function::TypstFunction; context = nothing) = TypstString(typst_function)

show_typst(
    io::IO, typst_context::TypstContext, typst_function::TypstFunction{TypstString}
) = math_mode(io, typst_context, typst_function) do io, typst_context, typst_function
    enclose(
        io, typst_function, (parenthesize(typst_context) ? ("(", ")") : ("", ""))...
    ) do io, typst_function
        show_typst(io, typst_function.callable)
        print(io, " (")
        join_with(show_typst, io, typst_function.parameters, ", "; mode = math)
        print(io, ')')
    end
end
show_typst(io::IO, typst_context::TypstContext, typst_function::TypstFunction{Symbol}) = math_mode(io, typst_context, typst_function
) do io, typst_context, typst_function
    (; callable, parameters) = typst_function

    if isoperator(callable)
        arity = length(parameters)

        if arity == 1
            print(io, callable)
            show_typst(io, only(parameters))
        elseif arity == 2
            enclose(
                io, parameters, (parenthesize(typst_context) ? ("(", ")") : ("", ""))...
            ) do io, parameters
                show_typst(io, parameters[1])
                print(io, ' ', callable, ' ')
                show_typst(io, parameters[2])
            end
        else show_typst(io, TypstFunction(string(callable), parameters))
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
