
# News

## v0.4.0

- Support Typst version 0.12
- Throw a `ContextError` for context values of an incorrect type
- The `preamble` used in `render` and some `show` methods can now be specified using `set_preamble`
- `render` now supports the `ignorestatus = true` keyword parameter
- Emulation of Typst command line interface. `typst("compile input.typ output.pdf")`

### Bug Fixes

- If a `TypstCommand` or `TypstString` contains any characters that satisfy `!isprint`,
their `show` methods now print a format that preserves those characters
- Account for a [Typst bug with single-letter strings in `math` mode](https://github.com/typst/typst/issues/274#issue-1639854848)
