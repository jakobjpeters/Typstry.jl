
# History

## v0.3.0

### Strings

- `context`
    - New default setting `backticks = 3` used for Typst `raw` blocks
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

## v0.2.0

### Strings

- Pass formatting configuration to a `TypstString` with keyword parameters instead of `Pair{Symbol}`s
- Remove type piracy of `show` with the `text/typst` MIME type
    - Values may instead be wrapped in `Typst`
    - Formatting may be configured by implementing a custom `context`
- Support `show(::IO, ::MIME"application/pdf", ::TypstString)`
- Replace `typst_text` constructor with the `TypstText` wrapper
- `show_typst`
    - Implement `show_typst(x)`, which prints to `stdout`
    - Implemented for `AbstractArray`, `Complex{Bool}`, `Tuple`, `Typst`, `TypstText`, and `Unsigned`
    - `Nothing` now corresponds to the Typst `none`
    - `AbtractMatrix` and `AbstractVector` in `code` mode now correspond to a Typst array
    - `OrdinalRange{<:Integer, <:Integer}` and `StepRangeLen{<:Integer, <:Integer, <:Integer}`
        - `code` mode implicitily uses the Typst default `step` if it is equal to `1`
        - `markup` and `math` mode now correspond to a Typst vector
    - The `Docs.Text` format is simpler in `markup` mode
        - This introduced a bug, which is patched in v0.3.0
    - New default setting `parenthesize = true`
        - Used for `Complex` and `Rational`
    - Rename the `inline` setting to `block` for consistency with Typst's `equation` function
        - This toggles the default behavior, which is now inline

### Commands

- Easily `render` a Julia value to a Typst source file and compiled document
- Increase coverage of the `Cmd` interface implementation for `TypstCommand`
- Improve error handling
    - The Typst compiler prints error messages to `stderr`
    - If not `ignorestatus`, a Typst compiler error will throw a Julia `TypstError`

### Bug Fixes

- Patch an assumption in `repr(::MIME, ::AbstractString)` that is incorrect for `TypstString`
- Format values in containers using `show(::IO, ::MIME"text/typst", ::Typst)`
- `show_typst(io, ::AbstractString)` now correctly escapes double quotation marks ~~and dollar signs~~.
- `show_typst(io, ::Complex)`
    - Fix `Complex{Bool}`
    - Handle negative imaginary part

## v0.1.0

### Strings

- `show_typst` prints a value in Typst format, with Julia settings and Typst parameters given in an `IOContext`
    - Implemented for `AbstractChar`, `AbstractFloat`, `AbstractMatrix`, `AbstractString`, `AbstractVector`, `Bool`, `Complex`, `Irrational`, `Nothing`, `OrdinalRange{<:Integer, <:Integer}`, `Rational`, `Regex`, `Signed`, `StepRangeLen{<:Integer, <:Integer, <:Integer}`, `Text`, and `TypstString`
- `show(::IO, ::MIME"text/typst", ::Any)` provides default settings to `show_typst`
- `Mode` is used to specify the current Typst context in `show_typst`
- `TypstString` is an `AbstractString` implementing the `String` interface and uses `show(::IO, ::MIME"text/typst", ::Any)` to print values to Typst format
- `@typst_str` constructs `TypstString`s and supports formatted interpolation
- `typst_text` constructs a `TypstString` using `print` instead of `show(::IO, ::MIME"text/typst", ::Any)`
- `show(::IO, ::Union{MIME"image/png", MIME"image/svg+xml}, ::TypstString)` renders a `TypstString` and prints it in PNG or SVG format

### Commands

- `TypstCommand` implements the `Cmd` interface and represents the Typst compiler
- `@typst_cmd` constructs `TypstCommand`s
- `julia_mono` is an artifact containing the [JuliaMono](https://github.com/cormullion/juliamono) typeface, which may be used in rendered Typst documents
