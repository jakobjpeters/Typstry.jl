
module TypstCommands

import Base:
    ==, addenv, detach, eltype, firstindex, getindex, hash, ignorestatus,
    iterate, keys, lastindex, length, read, setcpuaffinity, setenv, show
import Typst_jll

using ..Commands: Typstry
using Typstry: enclose, join_with

export TypstCommand, @typst_cmd

"""
    TypstCommand(::AbstractVector{<:AbstractString})
    TypstCommand(::TypstCommand; kwargs...)

The Typst compiler and its parameters.

Keyword parameters have the same semantics as for a `Cmd`.

# Interface

This type implements the `Cmd` interface.
However, the interface is undocumented, which may result in unexpected behavior.

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
- `read(::TypstCommand)`
- `run(::TypstCommand,\u00A0args...;\u00A0wait::Bool\u00A0=\u00A0true)`
    - Errors thrown by the Typst compiler will be printed to `stderr`.
        Then, a Julia [`TypstCommandError`](@ref Typstry.TypstCommandError) will be
        thrown unless the `ignorestatus` flag is set.
- `setcpuaffinity(::TypstCommand,\u00A0cpus)`
- `setenv(::TypstString,\u00A0env...;\u00A0kwargs...)`
    - Can be used with `julia_mono`.
- `show(::IO,\u00A0::MIME"text/plain",\u00A0::TypstCommand)`

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
    TypstCommand(tc::TypstCommand; ignorestatus = tc.ignore_status, kwargs...) = new(
        Cmd(tc.compiler; kwargs...), tc.parameters, ignorestatus
    )

    Base.addenv(tc::TypstCommand, environment...; inherit::Bool = true) = new(
        addenv(tc.compiler, environment...; inherit), tc.parameters, tc.ignore_status
    )

    Base.setenv(tc::TypstCommand, environment...; kwargs...) = new(
        setenv(tc.compiler, environment...; kwargs...), tc.parameters, tc.ignore_status
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
macro typst_cmd(s::String)
    parameters = isempty(s) ? String[] : map(string, eachsplit(s, ' '))
    :(TypstCommand($parameters))
end

tc::TypstCommand == _tc::TypstCommand = (
    tc.compiler == _tc.compiler &&
    tc.parameters == _tc.parameters &&
    tc.ignore_status == _tc.ignore_status
)

detach(tc::TypstCommand) = TypstCommand(tc; detach = true)

eltype(::Type{TypstCommand}) = String

firstindex(::TypstCommand) = 1

getindex(tc::TypstCommand, i) = i == 1 ? only(tc.compiler) : tc.parameters[i - 1]

hash(tc::TypstCommand, h::UInt) = hash((
    TypstCommand, tc.compiler, tc.parameters, tc.ignore_status
), h)

ignorestatus(tc::TypstCommand) = TypstCommand(tc; ignorestatus = true)

function iterate(tc::TypstCommand, i)
    if i == 1 (only(tc.compiler), 2)
    else
        parameters, _i = tc.parameters, i - 1
        length(parameters) < _i ?  nothing : (parameters[_i], i + 1)
    end
end
iterate(tc::TypstCommand) = iterate(tc, firstindex(tc))

keys(tc::TypstCommand) = LinearIndices(firstindex(tc) : lastindex(tc))

lastindex(tc::TypstCommand) = length(tc)

length(tc::TypstCommand) = length(tc.parameters) + 1

read(tc::TypstCommand, ::Type{String}) = String(read(tc))
function read(tc::TypstCommand)
    command = `$(tc.compiler) $(tc.parameters)`
    read(tc.ignore_status ? ignorestatus(command) : command)
end

setcpuaffinity(tc::TypstCommand, cpus) = TypstCommand(tc; cpus)

function show(io::IO, ::MIME"text/plain", tc::TypstCommand)
    parameters = tc.parameters

    if all(parameter -> all(isprint, parameter), parameters)
        enclose(io, parameters, "typst`", "`") do _io, _parameters
            join_with(_io, _parameters, ' ') do __io, parameter
                printstyled(__io, parameter; underline = true)
            end
        end
    else print(TypstCommand, '(', parameters, ')')
    end
end

end # TypstCommands
