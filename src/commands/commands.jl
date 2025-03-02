
"""
    typst_command_error(tc)
"""
typst_command_error(tc) = TypstCommandError(tc)

include("typst_command.jl")
include("typst_command_error.jl")

# Internals

"""
    format(::Union{MIME"application/pdf", MIME"image/png", MIME"image/svg+xml"})

Return the image format acronym corresponding to the given `MIME`.

# Examples

```jldoctest
julia> Typstry.format(MIME"application/pdf"())
"pdf"

julia> Typstry.format(MIME"image/png"())
"png"

julia> Typstry.format(MIME"image/svg+xml"())
"svg"
```
"""
format(::MIME"application/pdf") = "pdf"
format(::MIME"image/png") = "png"
format(::MIME"image/svg+xml") = "svg"

# `Typstry`

"""
    @typst_cmd("s")
    typst`s`

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

"""
    julia_mono

A constant `String` file path to the
[JuliaMono](https://github.com/cormullion/juliamono) typeface.

Use with a [`TypstCommand`](@ref) and one of [`addenv`](@ref),
[`setenv`](@ref), or the `font-path` Typst command-line option.
"""
const julia_mono = artifact"JuliaMono"

render!(tc) = merge_contexts!(tc, context)

"""
    render(value;
        input = "input.typ",
        output = "output.pdf",
        open = true,
        ignorestatus = true,
        context = TypstContext()
    )

Render to a document using
[`show(::IO,\u00A0::MIME"text/typst",\u00A0::Typst)`](@ref).

This first generates the `input` file containing
the [`preamble`](@ref) and formatted `value`.
Then it is compiled to the `output` document,
whose format is inferred by its file extension to be `pdf`, `png`, or `svg`.
The document may be automatically `open`ed by the default viewer.
The [`ignorestatus`](@ref) flag may be set.
This supports using the [`julia_mono`](@ref) typeface.

# Examples

```jldoctest
julia> render(Any[true 1; 1.2 1 // 2]);
```
"""
function render(value;
    input = "input.typ",
    output = "output.pdf",
    open = true,
    ignorestatus = true,
    context = TypstContext()
)
    Base.open(input; truncate = true) do file
        tc = render!(context)
        print(file, unwrap(tc, TypstString, :preamble))
        _show_typst(file, tc, value)
        println(file)
    end
    run(TypstCommand(TypstCommand(
        ["compile", input, output, "--font-path=$julia_mono", "--open"][begin:(end - !open)]);
    ignorestatus))
end

"""
    typst(::AbstractString; catch_interrupt = true, ignorestatus = true)

Convenience function intended for interactive use, emulating the typst
command line interface. Be aware, however, that it strictly splits
on spaces and does not provide any shell-style escape mechanism,
so it will not work if there are, e.g., filenames with spaces.

When `catch_interrupt` is true, CTRL-C quietly quits the command.
When [`ignorestatus`](@ref) is true, a Typst failure will not imply a julia error.

If the `"TYPST_FONT_PATHS"` environment variable is not set,
it is temporarily set to [`julia_mono`](@ref).
"""
function typst(parameters::AbstractString; catch_interrupt = true, ignorestatus = true)
    tc = addenv(TypstCommand(TypstCommand(split(parameters)); ignorestatus),
        "TYPST_FONT_PATHS" => get(ENV, "TYPST_FONT_PATHS", julia_mono))
    if catch_interrupt
        try run(tc)
        catch e e isa InterruptException || rethrow()
        end
    else run(tc)
    end
    nothing
end

<<<<<<< HEAD
# `Base`

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
[`TypstError`](@ref) if the Typst compiler throws an error.

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
    read(::TypstCommand, ::Type{String})
    read(::TypstCommand)

See also [`TypstCommand`](@ref).
"""
read(tc::TypstCommand, ::Type{String}) = String(read(tc))
function read(tc::TypstCommand)
    command = `$(tc.compiler) $(tc.parameters)`
    read(tc.ignore_status ? ignorestatus(command) : command)
end

"""
    run(::TypstCommand, args...; kwargs...)

See also [`TypstCommand`](@ref).

!!! info
    Errors thrown by the Typst compiler will be printed to `stderr`.
    Then, a Julia [`TypstError`](@ref) will be thrown unless the [`ignorestatus`](@ref) flag is set.
"""
function run(tc::TypstCommand, args...; kwargs...)
    process = run(ignorestatus(`$(tc.compiler) $(tc.parameters)`), args...; kwargs...)
    tc.ignore_status || success(process) || throw(TypstError(tc))
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

=======
>>>>>>> 15577c9 (Create `typst_commands.jl` and `typst_errors.jl`)
"""
    show(::IO, ::Union{
        MIME"application/pdf", MIME"image/png", MIME"image/svg+xml"
    }, ::Union{Typst, TypstString, TypstText})

Print the Portable Document Format (PDF), Portable Network Graphics (PNG),
or Scalable Vector Graphics (SVG) format.

The `preamble` keyword parameter used by [`render`](@ref) may be specified in an `IOContext`.
Environments, such as Pluto.jl notebooks, may use these methods to `display` values of type
[`Typst`](@ref), [`TypstString`](@ref), and [`TypstText`](@ref).
This supports using the [`julia_mono`](@ref) typeface.

# Examples

```jldoctest
julia> show(IOContext(devnull, :preamble => typst""), "image/svg+xml", Typst(1))
```
"""
function show(io::IO, m::Union{
    MIME"application/pdf", MIME"image/png", MIME"image/svg+xml"
}, t::Union{Typst, TypstString, TypstText})
    input = tempname()
    output = input * "." * format(m)

    render(t; input, output, open = false, ignorestatus = false,
        context = unwrap(io, :typst_context, TypstContext()))
    write(io, read(output))

    nothing
end
