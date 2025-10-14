
# News

## v0.7.0

- Dropped support for Typst_jll.jl v0.1 - 0.11
    - Minimum required version of Typst_jll is now 0.12
- `show(::IO, ::MIME, ::Any)` no longer creates temporary files to render PDFs, PNGs, and SVGs
    - Closes [#20 by @Jollywatt](https://github.com/jakobjpeters/Typstry.jl/issues/20)
- Implemented `Cmd(::TypstCommand; parameters...)`
- `read(::TypstCommand)` and `read(::TypstCommand, ::Typst{String})`
    now throw a `TypstCommandError` upon failure

### Bug fixes

- Fixed undefined variable error when a `TypstCommand` fails
