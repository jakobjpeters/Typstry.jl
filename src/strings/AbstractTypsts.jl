
module AbstractTypsts

import Base: ==, repr, show
import ..Strings: show_typst

using Base: Pairs
using ..Strings: Mode, TypstString, code
using Typstry: Typstry, Utilities, TypstContext
using .Utilities: enclose, join_with, unwrap

export AbstractTypst, TypstFunction, TypstText, Typst

"""
    AbstractTypst

Supertype of [`TypstFunction`](@ref), [`TypstText`](@ref), and [`Typst`](@ref).

# Interface

- `repr(::MIME"text/typst",\u00A0::AbstractTypst)`
- `show(::IO,\u00A0::Union{MIME"application/pdf",\u00A0MIME"image/png",\u00A0MIME"image/svg+xml"},\u00A0::AbstractTypst)`
    - Accepts `IOContext(::IO,\u00A0::TypstContext)`
    - Uses the `preamble` in [`context`](@ref Typstry.Contexts.TypstContexts.context)
    - Supports the [`julia_mono`](@ref Typstry.Commands.JuliaMono.julia_mono) typeface
- `show(::IO,\u00A0::MIME"text/typst",\u00A0::AbstractTypst)`
    - Accepts `IOContext(::IO,\u00A0::TypstContext)`
"""
abstract type AbstractTypst end

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
        unwrap(typst_context, Int, :depth),
        unwrap(typst_context, Mode, :mode),
        unwrap(typst_context, Int, :tab_size),
        callable,
        parameters,
        keyword_parameters
    )
end

"""
    TypstText{T}(::T) <: AbstractTypst
    TypstText(::T)

A wrapper whose [`show_typst`](@ref) method uses `print` on the wrapped value.

Subtype of [`AbstractTypst`](@ref).

# Interface

- `==(::TypstText{T},\u00A0::TypstText{T})\u00A0where\u00A0T`
- `show_typst(::IO,\u00A0::TypstContext,\u00A0::TypstText)`

# Examples

```jldoctest
julia> show_typst(TypstText('a'))
a
```
"""
struct TypstText{T} <: AbstractTypst
    value::T
end

"""
    Typst{T}(::T) <: AbstractTypst
    Typst(::T)

A wrapper used to pass values to `show`,
whose [`show_typst`](@ref) method formats the wrapped value.

Subtype of [`AbstractTypst`](@ref).

# Interface

- `==(::Typst{T},\u00A0::Typst{T})\u00A0where\u00A0T`
- `show_typst(::IO,\u00A0::TypstContext,\u00A0::Typst)`

# Examples

```jldoctest
julia> show_typst(Typst(1))
\$1\$
```
"""
struct Typst{T} <: AbstractTypst
    value::T
end

==(typst_function_1::TypstFunction, typst_function_2::TypstFunction) = (
    typst_function_1.depth == typst_function_2.depth &&
    typst_function_1.mode == typst_function_2.mode &&
    typst_function_1.tab_size == typst_function_2.tab_size &&
    typst_function_1.callable == typst_function_2.callable &&
    typst_function_1.parameters == typst_function_2.parameters &&
    typst_function_1.keyword_parameters == typst_function_2.keyword_parameters
)
function ==(typst_text_1::T, typst_text_2::T) where T <: Union{TypstText, Typst}
    typst_text_1.value == typst_text_2.value
end

repr(mime::MIME"text/typst", typst::AbstractTypst; context = nothing) = TypstString(
    TypstText(sprint(show, mime, typst; context))
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
show_typst(io::IO, ::TypstContext, typst_text::TypstText) = print(io, typst_text.value)
show_typst(io::IO, ::TypstContext, typst::Typst) = show_typst(io, typst.value)

show(io::IO, ::MIME"text/typst", typst::AbstractTypst) = show_typst(io, typst)
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

end # AbstractTypsts
