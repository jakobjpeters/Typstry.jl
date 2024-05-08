
# Internals

"""
    typst_program

A constant `Cmd` that is the Typst command-line interface
given by Typst_jll.jl with no additional parameters.
"""
const typst_program = typst()

"""
    apply(f, tc, args...; kwargs...)
"""
function apply(f, tc, args...; kwargs...)
    _tc = deepcopy(tc)
    _tc.typst = f(tc.typst, args...; kwargs...)
    _tc
end

# `Typstry`

"""
    TypstCommand(::Vector{String})
    TypstCommand(::TypstCommand; kwargs...)

The Typst command-line interface.

This type implements the `Cmd` interface.
However, this interface is unspecified which may result in missing functionality.

# Examples
```jldoctest
julia> help = TypstCommand(["help"])
typst`help`

julia> TypstCommand(help; ignorestatus = true)
typst`help`
```
"""
mutable struct TypstCommand
    typst::Cmd
    parameters::Cmd

    TypstCommand(parameters::Vector{String}) = new(typst_program, Cmd(parameters))
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
    :(TypstCommand(map(string, split($parameters, " "))))
end

# `Base`

"""
    addenv(::TypstCommand, args...; kwargs...)
"""
addenv(tc::TypstCommand, args...; kwargs...) = apply(addenv, tc, args...; kwargs...)

"""
    detach(::TypstCommand)

# Examples
```jldoctest
julia> detach(typst`help`)
typst`help`
```
"""
detach(tc::TypstCommand) = apply(detach, tc)

"""
    ignorestatus(::TypstCommand)

# Examples
```jldoctest
julia> ignorestatus(typst`help`)
typst`help`
```
"""
ignorestatus(tc::TypstCommand) = apply(ignorestatus, tc)

"""
    run(::TypstCommand, args...; kwargs...)

# Examples
```jldoctest
julia> run(typst`help`);
The Typst compiler

Usage: typst [OPTIONS] <COMMAND>

Commands:
  compile  Compiles an input file into a supported output format [aliases: c]
  watch    Watches an input file and recompiles on changes [aliases: w]
  init     Initializes a new project from a template
  query    Processes an input file to extract provided metadata
  fonts    Lists all discovered fonts in system and custom font paths
  update   Self update the Typst CLI (disabled)
  help     Print this message or the help of the given subcommand(s)

Options:
      --color[=<WHEN>]  Set when to use color. auto = use color if a capable terminal is detected [default: auto] [possible values: auto, always, never]
      --cert <CERT>     Path to a custom CA certificate to use when making network requests [env: TYPST_CERT=]
  -h, --help            Print help
  -V, --version         Print version
```
"""
run(tc::TypstCommand, args...; kwargs...) =
    run(Cmd(`$(tc.typst) $(tc.parameters)`), args...; kwargs...)

"""
    setenv(::TypstCommand, env; kwargs...)
"""
setenv(tc::TypstCommand, env; kwargs...) = apply(setenv, tc, env; kwargs...)

"""
    show(::IO, ::TypstCommand)
"""
show(io::IO, tc::TypstCommand) = print(io, "typst", tc.parameters)

@static if isdefined(Base, :setcpuaffinity)
    setcpuaffinity(tc::TypstCommand, cpus) = apply(setcpuaffinity, tc, cpus)

    @doc """
        setcpuaffinity(::TypstCommand, cpus)

    !!! compat
        Requires Julia v0.8+.
    """ setcpuaffinity
end
