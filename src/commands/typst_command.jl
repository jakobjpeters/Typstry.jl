
"""
    TypstCommand(::AbstractVector{<:AbstractString})
    TypstCommand(::TypstCommand; kwargs...)

The Typst compiler and its parameters.

Keyword parameters have the same semantics as for a `Cmd`.

# Interface

This type implements the `Cmd` interface.
However, the interface is undocumented, which may result in unexpected behavior.

- `addenv(::TypstCommand,\u00A0env...;\u00A0::Bool\u00A0=\u00A0true)`
    - Can be used with [`julia_mono`](@ref)
- `detach(::TypstCommand)`
- `eltype(::Type{TypstCommand})`
- `firstindex(::TypstCommand)`
- `getindex(::TypstCommand,\u00A0i)`
- `hash(::TypstCommand,\u00A0::UInt)`
- `ignorestatus(::TypstCommand)`
    - Do not throw a [`TypstCommandError`](@ref) if the Typst compiler throws an error.
        Errors thrown by the Typst compiler are printed to `stderr` regardless.
- `iterate(::TypstCommand,\u00A0i)`
- `iterate(::TypstCommand)`
- `keys(::TypstCommand)`
- `lastindex(::TypstCommand)`
- `length(::TypstCommand)`
- `read(::TypstCommand, ::Type{String})`
- `read(::TypstCommand)`
- `run(::TypstCommand,\u00A0args...;\u00A0::Bool\u00A0=\u00A0true)`
    - Errors thrown by the Typst compiler will be printed to `stderr`.
        Then, a Julia [`TypstCommandError`](@ref) will be
        thrown unless the `ignorestatus` flag is set.
- `setcpuaffinity(::TypstCommand,\u00A0cpus)`
- `setenv(::TypstString,\u00A0env...;\u00A0kwargs...)`
    - Can be used with `julia_mono`
- `show(::IO,\u00A0::MIME"text/plain",\u00A0::TypstCommand)`

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
    @typst_cmd("")
    typst``

Construct a [`TypstCommand`](@ref) where each parameter is separated by a space.

This does not support interpolation; use the constructor instead.

# Examples

```jldoctest
julia> typst`help`
typst`help`

julia> typst`compile input.typ output.typ`
typst`compile input.typ output.typ`
```
"""
macro typst_cmd(parameters::String)
    :(TypstCommand($(isempty(parameters) ? String[] : map(string, split(parameters, " ")))))
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

read(tc::TypstCommand, ::Type{String}) = String(read(tc))
function read(tc::TypstCommand)
    command = `$(tc.compiler) $(tc.parameters)`
    read(tc.ignore_status ? ignorestatus(command) : command)
end

function run(tc::TypstCommand, args...; wait::Bool = true)
    process = run(ignorestatus(`$(tc.compiler) $(tc.parameters)`), args...; wait)
    tc.ignore_status || success(process) || throw(TypstCommandError(tc))
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
