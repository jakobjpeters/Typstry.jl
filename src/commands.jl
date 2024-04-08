
"""
    TypstCommand
    TypstCommand(::Vector{String})
    TypstCommand(::TypstCommand; kwargs...)
"""
struct TypstCommand
    typst::Cmd
    parameters::Cmd

    TypstCommand(parameters::Vector{String}) = new(typst(), Cmd(parameters))
    TypstCommand(tc::TypstCommand; kwargs...) = new(Cmd(tc.typst; kwargs...), tc.parameters)
end

"""
    @typst_cmd(parameters)
    typst`parameters...`

Return a [`TypstCommand`](@ref).

# Examples
```jldoctest
julia> typst`help`
typst`help`

julia> typst`compile input.typ output.typ`
typst`compile input.typ output.typ`
```
"""
macro typst_cmd(parameters)
    :(TypstCommand(map(string, eachsplit($(esc(parse("\"$parameters\"")))))))
end

"""
    render(elements...;
        delimeter = "", input = "input.typ", output = "output.pdf", open = true
    )

Render the `elements`, each separated by the `delimeter`, to a document.

This function generates two files.
The first is the `input`, which contains the Typst code.
The second is the `output`, which is rendered from the `input` using Typst's compile command.

The document format is inferred by the file extension of `output`.
The available formats are `pdf`, `png`, and `svg`.

If `open` = true`, the `output` will be opened using the default viewer.

# Examples
```jldoctest
julia> render(typst"\$x ^ 2\$");

julia> render([1 2; 3 4]);
```
"""
function render(elements...; delimeter = "", input = "input.typ", output = "output.pdf", open = true)
    Base.open(input; truncate = true) do file
        join(file, Iterators.map(_typstify, elements), delimeter)
        println(file)
    end
    run(TypstCommand(["compile", input, output, "--open"][begin:end - !open]))
end

# Interface

"""
    show(::IO, ::TypstCommand)
"""
show(io::IO, tc::TypstCommand) = print(io, "typst", tc.parameters)

"""
    run(::TypstCommand, args...; kwargs...)
"""
run(tc::TypstCommand, args...; kwargs...) =
    run(Cmd(`$(tc.typst) $(tc.parameters)`), args...; kwargs...)

"""
    addenv(::TypstCommand, args...; kwargs...)
"""
addenv(tc::TypstCommand, args...; kwargs...) =
    TypstCommand(addenv(tc.typst, args...; kwargs...), tc.parameters)

"""
    setenv(::TypstCommand, env; kwargs...)
"""
setenv(tc::TypstCommand, env; kwargs...) =
    TypstCommand(setenv(tc.typst, env; kwargs...), tc.parameters)

"""
    ignorestatus(::TypstCommand)
"""
ignorestatus(tc::TypstCommand) =
    TypstCommand(ignorestatus(tc.typst), tc.parameters)

"""
    detach(::TypstCommand)
"""
detach(tc::TypstCommand) =
    TypstCommand(detach(tc.typst), tc.parameters)

"""
    setcpuaffinity(::TypstCommand, cpus)
"""
setcpuaffinity(tc::TypstCommand, cpus) =
    TypstCommand(setcpuaffinity(tc.typst, cpus), tc.parameters)
