
# News

## v0.3.0

### Strings

- `context`
    - New default key `backticks = 3`
    - The `indent` setting is now `tab_size = 2`, to correspond with Typst's default parameter
- `show_typst`
    - Implemented for `VersionNumber`, `Dates.Date`, `Dates.DateTime`, `Dates.Period`, `Dates.Time`, `Docs.HTML`, `LaTeXStrings.LaTeXString`, and `Markdown.MD`
    - `AbstractFloat`, `Irrational`, and `Signed` in `markup` mode are now enclosed in dollar signs
    - `Bool` in `markup` mode is no longer prefixed by a number sign
    - An `AbstractChar` and `AbstractString` in `code` and `math` mode is no longer escaped and quoted
    - A `Complex` is no longer parenthesized when one of the terms is zero
    - Typst parameters are now printed on their own lines using the `indent` and `depth` settings
- Improved error handling for interpolating incomplete expressions into a `@typst_str`

### Commands

- The `preamble` used at the beginning of Typst source files is now exported
- `render` now supports a custom `preamble`
- The `show` method with the `application/pdf`, `image/png`, and `image/svg+xml` MIME types now supports
    - A custom `preamble`
    - `Typst` and `TypstText`
- Removed an unnecessary `TypstCommand` constructor

## Bug Fixes

- `@typst_str`
    - No longer errors during interpolation when `TypstString` isn't loaded
    - Handles interpolation and escaped interpolation in the same manner as a `String`
        - `@typst_str` syntax and pretty-printing with `show(::IO, ::TypstString)` now correspond
- `show_typst`
    - `AbstractFloat` values that satisfy `isinf` and `isnan` now correspond to `calc.inf` and `calc.nan`, respectively
    - `AbstractString` and `Docs.Text` no longer escape dollar signs
    - Removed incorrect special formatting of `Docs.Text` in `markup` mode
- A `@typst_cmd` with no parameters no longer inserts an empty parameter
