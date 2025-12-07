
module TypstCommandErrors

import Base: showerror

using ..Commands: TypstCommand

export TypstCommandError

"""
    TypstCommandError <: Exception

An `Exception` indicating a Typst command-line
interface error from running a [`TypstCommand`](@ref).

# Interface

- `showerror(::IO,\u00A0::TypstCommandError)`
"""
struct TypstCommandError <: Exception
    typst_command::TypstCommand
end

showerror(io::IO, typst_command_error::TypstCommandError) = print(
    io,
    "TypstCommandError: failed to run a `",
    TypstCommand,
    '(',
    typst_command_error.typst_command.parameters,
    ")`"
)

end # TypstCommandErrors
