
# News

## v0.4.0

### Bug Fixes

- If a `TypstString` contains any characters that satisfy `!isprint`,
`show(::IO, ::TypstString)` now prints a format that preserves those characters.
- Delete redundant `show_typst` documentation for `String`
- Account for a [Typst bug with single-letter strings in `math` mode](https://github.com/typst/typst/issues/274#issue-1639854848)
