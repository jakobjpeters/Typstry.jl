
# Internals

"""
    typst_compiler

A constant `Cmd` that is the Typst compiler given
by Typst_jll.jl with no additional parameters.
"""
const typst_compiler = typst()

"""
    apply(f, tc, args...; kwargs...)
"""
function apply(f, tc, args...; kwargs...)
    _tc = deepcopy(tc)
    _tc.compiler = f(_tc.compiler, args...; kwargs...)
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
    compiler::Cmd
    parameters::Vector{String}
    ignore_status::Bool

    TypstCommand(parameters::Vector{String}) = new(typst_compiler, parameters, false)
    TypstCommand(tc::TypstCommand; ignorestatus = tc.ignore_status, kwargs...) =
        new(Cmd(tc.compiler; kwargs...), tc.parameters, ignorestatus)
end

"""
    TypstError <: Exception
    TypstError(::TypstCommand)

An `Exception` indicating an failure to `run` a [`TypstCommand`](@ref).

```jldoctest
julia> TypstError(typst``)
TypstError(typst``)
```
"""
struct TypstError <: Exception
    command::TypstCommand
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

An constant artifact containing the
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
detach(tc::TypstCommand) = TypstCommand(tc; detach = true)

"""
    ignorestatus(::TypstCommand)

See also [`TypstCommand`](@ref).

# Examples
```jldoctest
julia> ignorestatus(typst`help`)
typst`help`
```
"""
ignorestatus(tc::TypstCommand) = TypstCommand(tc; ignorestatus = true)

"""
    run(::TypstCommand, args...; kwargs...)

See also [`TypstCommand`](@ref).

!!! info
    Errors from the Typst compiler are printed to `stderr`.
    If [`ignorestatus`](@ref) has been applied,
    this will not throw an exception in Julia.
    Otherwise, the Typst error will be printed before the Julia error.
"""
function run(tc::TypstCommand, args...; kwargs...)
    process = run(ignorestatus(Cmd(`$(tc.compiler) $(tc.parameters)`)), args...; kwargs...)
    success(process) || tc.ignore_status || throw(TypstError(tc))
    process
end

@static if isdefined(Base, :setcpuaffinity)
    setcpuaffinity(tc::TypstCommand, cpus) = TypstCommand(tc; cpus)

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
show(io::IO, tc::TypstCommand) =
    enclose((io, parameters) -> join_with(print, io, parameters, " "), io, tc.parameters, "typst`", "`")

"""
    showerror(::IO, ::TypstError)

Print a [`TypstError`](@ref) when failing to `run` a [`TypstCommand`](@ref).

# Examples
```jldoctest
julia> showerror(stdout, TypstError(typst``))
TypstError: failed to `run(TypstCommand([""]))`
```
"""
showerror(io::IO, te::TypstError) = print(io,
    "TypstError: failed to `", run, "(", TypstCommand, "(", te.command.parameters, "))`")
