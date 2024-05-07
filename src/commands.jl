
"""
    typst_executable
"""
const typst_executable = typst()

"""
    TypstCommand
    TypstCommand(::Vector{String})
    TypstCommand(::TypstCommand; kwargs...)

The Typst command-line interface.

This command attempts to support the same interface as `Cmd`.
However, this interface is unspecified which may result in missing functionality.

# Examples
```jldoctest
julia> help = TypstCommand(["help"])
typst`help`

julia> TypstCommand(help; ignorestatus = true)
typst`help`
```
"""
struct TypstCommand
    typst::Cmd
    parameters::Cmd

    TypstCommand(parameters::Vector{String}) = new(typst_executable, Cmd(parameters))
    TypstCommand(tc::TypstCommand; kwargs...) = new(Cmd(tc.typst; kwargs...), tc.parameters)
end

"""
    @typst_cmd(parameters)
    typst`parameters...`

Construct a [`TypstCommand`](@ref) without interpolation.

Each parameter must be separated by a space `" "`.

# Examples
```jldoctest
julia> typst`help`
typst`help`

julia> typst`compile input.typ output.typ`
typst`compile input.typ output.typ`
```
"""
macro typst_cmd(parameters)
    :(TypstCommand(map(string, eachsplit($parameters, " "))))
end

# Interface

"""
    addenv(::TypstCommand, args...; kwargs...)
"""
addenv(tc::TypstCommand, args...; kwargs...) =
    TypstCommand(addenv(tc.typst, args...; kwargs...), tc.parameters)

"""
    detach(::TypstCommand)
"""
detach(tc::TypstCommand) =
    TypstCommand(detach(tc.typst), tc.parameters)

"""
    ignorestatus(::TypstCommand)
"""
ignorestatus(tc::TypstCommand) =
    TypstCommand(ignorestatus(tc.typst), tc.parameters)

"""
    run(::TypstCommand, args...; kwargs...)
"""
run(tc::TypstCommand, args...; kwargs...) =
    run(Cmd(`$(tc.typst) $(tc.parameters)`), args...; kwargs...)

"""
    setcpuaffinity(::TypstCommand, cpus)
"""
setcpuaffinity(tc::TypstCommand, cpus) =
    TypstCommand(setcpuaffinity(tc.typst, cpus), tc.parameters)

"""
    setenv(::TypstCommand, env; kwargs...)
"""
setenv(tc::TypstCommand, env; kwargs...) =
    TypstCommand(setenv(tc.typst, env; kwargs...), tc.parameters)

"""
    show(::IO, ::TypstCommand)
"""
show(io::IO, tc::TypstCommand) = print(io, "typst", tc.parameters)
