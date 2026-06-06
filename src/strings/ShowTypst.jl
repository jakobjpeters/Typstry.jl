
module ShowTypst

export show_typst

module Interface

# function show_typst(io::IO, typst_context::TypstContext, typst_function::TypstFunction)
#     typst_function.mode == code || print(io, "#")
#     show_typst(io, typst_function.callable)
#     enclose(io, typst_function, '(', ')') do io, typst_function
#         parameters = typst_function.parameters
#         keyword_parameters = typst_function.keyword_parameters
#         no_parameters, no_keyword_parameters = isempty(parameters), isempty(keyword_parameters)

#         if !(no_parameters && no_keyword_parameters)
#             (; tab_size, depth) = typst_function
#             indent = ' ' ^ tab_size
#             next_depth = depth + 1
#             spacing = indent ^ next_depth

#             join_with(io, parameters, ',') do io, parameter
#                 print(io, '\n', spacing)
#                 show_typst(io, parameter; depth = next_depth, mode = code)
#             end

#             no_parameters || no_keyword_parameters || print(io, ',')

#             join_with(io, keyword_parameters, ',') do io, (key, value)
#                 print(io, '\n', spacing)
#                 print(io, key)
#                 print(io, ": ")
#                 show_typst(io, value; depth = next_depth, mode = code)
#             end

#             print(io, '\n', indent ^ depth)
#         end
#     end
# end
# 
# show_typst(_typst_context::TypstContext, value) = show_typst(
#     typst_context(_typst_context, value)...
# )
# show_typst(io::IO, value; _typst_context...) = show_typst(
#     typst_context(io, TypstContext(; _typst_context...), value)...
# )
# show_typst(value; _typst_context...) = show_typst(
#     typst_context(TypstContext(; _typst_context...), value)...
# )

@doc """
    show_typst(::IO, ::TypstContext, ::Any)::Nothing
    show_typst(::IO, ::Any; context...)::Nothing
    show_typst(::TypstContext, ::Any)::Nothing
    show_typst(::Any; context...)::Nothing

Print in Typst format with Julia settings and Typst
parameters provided by the [`TypstContext`](@ref).

Implement the three-parameter form of this function
for a custom type to specify its Typst formatting.
A setting is a value used in Julia, whose type varies across settings.
A parameter is passed directly to a Typst function and must be a [`TypstString`](@ref)
with the same name as in Typst, except that dashes are replaced with underscores.
Some settings, such as `block`, correspond with a parameter but may also be used in Julia.

See also the [Typst Formatting Examples](@ref).

!!! tip
    Please create an issue or pull-request to implement new methods.
""" show_typst


import ..Strings: show_typst

using Base: MathConstants.catalan # TODO
using ..Strings: Utilities, Mode, TypstFunction, TypstString, TypstText, code, markup, math
using Typstry: TypstContext, Utilities.enclose, Contexts.ContextErrors.unwrap
using .Utilities: code_mode, math_mode, math_pad, show_parameters, show_raw

show_typst(io::IO, typst_context::TypstContext, x::AbstractArray) = show_parameters(
    io, typst_context, TypstString(TypstText("math.vec")), x, [:delim, :align, :gap]
)
show_typst(io::IO, typst_context::TypstContext, x::AbstractMatrix) = show_parameters(
    io, typst_context, TypstString(TypstText("math.mat")), Tuple.(eachrow(x)), [
        :delim, :align, :augment, :gap, :row_gap, :column_gap
    ]
)
# function show_typst(io::IO, tc::TypstContext, x::AbstractString)
#     unwrap(tc, Mode, :mode) == markup && print(io, '#')
#     # TODO: handle Typst string escaping (`"\\u{}"`)
#     enclose((io, x) -> escape_string(io, x, '"'), io, x, '"')
# end
function show_typst(io::IO, tc::TypstContext, x::Complex{<:Union{
    AbstractFloat, AbstractIrrational, Rational{<:Signed}, Signed
}})
    _mode = unwrap(tc, Mode, :mode)
    math_mode(io, tc, x) do io, tc, x
        enclose(io, x, (_mode == math && unwrap(tc, Bool, :parenthesize) ? ("(", ")") : ("", ""))...) do io, x
            imaginary = imag(x)

            show_typst(io, real(x))
            print(io, ' ', signbit(imaginary) ? '-' : '+', ' ')
            show_typst(io, imaginary)
            print(io, 'i')
        end
    end
end
function show_typst(io::IO, typst_context::TypstContext, x::NamedTuple)
    if isempty(x)
        code_mode(io, typst_context)
        print(io, "(:)")
    else show_typst(io, TypstFunction(typst_context, TypstString(TypstText("")); x...))
    end
end
function show_typst(io::IO, tc::TypstContext, x::Rational{<:Signed})
    _mode = unwrap(tc, Mode, :mode)
    math_mode(io, tc, x) do io, tc, x
        enclose(io, x, (_mode == math && unwrap(tc, Bool, :parenthesize) ? ("(", ")") : ("", ""))...) do io, x
            show_typst(io, numerator(x); mode = math)
            print(io, " / ")
            show_typst(io, denominator(x); mode = math)
        end
    end
end
function show_typst(io::IO, tc::TypstContext, x::Tuple)
    if length(x) == 1
        code_mode(io, tc)
        enclose(show_typst, io, only(x), '(', ",)"; mode = code)
    else show_typst(io, TypstFunction(tc, TypstString(TypstText("")), x...))
    end
end
function show_typst(io::IO, tc::TypstContext, x::Union{
    OrdinalRange{<:Signed, <:Signed},
    StepRangeLen{<:Signed, <:Signed, <:Signed, <:Signed}
})
    inputs = (tc, TypstString(TypstText(:range)), first(x), last(x) + one(last(x)))
    _step = step(x)

    if _step == 1 show_typst(io, TypstFunction(inputs...))
    else show_typst(io, TypstFunction(inputs...; step = _step))
    end
end

end # Interface

end # ShowTypst
