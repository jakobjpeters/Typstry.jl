
module TypstCommandErrors

import Base: showerror, show

using ..Commands: TypstCommand

export TypstCommandError

"""
    TypstCommandError <: Exception

An `Exception` indicating a Typst command-line
interface error from running a [`TypstCommand`](@ref).
"""
struct TypstCommandError <: Exception
    typst_command::TypstCommand
end

showerror(io::IO, te::TypstCommandError) = print(
    io,
    "TypstCommandError: failed to run a `",
    TypstCommand,
    '(',
    te.typst_command.parameters,
    ")`"
)

function show(io::IO, m::MIME"text/plain", te::TypstCommandError)
    print(io, TypstCommandError, '(')
    show(io, m, te.typst_command)
    print(io, ')')
end

end # TypstCommandErrors
