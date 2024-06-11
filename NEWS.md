
# News

## v0.3.0

- Package extensions for Dates.jl, LaTeXStrings.jl, and Markdown.jl

### Strings

- New default context `backticks = 3`
- The default value for the `indent` context is now `typst"  "`, to correspond with Typst's default indentation
- Typst parameters are now printed on their own lines using the `indent` and `depth` settings
- `show_typst`
    - An `AbstractString` is no longer quoted and escaped in `code` and `math` mode
    - Implemented for `Dates.Date`, `Dates.DateTime`, `Dates.Time`, `Docs.HTML`, `LaTeXStrings.LaTeXString`, and `Markdown.MD`
- The `show` methods for `TypstString` with a `application/pdf`, `image/png`, and `image/svg+xml` MIME types now support a custom `preamble`

### Commands

- `render` now supports a custom `preamble`

## Bugs

- `@typst_str` no longer errors during interpolation when `TypstString` isn't loaded
- `Inf` and `NaN` now correspond to `calc.inf` and `calc.nan`, respectively
