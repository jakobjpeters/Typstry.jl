
# News

## v0.4.0

- Support Typst version 0.12

### Bug Fixes

- If a `TypstString` contains any characters that satisfy `!isprint`,
`show(::IO, ::TypstString)` now prints a format that preserves those characters.
- Account for a [Typst bug with single-letter strings in `math` mode](https://github.com/typst/typst/issues/274#issue-1639854848)
