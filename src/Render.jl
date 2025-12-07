
module Render

using Typstry: TypstCommand, TypstContext, julia_mono, preamble, show_typst, typst_context

export render

"""
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

- `input::AbstractString = "document.typ"`
    - Write the `preamble` and formatted value to this Typst source file.
- `output::AbstractString = "document.pdf"`
    - Compile the document in the format specified by the file extension `pdf`, `png`, or `svg`.
- `open::Bool = true`
    - Whether to preview the document with the default viewer, if available.
- `ignorestatus::Bool = true`
    - Whether to throw a [`TypstCommandError`](@ref) if the command errors.

# Examples

```jldoctest
julia> render(Any[true 1; 1.2 1 // 2]);
```
"""
function render(_typst_context::TypstContext, value;
    input::AbstractString = "document.typ",
    output::AbstractString = "document.pdf",
    open::Bool = true,
    ignorestatus::Bool = true
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
    input::AbstractString = "input.typ",
    output::AbstractString = "output.pdf",
    open::Bool = true,
    ignorestatus::Bool = true,
context...) = render(TypstContext(; context...), value; input, output, open, ignorestatus)

end # Render
