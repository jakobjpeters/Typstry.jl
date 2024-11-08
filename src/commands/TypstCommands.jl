
module TypstCommands

import Base:
    ==, addenv, detach, eltype, firstindex, getindex, hash, ignorestatus,
    iterate, keys, lastindex, length, run, setcpuaffinity, setenv, show
import Typst_jll
using ..Commands: Utilities, typst_command_error
using .Utilities: enclose, join_with

"""
    apply(f, tc, args...; kwargs...)
"""
function apply(f, tc, args...; kwargs...)
    _tc = deepcopy(tc)
    _tc.compiler = f(_tc.compiler, args...; kwargs...)
    _tc
end

"""
    TypstCommand(::AbstractVector{<:AbstractString})
    TypstCommand(::TypstCommand; kwargs...)

The Typst compiler and its parameters.

Keyword parameters have the same semantics as for a `Cmd`.

# Interface

This type implements the `Cmd` interface.
However, the interface is undocumented, which may result in unexpected behavior.

- `addenv(::TypstCommand, env...; ::Bool = true)`
    - Can be used with [`julia_mono`](@ref)
    - `addenv(::TypstCommand, "TYPST_FONT_PATHS" => julia_mono)`
- `detach(::TypstCommand)`
- `eltype(::Type{TypstCommand})`
- `firstindex(::TypstCommand)`
- `getindex(::TypstCommand, i)`
- `hash(::TypstCommand, ::UInt)`
- `ignorestatus(::TypstCommand)`
    - Do not throw a [`TypstCommandError`](@ref) if the Typst compiler throws an error.
        Errors thrown by the Typst compiler are printed to `stderr` regardless.
- `iterate(::TypstCommand, i)`
- `iterate(::TypstCommand)`
- `keys(::TypstCommand)`
- `lastindex(::TypstCommand)`
- `length(::TypstCommand)`
- `run(::TypstCommand, args...; ::Bool = true)`
    - Errors thrown by the Typst compiler will be printed to `stderr`.
        Then, a Julia [`TypstCommandError`](@ref) will be
        thrown unless the [`ignorestatus`](@ref) flag is set.
- `setcpuaffinity(::TypstCommand, cpus)`
- `setenv(::TypstString, env...; kwargs...)`
    - Can be used with [`julia_mono`](@ref)
    - `setenv(::TypstCommand, "TYPST_FONT_PATHS" => julia_mono)`
- `show(::IO, ::MIME"text/plain", ::TypstCommand)`

# Examples

```jldoctest
julia> help = TypstCommand(["help"])
typst`help`

julia> TypstCommand(help; ignorestatus = true)
typst`help`
```
"""
mutable struct TypstCommand
    const parameters::Vector{String}
    const ignore_status::Bool
    compiler::Cmd

    TypstCommand(parameters) = new(parameters, false, Typst_jll.typst())
    TypstCommand(tc::TypstCommand; ignorestatus = tc.ignore_status, kwargs...) =
        new(tc.parameters, ignorestatus, Cmd(tc.compiler; kwargs...))
end

tc::TypstCommand == _tc::TypstCommand =
    tc.compiler == _tc.compiler &&
    tc.parameters == _tc.parameters &&
    tc.ignore_status == _tc.ignore_status

addenv(tc::TypstCommand, env...; inherit::Bool = true) = apply(addenv, tc, env...; inherit)

detach(tc::TypstCommand) = TypstCommand(tc; detach = true)

eltype(::Type{TypstCommand}) = String

firstindex(::TypstCommand) = 1

getindex(tc::TypstCommand, i) = i == 1 ? only(tc.compiler) : tc.parameters[i - 1]

hash(tc::TypstCommand, h::UInt) =
    hash((TypstCommand, tc.compiler, tc.parameters, tc.ignore_status), h)

ignorestatus(tc::TypstCommand) = TypstCommand(tc; ignorestatus = true)

iterate(tc::TypstCommand, i) =
    if i == 1 (only(tc.compiler), 2)
    else
        parameters, _i = tc.parameters, i - 1
        length(parameters) < _i ?  nothing : (parameters[_i], i + 1)
    end
iterate(tc::TypstCommand) = iterate(tc, 1)

keys(tc::TypstCommand) = LinearIndices(firstindex(tc) : lastindex(tc))

lastindex(tc::TypstCommand) = length(tc)

length(tc::TypstCommand) = length(tc.parameters) + 1

function run(tc::TypstCommand, args...; wait::Bool = true)
    process = run(ignorestatus(Cmd(`$(tc.compiler) $(tc.parameters)`)), args...; wait)
    tc.ignore_status || success(process) || throw(typst_command_error(tc))
    process
end

setcpuaffinity(tc::TypstCommand, cpus) = TypstCommand(tc; cpus)

setenv(tc::TypstCommand, env...; kwargs...) = apply(setenv, tc, env...; kwargs...)

function show(io::IO, ::MIME"text/plain", tc::TypstCommand)
    parameters = tc.parameters

    all(parameter -> all(isprint, parameter), parameters) ?
        enclose((io, parameters) -> join_with(
            (io, parameter) -> printstyled(io, parameter; underline = true),
        io, parameters, " "), io, tc.parameters, "typst`", "`") :
        print(TypstCommand, "(", parameters, ")")
end

end # TypstCommands
