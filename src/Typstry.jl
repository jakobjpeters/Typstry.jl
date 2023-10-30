
module Typstry

import Typst_jll
using Base: Meta.parse

# Internals

"""
    interpolate(xs, s, start, stop)
"""
interpolate(xs, s, start, stop) = push!(xs, esc(parse(s[start:stop])))

"""
    typst_cmd(s)
"""
typst_cmd(s) = `$(Typst_jll.typst()) $(split(s))`

# Interface

"""
    @typst_str(s)

Construct a string with custom interpolation and without unescaping.
Backslashes (`\\`) and quotation marks (`\"`) must still be escaped.

Use `\$\$` to interpolate values.
The `\$` symbol is not used because Typst uses
that symbol to start and end a math mode block.

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
    i, n, xs = 1, length(s), []
    while i <= n
        maybe_j = findnext("\$\$", s, i)
        if isnothing(maybe_j)
            push!(xs, s[i:n])
            break
        end
        j = first(maybe_j) - 1
        push!(xs, s[i:j - 1])
        i = j + 3
        if j != 0 && s[j] == '\\' push!(xs, s[j + 1: j + 2])
        else
            (j + 2 == n || s[j + 3] == ' ') && error("invalid interpolation syntax: missing value")
            j != 0 && push!(xs, s[j])
            k = j + 3
            if s[i] == '('
                i += open = 1
                while open != 0 && (i <= n || error("invalid interpolation syntax: unmatched parentheses"))
                    open += (s[i] == '(') - (s[i] == ')')
                    i += 1
                end
                interpolate(xs, s, k, i - 1)
            else
                maybe_i = findnext(' ', s, i)
                if isnothing(maybe_i)
                    interpolate(xs, s, k, n)
                    break
                end
                i = only(maybe_i)
                interpolate(xs, s, k, i)
            end
        end
    end
    :(string($(xs...)))
end

"`\$x`"

"""
    @typst_cmd(s)

Return a `Cmd` such that ```run(typst`\$s`)```
is equivalent to `shell> typst \$s`.

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
    typst(s)

Equivalent to `shell> typst \$s`.

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
typst(s) = run(typst_cmd(s))

"""
    typst(xs...)

Equivalent to `typst(join(xs, " "))`.

# Examples
```jldoctest
julia> write("input.typ", typst"\$x ^ 2\$");

julia> typst("compile", "input.typ", "output.pdf");
```
"""
typst(xs...) = typst(join(xs, " "))

"""
    render(::String; input = "input.typ", output = "output.pdf", open = true)

Render the given string to a document.

This function generates two files.
The first is the `input`, which contains the Typst document.
The second is the `output`, which is rendered from the `input` using Typst's compile function.

The document format is inferred by the file extension of `output`.
The available formats are `pdf`, `png`, and `svg`.

If `open`, `output` will be opened using the default viewer.

!!! note
    This is designed to generate a document with little effort.
    For more advanced useage, see [`typst`](@ref).

# Examples
```jldoctest
julia> render(typst"\$x ^ 2\$");

julia> render([1, 2, 3, 4]);
```
"""
function render(document::String; input = "input.typ", output = "output.pdf", open = true)
    write(input, document)
    typst(("compile", input, output, "--open")[begin:end - !open]...)
end

"""
    render(elements...; delimeter = " \\\\n", kwargs...)

Equivalent to `render(join(xs, delimeter; kwargs...))`.

# Examples
```jldoctest
julia> render("The area of a circle is", typst"\$A = pi dot r ^ 2\$"; delimeter = " ");
```
"""
render(elements...; delimeter = " \\\n", kwargs...) = render(join(elements, delimeter); kwargs...)

export @typst_str, @typst_cmd, typst, render

end # module
