
# News

## v0.3.0

### Strings

- New default context `backticks = 3`
- The default value for the `indent` context is now `typst"  "`, to correspond with Typst's default indentation
- Typst parameters are now printed on their own lines using the `indent` and `depth` settings
- `show_typst`
    - `Signed` in `markup` mode is now converted to a `code` mode integer
    - An `AbstractChar` and `AbstractString` now correspond to a Typst string
    - Implemented for `Dates.Date`, `Dates.DateTime`, `Dates.Day`, `Dates.Hour`, `Dates.Minute`, `Dates.Second`, `Dates.Time`, `Dates.Week`, `Docs.HTML`, `LaTeXStrings.LaTeXString`, `Markdown.MD`, and `VersionNumber`
- The `show` methods for `TypstString` with a `application/pdf`, `image/png`, and `image/svg+xml` MIME types now support a custom `preamble`

### Commands

- `render` now supports a custom `preamble`

## Bugs

- `@typst_str` no longer errors during interpolation when `TypstString` isn't loaded
- `Inf` and `NaN` now correspond to `calc.inf` and `calc.nan`, respectively
