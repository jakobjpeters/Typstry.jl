
module Typstry

import Typst_jll
using Base: Meta.parse

# Internals

"""
    typst_cmd(x; kwargs...)
"""
typst_cmd(xs; kwargs...) = Cmd(`$(Typst_jll.typst()) $xs`; kwargs...)
typst_cmd(s::String; kwargs...) = typst_cmd(split(s); kwargs...)

# Interface

"""
    @typst_str(s)
    typst"s"

Construct a string with custom interpolation and without unescaping.
Backslashes (`\\`) and quotation marks (`\"`) must still be escaped.

Use `\$\$` to interpolate values.
The `\$` symbol is not used because Typst uses
that symbol to start and end a math mode block.

!!! warning
    See also the performance tip to [avoid string interpolation for I/O]
    (https://docs.julialang.org/en/v1/manual/performance-tips/#Avoid-string-interpolation-for-I/O).

# Examples
```jldoctest
julia> x = 1;

julia> typst"\$1 / x\$"
\"\\\$1 / x\\\$\"

julia> typst"\$\$x \$\$(x + 1)"
"1 2"

julia> typst"\\\$\$x"
"\\\$\\\$x"

julia> typst"\\\\"
"\\\\"
```
"""
macro typst_str(s)
    esc(parse("\"" * replace(s,
        "\\\$\$" => "\\\$\\\$", "\$\$" => "\$", "\$" => "\\\$", "\"" => "\\\"", "\\" => "\\\\"
    ) * "\""))
end

"""
    @typst_cmd(s)
    typst`s`

Return a `Cmd` whose first argument is the Typst command-line interface
and whose remaining arguments are given by `split(s)`.

!!! note
    This macro does not yet support interpolation.

# Examples
```jldoctest
julia> run(typst`help`);
The Typst compiler

Usage: typst [OPTIONS] <COMMAND>

Commands:
  compile  Compiles an input file into a supported output format [aliases: c]
  watch    Watches an input file and recompiles on changes [aliases: w]
  query    Processes an input file to extract provided metadata
  fonts    Lists all discovered fonts in system and custom font paths
  update   Self update the Typst CLI (disabled)
  help     Print this message or the help of the given subcommand(s)

Options:
  -v, --verbosity...  Sets the level of logging verbosity: -v = warning & error, -vv = info, -vvv = debug, -vvvv = trace
      --cert <CERT>   Path to a custom CA certificate to use when making network requests [env: TYPST_CERT=]
  -h, --help          Print help
  -V, --version       Print version

julia> write("input.typ", typst"\$x ^ 2\$");

julia> run(typst`compile input.typ output.pdf`);
```
"""
macro typst_cmd(s)
    typst_cmd(s)
end

"""
    typst(x; kwargs...)

Construct and run a `Cmd` whose first argument is the Typst command-line interface
and whose remaining arguments are given by `x`.

If `x` is a string, the arguments are given by `split(x)`.
The `kwargs` are passed to `Cmd`.

See also [`@typst_cmd`](@ref).

# Examples
```jldoctest
julia> typst("help");
The Typst compiler

Usage: typst [OPTIONS] <COMMAND>

Commands:
  compile  Compiles an input file into a supported output format [aliases: c]
  watch    Watches an input file and recompiles on changes [aliases: w]
  query    Processes an input file to extract provided metadata
  fonts    Lists all discovered fonts in system and custom font paths
  update   Self update the Typst CLI (disabled)
  help     Print this message or the help of the given subcommand(s)

Options:
  -v, --verbosity...  Sets the level of logging verbosity: -v = warning & error, -vv = info, -vvv = debug, -vvvv = trace
      --cert <CERT>   Path to a custom CA certificate to use when making network requests [env: TYPST_CERT=]
  -h, --help          Print help
  -V, --version       Print version

julia> write("input.typ", typst"\$x ^ 2\$");

julia> typst("compile input.typ output.pdf");
```
"""
typst(x; kwargs...) = run(typst_cmd(x; kwargs...))

"""
    render(elements...;
        delimeter = "", input = "input.typ", output = "output.pdf", open_output = true
    )

Render the `elements`, each separated by the `delimeter`, to a document.

This function generates two files.
The first is the `input`, which contains the Typst code.
The second is the `output`, which is rendered from the `input` using Typst's compile command.

The document format is inferred by the file extension of `output`.
The available formats are `pdf`, `png`, and `svg`.

If `open_output = true`, the `output` will be opened using the default viewer.

# Examples
```jldoctest
julia> render(typst"\$x ^ 2\$");

julia> render([1, 2, 3, 4]);
```
"""
function render(elements...; delimeter = "", input = "input.typ", output = "output.pdf", open_output = true)
    open(file -> join(file, elements, delimeter), input; truncate = true)
    typst(("compile", input, output, "--open")[begin:end - !open_output])
end

export @typst_str, @typst_cmd, typst, render

end # module
