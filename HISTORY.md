
# History

## v0.1.0

### Strings

- `show_typst` prints a value in Typst format, with Julia settings and Typst parameters given in an `IOContext`
- `show(::IO, ::MIME"text/typst", ::Any)` provides default settings to `show_typst`
- `Mode` is a setting that specifies the current Typst context
- `TypstString` is an `AbstractString` implementing the `String` interface and uses `show(::IO, ::MIME"text/typst", ::Any)` to print values to Typst format
- `@typst_str` constructs `TypstString`s and supports formatted interpolation
- `typst_text` constructs a `TypstString` using `print` instead of `show(::IO, ::MIME"text/typst", ::Any)`
- `show(::IO, ::Union{MIME"image/png", MIME"image/svg+xml}, ::TypstString)` renders a `TypstString` and prints it in PNG or SVG format

### Commands

- `TypstCommand` implements the `Cmd` interface and represents the Typst compiler
- `@typst_cmd` constructs `TypstCommand`s
- `julia_mono` is an artifact containing the [JuliaMono](https://github.com/cormullion/juliamono) typeface, which may be used in rendered Typst documents
