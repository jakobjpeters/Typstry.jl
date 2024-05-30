
# News

## v0.2.0

### Strings

- Remove type piracy by requiring values to be either a `TypstString` or wrapped in `Typst`
    - Format may be specified by implementing a custom `context`
- Support `show(::IO, ::MIME"application/pdf", ::TypstString)`
- Formatting options in `TypstString` are now passed as keyword parameters instead of `Pair{Symbol}`s
- Replace `typst_text` constructor with `TypstText` wrapper
- `show_typst`
    - Implement `show_typst(x)` which prints to `stdout`
    - Implemented for `AbstractArray`, `Tuple`, `Typst`, and `Unsigned`
    - `nothing` now corresponds to Typst's `none`
    - `AbtractMatrix` and `AbstractVector` in `code` mode now correspond to a Typst array
    - `OrdinalRange{<:Integer, <:Integer}` and `StepRangeLen{<:Integer, <:Integer, <:Integer}`
        - `code` mode implicitely uses the Typst default `step` if it is equal to `1`
        - `markup` and `math` mode now correspond to a Typst vector
    - New default setting `parenthesize = true`
        - Used for `Complex` and `Rational`
    - The `inline` setting has been renamed to `block` to be consistent with Typst's `equation` function
        - This toggles the default behavior, which is now inline

### Commands

- Implement `render` to easily generate a Typst document
- Increase coverage of the `Cmd` interface implementation for `TypstCommand`
- Improve error handling
    - The Typst compiler prints error messages to `stderr`
    - If not `ignorestatus`, a Typst compiler error will throw a Julia `TypstError`

### Bug Fixes

- Patch incorrect output from an assumption in `repr(::MIME, ::TypstString)`
- Format values in containers using `show(::IO, ::MIME"text/typst", ::Typst)`
- `show_typst(io, ::AbstractString)` now correctly escapes double quotation marks and dollar signs.
- `show_typst(io, ::Complex)`
    - Fix `Complex{Bool}`
    - Handle negative imaginary part
