
include("typst_command.jl")
include("typst_command_error.jl")

"""
    julia_mono

A constant `String` file path to the
[JuliaMono](https://github.com/cormullion/juliamono) typeface.

This typeface is available when using one of the following approaches:

- `TypstCommand(["compile", "input.typ", "output.pdf", "--font-path=" * julia_mono])`
- `addenv(::TypstCommand,\u00A0"TYPST_FONT_PATHS"\u00A0=>\u00A0julia_mono)`
- `setenv(::TypstCommand,\u00A0"TYPST_FONT_PATHS"\u00A0=>\u00A0julia_mono)`
- `ENV["TYPST_FONT_PATHS"] = julia_mono`

and when compiling documents with the following methods:

- [`render`](@ref)
- [`typst`](@ref)
- `show` with the `application/pdf`, `image/png`, and `image/svg+xml`
    `MIME` types and a `TypstString`, `TypstText`, and `Typst` value

See also [`TypstCommand`](@ref).
"""
const julia_mono = artifact"JuliaMono"

render!(tc) = merge_contexts!(tc, context)

"""
    render(::TypstContext = TypstContext(; context...), value;
        input::AbstractString = "input.typ",
        output::AbstractString = "output.pdf",
        open::Bool = true,
        ignorestatus::Bool = true,
    context...)

Render the `value` to a document.

This first generates the `input` file containing
the `preamble` and formatted `value`.
Then it is compiled to the `output` document,
whose format is inferred by its file extension to be `pdf`, `png`, or `svg`.
The document may be automatically `open`ed by the default viewer.
The `ignorestatus` flag may be set.
This supports using the [`julia_mono`](@ref) typeface.

See also [`TypstContext`](@ref).

# Examples

```jldoctest
julia> render(Any[true 1; 1.2 1 // 2])
```
"""
function render(tc::TypstContext, value;
    input::AbstractString = "input.typ",
    output::AbstractString = "output.pdf",
    open::Bool = true,
    ignorestatus::Bool = true
)
    Base.open(input; truncate = true) do file
        print(file, preamble(render!(tc)))
        _show_typst(file, tc, value)
        println(file)
    end
    run(TypstCommand(TypstCommand([
        "compile", input, output, "--font-path=$julia_mono", "--open"
    ][begin:(end - !open)]); ignorestatus))
    nothing
end
render(value;
    input::AbstractString = "input.typ",
    output::AbstractString = "output.pdf",
    open::Bool = true,
    ignorestatus::Bool = true,
context...) = render(TypstContext(; context...), value; input, output, open, ignorestatus)

"""
    typst(::AbstractString; catch_interrupt::Bool = true, ignorestatus::Bool = true)

Convenience function intended for interactive use, emulating the typst
command line interface. Be aware, however, that it strictly splits
on spaces and does not provide any shell-style escape mechanism,
so it will not work if there are, e.g., filenames with spaces.

When `catch_interrupt` is true, CTRL-C quietly quits the command.
When `ignorestatus` is true, a Typst failure will not imply a julia error.

If the `"TYPST_FONT_PATHS"` environment variable is not set,
it is temporarily set to [`julia_mono`](@ref).
"""
function typst(parameters::AbstractString; catch_interrupt::Bool = true, ignorestatus::Bool = true)
    tc = addenv(
        TypstCommand(TypstCommand(split(parameters)); ignorestatus),
        "TYPST_FONT_PATHS" => get(ENV, "TYPST_FONT_PATHS", julia_mono)
    )

    if catch_interrupt
        try run(tc)
        catch e e isa InterruptException || rethrow()
        end
    else run(tc)
    end

    nothing
end

function show(io::IO, m::Union{
    MIME"application/pdf", MIME"image/png", MIME"image/svg+xml"
}, t::Union{Typst, TypstString, TypstText})
    input = tempname()
    output = input * '.' * format(m)

    render(t; input, output, open = false, ignorestatus = false, context = typst_context(io))
    write(io, read(output))

    nothing
end
