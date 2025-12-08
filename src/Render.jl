
module Render

import Base: show

using Typstry:
    Strings, AbstractTypst, TypstCommand, TypstContext, TypstString,
    julia_mono, Commands.Interface.run_typst, show_typst
using .Strings: Utilities, preamble
using .Utilities: format, typst_context

export render

const default_input, default_output = "document." .* ["typ", "pdf"]
const default_open, default_ignorestatus = true, true

function render(_typst_context::TypstContext, value;
    input::AbstractString = default_input,
    output::AbstractString = default_output,
    open::Bool = default_open,
    ignorestatus::Bool = default_ignorestatus
)
    Base.open(input; truncate = true) do file
        io_context, _typst_context, _ = typst_context(file, _typst_context, value)
        print(io_context, preamble(_typst_context))
        show_typst(io_context, value)
        println(file)
    end
    run(TypstCommand(TypstCommand([
        "compile", input, output, "--font-path", julia_mono, "--open"
    ][begin:(end - !open)]); ignorestatus))
    nothing
end
render(value;
    input::AbstractString = default_input,
    output::AbstractString = default_output,
    open::Bool = default_open,
    ignorestatus::Bool = default_ignorestatus,
    typst_context...
) = render(TypstContext(; typst_context...), value; input, output, open, ignorestatus)

@doc """
    render(::TypstContext, value; parameters...)::Nothing
    render(value; parameters..., context...)::Nothing

Render the `value` to a document.

This supports using the [`julia_mono`](@ref) typeface.

See also [`TypstContext`](@ref).

!!! info
    Typst requires the `output` path to contain a page number template `{p}`
    when compiling documents with multiple pages to either PNG or SVG format.
    In this case, use `open = false` to prevent an error from the Typst command-line interface.
    See also [Typst #7182](https://github.com/typst/typst/issues/7182).

# Parameters

- `input::AbstractString = $(repr(default_input))`
    - Write the `preamble` and formatted value to this Typst source file.
- `output::AbstractString = $(repr(default_output))`
    - Compile the document in the format specified by the file extension `pdf`, `png`, or `svg`.
- `open::Bool = $(repr(default_open))`
    - Whether to preview the document with the default viewer, if available.
- `ignorestatus::Bool = $(repr(default_ignorestatus))`
    - Whether to throw a [`TypstCommandError`](@ref Typstry.Commands.TypstCommandErrors.TypstCommandError) if the command errors.

# Examples

```jldoctest
julia> render(Any[true 1; 1.2 1 // 2]);
```
""" render

function show(io::IO, mime::Union{
    MIME"application/pdf", MIME"image/png", MIME"image/svg+xml"
}, value::Union{AbstractTypst, TypstString})
    io_buffer = IOBuffer()
    typst_command = TypstCommand([
        "compile", "--font-path", julia_mono, "--format", format(mime), "-", "-"
    ])
    _typst_context = typst_context(io, value)[2]

    print(io_buffer, preamble(_typst_context))
    show_typst(io_buffer, _typst_context, value)
    println(io_buffer)

    seekstart(io_buffer)
    run_typst(command -> pipeline(command; stdin = io_buffer, stdout = io), typst_command)
    nothing
end

end # Render
