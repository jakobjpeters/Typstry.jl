
"""
    TypstCommandError <: Exception
    TypstCommandError(::TypstCommand)

An `Exception` indicating a failure to [`run`](@ref) a [`TypstCommand`](@ref).

# Examples
```jldoctest
julia> TypstCommandError(typst``)
TypstCommandError(typst``)
```
"""
struct TypstCommandError <: Exception
    command::TypstCommand
end

"""
    show(::IO, ::MIME"text/plain", ::TypstCommandError)

# Examples

```jldoctest
julia> show(stdout, "text/plain", TypstCommandError(typst``))
TypstCommandError(typst``)
```
"""
function show(io::IO, m::MIME"text/plain", te::TypstCommandError)
    print(io, TypstCommandError, "(")
    show(io, m, te.command)
    print(io, ")")
end

"""
    showerror(::IO, ::TypstCommandError)

Print a [`TypstCommandError`](@ref) when failing to [`run`](@ref) a [`TypstCommand`](@ref).

# Examples

```jldoctest
julia> showerror(stdout, TypstCommandError(typst``))
TypstCommandError: failed to `run` a `TypstCommand(String[])`
```
"""
showerror(io::IO, te::TypstCommandError) = print(io,
    "TypstCommandError: failed to `run` a `", TypstCommand, "(", te.command.parameters, ")`")
