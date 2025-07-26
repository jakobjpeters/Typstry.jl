
module TypstCommandErrors

import Base: showerror, show

using ..Commands: TypstCommand

export TypstCommandError

"""
    TypstCommandError <: Exception
    TypstCommandError(::TypstCommand)

An `Exception` indicating a Typst comand-line
interface error from running a [`TypstCommand`](@ref).

# Interface

Implements the `Exception` interface.

- `showerror(::IO,\u00A0::TypstCommandError)`
- `show(::IO,\u00A0::MIME"text/plain",\u00A0::TypstCommandError)`

# Examples
```jldoctest
julia> TypstCommandError(typst``)
TypstCommandError(typst``)
```
"""
struct TypstCommandError <: Exception
    command::TypstCommand
end

showerror(io::IO, te::TypstCommandError) = print(
    io, "TypstCommandError: failed to `run` a `", TypstCommand, '(', te.command.parameters, ")`"
)

function show(io::IO, m::MIME"text/plain", te::TypstCommandError)
    print(io, TypstCommandError, '(')
    show(io, m, te.command)
    print(io, ')')
end

end # TypstCommandErrors
