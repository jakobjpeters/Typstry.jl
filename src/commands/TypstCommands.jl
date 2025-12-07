
module TypstCommands

import Base:
    ==, Cmd, addenv, detach, eltype, firstindex, getindex, hash, ignorestatus,
    iterate, keys, lastindex, length, setcpuaffinity, setenv, show
import Typst_jll, Typstry

using Typstry: enclose, join_with

export TypstCommand, @typst_cmd

"""
    TypstCommand(::AbstractVector{<:AbstractString})
    TypstCommand(::TypstCommand; parameters...)

The Typst compiler and its parameters.

Keyword parameters have the same semantics as for a `Cmd`.

# Interface

This type implements the `Cmd` interface.
However, the interface is undocumented, which may result in unexpected behavior.

- `==(::TypstCommand,\u00A0::TypstCommand)`
- `Cmd(::TypstCommand;\u00A0parameters...)`
- `addenv(::TypstCommand,\u00A0env...;\u00A0inherit::Bool\u00A0=\u00A0true)`
    - Can be used with [`julia_mono`](@ref Typstry.julia_mono).
- `detach(::TypstCommand)`
- `eltype(::Type{TypstCommand})`
- `firstindex(::TypstCommand)`
- `getindex(::TypstCommand,\u00A0i)`
- `hash(::TypstCommand,\u00A0::UInt)`
- `ignorestatus(::TypstCommand)`
    - Do not throw a [`TypstCommandError`](@ref Typstry.TypstCommandError) if the Typst compiler throws an error.
        Errors thrown by the Typst compiler are printed to `stderr` regardless.
- `iterate(::TypstCommand,\u00A0i)`
- `iterate(::TypstCommand)`
- `keys(::TypstCommand)`
- `lastindex(::TypstCommand)`
- `length(::TypstCommand)`
- `read(::TypstCommand, ::Type{String})`
    - Errors thrown by the Typst compiler will be printed to `stderr`.
        Then, a Julia [`TypstCommandError`](@ref Typstry.TypstCommandError) will be
        thrown unless the `ignorestatus` flag is set.
- `read(::TypstCommand)`
    - Errors thrown by the Typst compiler will be printed to `stderr`.
        Then, a Julia [`TypstCommandError`](@ref Typstry.TypstCommandError) will be
        thrown unless the `ignorestatus` flag is set.
- `run(::TypstCommand,\u00A0args...;\u00A0wait::Bool\u00A0=\u00A0true)`
    - Errors thrown by the Typst compiler will be printed to `stderr`.
        Then, a Julia [`TypstCommandError`](@ref Typstry.TypstCommandError) will be
        thrown unless the `ignorestatus` flag is set.
- `setcpuaffinity(::TypstCommand,\u00A0cpus)`
- `setenv(::TypstString,\u00A0env...;\u00A0kwargs...)`
    - Can be used with [`julia_mono`](@ref Typstry.julia_mono).
- `show(::IO,\u00A0::MIME"text/plain",\u00A0::TypstCommand)`
- `show(::IO,\u00A0::TypstCommand)`

# Examples

```jldoctest
julia> help = TypstCommand(["help"])
typst`help`

julia> TypstCommand(help; ignorestatus = true)
typst`help`
```
"""
struct TypstCommand
    compiler::Cmd
    parameters::Vector{String}
    ignore_status::Bool

    TypstCommand(parameters) = new(Typst_jll.typst(), parameters, false)
    TypstCommand(
        typst_command::TypstCommand; ignorestatus = typst_command.ignore_status, parameters...
    ) = new(Cmd(typst_command.compiler; parameters...), typst_command.parameters, ignorestatus)

    Base.addenv(typst_command::TypstCommand, environment...; inherit::Bool = true) = new(
        addenv(typst_command.compiler, environment...; inherit),
        typst_command.parameters,
        typst_command.ignore_status
    )

    Base.setenv(typst_command::TypstCommand, environment...; parameters...) = new(
        setenv(typst_command.compiler, environment...; parameters...),
        typst_command.parameters,
        typst_command.ignore_status
    )
end

"""
    @typst_cmd("")
    typst``

Construct a [`TypstCommand`](@ref) where each parameter is separated by a space.

This does not yet support interpolation; use the constructor instead.

# Examples

```jldoctest
julia> typst`help`
typst`help`

julia> typst`compile input.typ output.typ`
typst`compile input.typ output.typ`
```
"""
macro typst_cmd(input::String)
    :(TypstCommand($(string.(eachsplit(input)))))
end

typst_command::TypstCommand == _typst_command::TypstCommand = (
    typst_command.compiler == _typst_command.compiler &&
    typst_command.parameters == _typst_command.parameters &&
    typst_command.ignore_status == _typst_command.ignore_status
)

Cmd(typst_command::TypstCommand; parameters...) = Cmd(
    `$(typst_command.compiler) $(typst_command.parameters)`;
    ignorestatus = typst_command.ignore_status,
    parameters...
)

detach(typst_command::TypstCommand) = TypstCommand(typst_command; detach = true)

eltype(::Type{TypstCommand}) = String

firstindex(::TypstCommand) = 1

function getindex(typst_command::TypstCommand, i)
    i == 1 ? only(typst_command.compiler) : typst_command.parameters[i - 1]
end

hash(typst_command::TypstCommand, code::UInt) = hash((
    TypstCommand, typst_command.compiler, typst_command.parameters, typst_command.ignore_status
), code)

ignorestatus(typst_command::TypstCommand) = TypstCommand(typst_command; ignorestatus = true)

function iterate(typst_command::TypstCommand, i)
    if i == 1 (only(typst_command.compiler), 2)
    else
        parameters, _i = typst_command.parameters, i - 1
        length(parameters) < _i ?  nothing : (parameters[_i], i + 1)
    end
end
iterate(typst_command::TypstCommand) = iterate(typst_command, firstindex(typst_command))

keys(typst_command::TypstCommand) = LinearIndices(
    firstindex(typst_command):lastindex(typst_command)
)

lastindex(typst_command::TypstCommand) = length(typst_command)

length(typst_command::TypstCommand) = length(typst_command.parameters) + 1

setcpuaffinity(typst_command::TypstCommand, cpus) = TypstCommand(typst_command; cpus)

function show(io::IO, ::MIME"text/plain", typst_command::TypstCommand)
    parameters = typst_command.parameters

    if all(parameter -> all(isprint, parameter), parameters)
        enclose(io, parameters, "typst`", '`') do _io, _parameters
            join_with(_io, _parameters, ' ') do __io, parameter
                printstyled(__io, parameter; underline = true)
            end
        end
    else show(io, typst_command)
    end
end
show(io::IO, typst_command::TypstCommand) = print(
    io, TypstCommand, '(', typst_command.parameters, ')'
)

end # TypstCommands
