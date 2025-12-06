
# News

## v0.7.0

### Issues

- New logo designed by @cormullion
    - Closes [#17 by @cormullion](https://github.com/jakobjpeters/Typstry.jl/issues/17)
- `show(::IO, ::MIME, ::Any)` no longer creates temporary files to render PDFs, PNGs, and SVGs
    - Closes [#20 by @Jollywatt](https://github.com/jakobjpeters/Typstry.jl/issues/20)

### Typst_jll.jl

- Support v0.14.0
- Drop support for v0.1 - 0.11
    - Minimum required version is now 0.12

### Methods

- `show_typst` for `NamedTuple`, `Symbol`, `TypstFunction`
- `*(::TypstString, ::TypstString)::TypstString`
- `Cmd(::TypstCommand; parameters...)`
- `show(::IO, ::MIME"text/plain", ::TypstString)`

### Changes

- Updated JuliaMono from version 0.55 to 0.61
- `read(::TypstCommand)` and `read(::TypstCommand, ::Type{String})`
    now throw a `TypstCommandError` upon failure
- `sizehint!(::TypstContext, n)` now returns a `TypstContext` instead of a `Dict{Symbol, Any}`
- Several `show_typst` methods have been updated
- Deleted `backticks` from the default `context`

### Other

- Documentation for image-in-terminal support
- Implement `TypstFunction`, which lowers to a function call in `code` mode

### Bug fixes

- Fixed undefined variable error when a `TypstCommand` fails
- Fixed undefined variable error for `repr(::MIME"text/typst", ::TypstString)`
- Fixed method error in `mergewith(combine, ::TypstContext, ::AbstractDict...)`
- Fixed `repr` failing to forward the `context`
- Several other fixes for `show_typst`
