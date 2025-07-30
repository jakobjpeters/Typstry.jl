
"""
    render(::TypstContext, value; parameters...)
    render(value; parameters..., context...)

Render the `value` to a document.

This supports using the [`julia_mono`](@ref) typeface.

See also [`TypstContext`](@ref).

# Parameters

- `input::AbstractString = "input.typ"`
    - Write the `preamble` and formatted value to this Typst source file.
- `output::AbstractString = "output.pdf"`
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
function render(tc::TypstContext, value;
    input::AbstractString = "input.typ",
    output::AbstractString = "output.pdf",
    open::Bool = true,
    ignorestatus::Bool = true
)
    Base.open(input; truncate = true) do file
        ioc, tc, _ = typst_context(file, tc, value)
        print(ioc, preamble(tc))
        show_typst(IOContext(ioc, tc), value)
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
