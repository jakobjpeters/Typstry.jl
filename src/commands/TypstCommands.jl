
module TypstCommands

import Base:
    ==, addenv, detach, eltype, firstindex, getindex, hash, ignorestatus,
    iterate, keys, lastindex, length, read, run, setcpuaffinity, setenv, show
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

!!! info
    This type implements the `Cmd` interface.
    However, the interface is undocumented, which may result in unexpected behavior.

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

"""
    ==(::TypstCommand, ::TypstCommand)

See also [`TypstCommand`](@ref).

# Examples

```jldoctest
julia> TypstCommand(["help"]) == @typst_cmd("help") == typst`help`
true

julia> typst`help` == ignorestatus(typst`help`)
false
```
"""
tc::TypstCommand == _tc::TypstCommand =
    tc.compiler == _tc.compiler &&
    tc.parameters == _tc.parameters &&
    tc.ignore_status == _tc.ignore_status

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
    eltype(::Type{TypstCommand})

See also [`TypstCommand`](@ref).

# Examples

```jldoctest
julia> eltype(TypstCommand)
String
```
"""
eltype(::Type{TypstCommand}) = String

"""
    firstindex(::TypstCommand)

See also [`TypstCommand`](@ref).

# Examples

```jldoctest
julia> firstindex(typst`help`)
1
```
"""
firstindex(::TypstCommand) = 1

"""
    getindex(::TypstCommand, i)

See also [`TypstCommand`](@ref).

# Examples

```jldoctest
julia> typst`help`[2]
"help"
```
"""
getindex(tc::TypstCommand, i) = i == 1 ? only(tc.compiler) : tc.parameters[i - 1]

"""
    hash(::TypstCommand, ::UInt)

See also [`TypstCommand`](@ref).
"""
hash(tc::TypstCommand, h::UInt) =
    hash((TypstCommand, tc.compiler, tc.parameters, tc.ignore_status), h)

"""
    ignorestatus(::TypstCommand)

Return a [`TypstCommand`](@ref) that does not throw a
[`TypstCommandError`](@ref) if the Typst compiler throws an error.

Errors thrown by the Typst compiler are printed to `stderr` regardless.

# Examples

```jldoctest
julia> ignorestatus(typst`help`)
typst`help`
```
"""
ignorestatus(tc::TypstCommand) = TypstCommand(tc; ignorestatus = true)

"""
    iterate(::TypstCommand)
    iterate(::TypstCommand, i)

See also [`TypstCommand`](@ref).

# Examples

```jldoctest
julia> iterate(typst`help`, 2)
("help", 3)

julia> iterate(typst`help`, 3)
```
"""
iterate(tc::TypstCommand) = iterate(tc, 1)
iterate(tc::TypstCommand, i) =
    if i == 1 (only(tc.compiler), 2)
    else
        parameters, _i = tc.parameters, i - 1
        length(parameters) < _i ?  nothing : (parameters[_i], i + 1)
    end

"""
    keys(::TypstCommand)

See also [`TypstCommand`](@ref).

# Examples

```jldoctest
julia> keys(typst`help`)
2-element LinearIndices{1, Tuple{Base.OneTo{Int64}}}:
 1
 2
```
"""
keys(tc::TypstCommand) = LinearIndices(firstindex(tc) : lastindex(tc))

"""
    lastindex(::TypstCommand)

See also [`TypstCommand`](@ref).

# Examples

```jldoctest
julia> lastindex(typst`help`)
2
```
"""
lastindex(tc::TypstCommand) = length(tc)

"""
    length(::TypstCommand)

See also [`TypstCommand`](@ref).

# Examples

```jldoctest
julia> length(typst`help`)
2
```
"""
length(tc::TypstCommand) = length(tc.parameters) + 1

"""
    run(::TypstCommand, args...; kwargs...)

See also [`TypstCommand`](@ref).

!!! info
    Errors thrown by the Typst compiler will be printed to `stderr`.
    Then, a Julia [`TypstCommandError`](@ref) will be
    thrown unless the [`ignorestatus`](@ref) flag is set.
"""
function run(tc::TypstCommand, args...; kwargs...)
    process = run(ignorestatus(Cmd(`$(tc.compiler) $(tc.parameters)`)), args...; kwargs...)
    tc.ignore_status || success(process) || throw(typst_command_error(tc))
    process
end

"""
    setcpuaffinity(::TypstCommand, cpus)

See also [`TypstCommand`](@ref).

# Examples

```jldoctest
julia> setcpuaffinity(typst`help`, nothing)
typst`help`
```
"""
setcpuaffinity(tc::TypstCommand, cpus) = TypstCommand(tc; cpus)

"""
    setenv(::TypstCommand, args...; kwargs...)

See also [`TypstCommand`](@ref) and [`julia_mono`](@ref).

# Examples

```jldoctest
julia> setenv(typst`compile input.typ output.pdf`, "TYPST_FONT_PATHS" => julia_mono)
typst`compile input.typ output.pdf`
```
"""
setenv(tc::TypstCommand, args...; kwargs...) = apply(setenv, tc, args...; kwargs...)

"""
    show(::IO, ::MIME"text/plain", ::TypstCommand)

See also [`TypstCommand`](@ref).

# Examples

```jldoctest
julia> show(stdout, "text/plain", typst`help`)
typst`help`
```
"""
function show(io::IO, ::MIME"text/plain", tc::TypstCommand)
    parameters = tc.parameters

    all(parameter -> all(isprint, parameter), parameters) ?
        enclose((io, parameters) -> join_with(
            (io, parameter) -> printstyled(io, parameter; underline = true),
        io, parameters, " "), io, tc.parameters, "typst`", "`") :
        print(TypstCommand, "(", parameters, ")")
end

end # TypstCommands
