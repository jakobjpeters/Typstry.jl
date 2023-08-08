
module Typstry

import Typst_jll

"""
    typst(args...)

Call the `typst` command-line interface with the given arguments via
[`Typst_jll.jl`](https://github.com/JuliaBinaryWrappers/Typst_jll.jl).

Equivalent to `\$ typst args...` in the shell.
"""
typst(args...) = Typst_jll.typst(exe -> run(Cmd([exe, args...])))

"""
    typst(command::Function, args...; pre_options = (), post_options = ())

Equivalent to `typst(pre_options..., string(command), post_options..., args...)`.
"""
typst(command::Function, args...; pre_options = (), post_options = ()) =
    typst(pre_options..., string(command), post_options..., args...)

"""
    compile(input, [output]; pre_options = (), post_options = ())

Equivalent to [`typst(compile, input, output; pre_options, post_options)`](@ref typst).
```
"""
compile(input, output = nothing; pre_options = (), post_options = ()) =
    typst(compile, filter(!isnothing, (input, output))...; pre_options, post_options)

"""
    watch(input, [output]; pre_options = (), post_options = ())

Equivalent to [`typst(watch, input, output; pre_options, post_options)`](@ref typst).
"""
watch(input, output = nothing; pre_options = (), post_options = ()) =
    typst(watch, filter(!isnothing, (input, output))...; pre_options, post_options)

"""
    fonts(; pre_options = (), post_options = ())

Equivalent to [`typst(fonts; pre_options, post_options)`](@ref typst).
"""
fonts(; pre_options = (), post_options = ()) = typst(fonts; pre_options, post_options)

"""
    help([command::Function])

Prints the help message for `typst` or the given `command`.

Equivalent to [`typst(help, command)`](@ref typst).

# Examples
```jldoctest
julia> help();
typst creates PDF files from .typ files

Usage: typst [OPTIONS] <COMMAND>

Commands:
  compile  Compiles the input file into a PDF file [aliases: c]
  watch    Watches the input file and recompiles on changes [aliases: w]
  fonts    List all discovered fonts in system and custom font paths
  help     Print this message or the help of the given subcommand(s)

Options:
      --font-path <DIR>  Add additional directories to search for fonts [env: TYPST_FONT_PATHS=]
      --root <DIR>       Configure the root for absolute paths [env: TYPST_ROOT=]
  -v, --verbosity...     Sets the level of verbosity: 0 = none, 1 = warning & error, 2 = info, 3 = debug, 4 = trace
  -h, --help             Print help
  -V, --version          Print version

julia> help(fonts);
List all discovered fonts in system and custom font paths

Usage: typst fonts [OPTIONS]

Options:
      --variants  Also list style variants of each font family
  -h, --help      Print help
```
"""
help() = typst(help)
help(command::Function) = typst(help, string(command))

"""
    t_str(s)

Construct a string without interpolation and unescaping
(except for quotation marks, `\"`, which still have to be escaped).

!!! note
    This macro is currently equivalent to `@raw_str`.
    Future work will implement custom interpolation.

# Examples
```jldoctest
julia> t"\$1 / x\$"
"\\\$1 / x\\\$"
```
"""
macro t_str(s)
    s
end

export typst, compile, watch, fonts, help, @t_str

end # module Typst
