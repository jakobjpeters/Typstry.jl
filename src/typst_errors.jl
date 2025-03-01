
"""
    TypstError <: Exception
    TypstError(::TypstCommand)

An `Exception` indicating a failure to [`run`](@ref) a [`TypstCommand`](@ref).

# Examples
```jldoctest
julia> TypstError(typst``)
TypstError(typst``)
```
"""
struct TypstError <: Exception
    command::TypstCommand
end

"""
    show(::IO, ::MIME"text/plain", ::TypstError)

# Examples

```jldoctest
julia> show(stdout, "text/plain", TypstError(typst``))
TypstError(typst``)
```
"""
function show(io::IO, m::MIME"text/plain", te::TypstError)
    print(io, TypstError, "(")
    show(io, m, te.command)
    print(io, ")")
end

"""
    showerror(::IO, ::TypstError)

Print a [`TypstError`](@ref) when failing to [`run`](@ref) a [`TypstCommand`](@ref).

# Examples

```jldoctest
julia> showerror(stdout, TypstError(typst``))
TypstError: failed to `run` a `TypstCommand(String[])`
```
"""
showerror(io::IO, te::TypstError) = print(io,
    "TypstError: failed to `run` a `", TypstCommand, "(", te.command.parameters, ")`")
