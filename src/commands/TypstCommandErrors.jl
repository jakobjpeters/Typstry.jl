
module TypstCommandErrors

import Base: showerror, show
using ..Commands: TypstCommands.TypstCommand

"""
    TypstCommandError <: Exception
    TypstCommandError(::TypstCommand)

An `Exception` indicating a failure to [`run`](@ref) a [`TypstCommand`](@ref).

# Interface

Implements the `Exception` interface.

- `showerror(::IO, ::TypstCommandError)`
- `show(::IO, ::MIME"text/plain", ::TypstCommandError)`

# Examples
```jldoctest
julia> TypstCommandError(typst``)
TypstCommandError(typst``)
```
"""
struct TypstCommandError <: Exception
    command::TypstCommand
end

showerror(io::IO, te::TypstCommandError) = print(io,
    "TypstCommandError: failed to `run` a `", TypstCommand, "(", te.command.parameters, ")`")

function show(io::IO, m::MIME"text/plain", te::TypstCommandError)
    print(io, TypstCommandError, "(")
    show(io, m, te.command)
    print(io, ")")
end

end # TypstCommandErrors
