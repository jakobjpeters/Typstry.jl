
include("typst_command.jl")
include("typst_command_error.jl")

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
        print(file, preamble(tc))
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

    render(t; input, output, open = false, ignorestatus = false, context = typst_context(io))
    write(io, read(output))

    nothing
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
