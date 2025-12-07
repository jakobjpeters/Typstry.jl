
module TypstCommandErrors

import Base: showerror

using ..Commands: TypstCommand

export TypstCommandError

"""
    TypstCommandError <: Exception

An `Exception` indicating a Typst command-line
interface error from running a [`TypstCommand`](@ref Typstry.TypstCommand).

# Interface

- `showerror(::IO,\u00A0::TypstCommandError)`
"""
struct TypstCommandError <: Exception
    parameters::Vector{String}

    TypstCommandError(typst_command::TypstCommand) = new(typst_command.parameters)
end

showerror(io::IO, typst_command_error::TypstCommandError) = print(
    io,
    TypstCommandError,
    ": failed to run a `",
    TypstCommand,
    '(',
    typst_command_error.parameters,
    ")`"
)

end # TypstCommandErrors
