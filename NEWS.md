
# News

## v0.4.0

- Support Typst version 0.12
- Throw a `ContextError` for context values of an incorrect type
- The `preamble` used in `render` and some `show` methods can now be specified using `set_preamble`
- `render` now supports the `ignorestatus` keyword parameter

### Bug Fixes

- If a `TypstString` contains any characters that satisfy `!isprint`,
`show(::IO, ::TypstString)` now prints a format that preserves those characters
- Account for a [Typst bug with single-letter strings in `math` mode](https://github.com/typst/typst/issues/274#issue-1639854848)
