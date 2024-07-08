
# News

## v0.3.0

### Strings

- New default context `backticks = 3`
- The `indent` setting has been changed to `tab_size = 2`, to correspond with Typst's default parameter
- Typst parameters are now printed on their own lines using the `indent` and `depth` settings
- `show_typst`
    - Implemented for `Dates.Date`, `Dates.DateTime`, `Dates.Day`, `Dates.Hour`, `Dates.Minute`, `Dates.Second`, `Dates.Time`, `Dates.Week`, `Docs.HTML`, `LaTeXStrings.LaTeXString`, `Markdown.MD`, and `VersionNumber`
    - `AbstractFloat`, `Irrational`, and `Signed` in `markup` mode are now enclosed with `$`
    - `Bool` in `markup` mode is no longer prefixed by `#`
    - An `AbstractChar` and `AbstractString` in `code` and `math` mode are no longer escaped and quoted
    - A `Complex` is no longer parenthesized when a term is zero
- The `show` methods with the `applicatoin/pdf`, `image/png`, and `image/svg+xml` MIME types
    - Can be given a custom `preamble`
    - Support `Typst` and `TypstText`
- Improved error handling for interpolating incomplete expressions into a `@typst_str`

### Commands

- `render` now supports a custom `preamble`

## Bug Fixes

- `@typst_str`
    - No longer errors during interpolation when `TypstString` isn't loaded
    - Handle interpolation and escaped interpolation in the same manner as double quotation marks
        - `print` and `show` now correspond
- A `@typst_cmd` with no parameters no longer inserts an empty parameter
- `AbstractFloat` values that satisfy `isinf` and `isnan` now correspond to `calc.inf` and `calc.nan`, respectively
- `AbstractString` and `Text` no longer escape `$`
