
module Commands

import Base: read, run
import Typstry

using Artifacts: @artifact_str

include("TypstCommands.jl")

using .TypstCommands: TypstCommand, @typst_cmd

include("TypstCommandErrors.jl")

using .TypstCommandErrors: TypstCommandError

export TypstCommandError, TypstCommand, @typst_cmd, julia_mono, typst

"""
    julia_mono

A constant `String` file path to the
[JuliaMono](https://github.com/cormullion/juliamono) typeface.

This typeface is available when using one of the following approaches:

- `TypstCommand(["compile", "input.typ", "output.pdf", "--font-path=\$julia_mono"])`
- `addenv(::TypstCommand,\u00A0"TYPST_FONT_PATHS"\u00A0=>\u00A0julia_mono)`
- `setenv(::TypstCommand,\u00A0"TYPST_FONT_PATHS"\u00A0=>\u00A0julia_mono)`
- `ENV["TYPST_FONT_PATHS"] = julia_mono`

and when compiling documents with the following methods:

- [`render`](@ref Typstry.render)
- [`typst`](@ref)
- `show` with the `application/pdf`, `image/png`, `image/svg+xml`, and `image/webp`
    `MIME` types and a `TypstFunction`, `TypstString`, `TypstText`, and `Typst` value

See also [`TypstCommand`](@ref).
"""
const julia_mono = artifact"JuliaMono"

"""
    typst(::AbstractString; catch_interrupt::Bool = true, ignorestatus::Bool = true)

Convenience function intended for interactive use, emulating the typst
command line interface.

If the `"TYPST_FONT_PATHS"` environment variable is not set,
it is temporarily set to [`julia_mono`](@ref).

!!! warning
    It strictly splits on spaces and does not provide any shell-style escape mechanism,
    so it will not work if there are, e.g., filenames with spaces.

# Parameters

- `catch_interrupt::Bool = true`
    - `[CTRL]+[C]` quietly quits the command.
- `ignorestatus::Bool = true`
    - Whether to throw a [`TypstCommandError`](@ref) if the command errors.
"""
function typst(parameters::AbstractString; catch_interrupt::Bool = true, ignorestatus::Bool = true)
    tc = addenv(
        TypstCommand(TypstCommand(split(parameters)); ignorestatus),
        "TYPST_FONT_PATHS" => get(ENV, "TYPST_FONT_PATHS", julia_mono)
    )

    if catch_interrupt
        try run(tc)
        catch e e isa InterruptException || rethrow()
        end
    else run(tc)
    end

    nothing
end

read(typst_command::TypstCommand, ::Type{String}) = String(read(typst_command))
function read(typst_command::TypstCommand)
    io_buffer = IOBuffer()
    run_typst(command -> pipeline(command; stdout = io_buffer), typst_command)
    take!(io_buffer)
end

run(typst_command::TypstCommand, args...; wait::Bool = true) = run_typst(typst_command) do command
    run(command, args...; wait)
end

function run_typst(callback, typst_command::TypstCommand)
    process = callback(ignorestatus(Cmd(typst_command)))
    typst_command.ignore_status || success(process) || throw(TypstCommandError(typst_command))
    process
end

end # Commands
