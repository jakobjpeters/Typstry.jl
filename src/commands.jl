
# Internals

"""
    typst_program

A constant `Cmd` that is the Typst compiler given
by Typst_jll.jl with no additional parameters.
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

The Typst compiler.

!!! info
    This type implements the `Cmd` interface.
    However, the interface is unspecified which may result unexpected behavior.

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
    @typst_cmd(s)
    typst`s`

Construct a [`TypstCommand`](@ref) where each parameter is separated by a space.

This does not support interpolation; use the `TypstCommand` constructor instead.

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

"""
    julia_mono

An artifact containing the
[JuliaMono](https://github.com/cormullion/juliamono) typeface.

Use with a [`TypstCommand`](@ref) and one of [`addenv`](@ref),
[`setenv`](@ref), or the `font-path` command-line option.
"""
const julia_mono = artifact"JuliaMono"

# `Base`

"""
    addenv(::TypstCommand, args...; kwargs...)

See also [`TypstCommand`](@ref) and [`julia_mono`](@ref).

# Examples
```jldoctest
julia> addenv(typst`compile input.typ output.pdf`, "TYPST_FONT_PATHS" => julia_mono)
typst`compile input.typ output.pdf`
```
"""
addenv(tc::TypstCommand, args...; kwargs...) = apply(addenv, tc, args...; kwargs...)

"""
    detach(::TypstCommand)

See also [`TypstCommand`](@ref).

# Examples
```jldoctest
julia> detach(typst`help`)
typst`help`
```
"""
detach(tc::TypstCommand) = apply(detach, tc)

"""
    ignorestatus(::TypstCommand)

See also [`TypstCommand`](@ref).

# Examples
```jldoctest
julia> ignorestatus(typst`help`)
typst`help`
```
"""
ignorestatus(tc::TypstCommand) = apply(ignorestatus, tc)

"""
    run(::TypstCommand, args...; kwargs...)

See also [`TypstCommand`](@ref).
"""
run(tc::TypstCommand, args...; kwargs...) =
    run(Cmd(`$(tc.typst) $(tc.parameters)`), args...; kwargs...)

@static if isdefined(Base, :setcpuaffinity)
    setcpuaffinity(tc::TypstCommand, cpus) = apply(setcpuaffinity, tc, cpus)

    @doc """
        setcpuaffinity(::TypstCommand, cpus)

    See also [`TypstCommand`](@ref).

    !!! compat
        Requires at least Julia v0.8.

    # Examples
    ```jldoctest
    julia> setcpuaffinity(typst`help`, nothing)
    typst`help`
    ```
    """ setcpuaffinity
end

"""
    setenv(::TypstCommand, env; kwargs...)

See also [`TypstCommand`](@ref) and [`julia_mono`](@ref).

# Examples
```jldoctest
julia> setenv(typst`compile input.typ output.pdf`, "TYPST_FONT_PATHS" => julia_mono)
typst`compile input.typ output.pdf`
```
"""
setenv(tc::TypstCommand, env; kwargs...) = apply(setenv, tc, env; kwargs...)

"""
    show(::IO, ::TypstCommand)

See also [`TypstCommand`](@ref).

# Examples
```jldoctest
julia> show(stdout, typst`help`)
typst`help`
```
"""
show(io::IO, tc::TypstCommand) = print(io, "typst", tc.parameters)
