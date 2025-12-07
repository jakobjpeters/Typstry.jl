
module JuliaMono

using Artifacts: @artifact_str

"""
    julia_mono

A constant `String` file path to the
[JuliaMono](https://github.com/cormullion/juliamono) typeface.

This typeface is available when using one of the following approaches:

- `TypstCommand(["compile", "input.typ", "output.pdf", "--font-path=\$julia_mono"])`
- `addenv(::TypstCommand,\u00A0"TYPST_FONT_PATHS"\u00A0=>\u00A0julia_mono)`
- `setenv(::TypstCommand,\u00A0"TYPST_FONT_PATHS"\u00A0=>\u00A0julia_mono)`
- `ENV["TYPST_FONT_PATHS"] = julia_mono`

and when compiling documents with the following methods:

- [`@run`](@ref Typstry.Commands.Run.@run)
- [`render`](@ref Typstry.Render.render)
- `show` with the `application/pdf`, `image/png`, `image/svg+xml`, and `image/webp`
    `MIME` types and a `TypstFunction`, `TypstString`, `TypstText`, and `Typst` value

See also [`TypstCommand`](@ref Typstry.Commands.TypstCommands.TypstCommand).
"""
const julia_mono = artifact"JuliaMono"

end # JuliaMono
