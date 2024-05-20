
# News

## v0.2.0

### Strings

- Support `show(::IO, ::MIME"application/pdf", ::TypstString)`
- Patch incorrect output from an assumption in `repr(::MIME, ::TypstString)`
- Formatting options in `TypstString` are now passed as keyword parameters instead of `Pair{Symbol}`s
- `show_typst`
    - Implemented for `Tuple`, `Typst`, and `Unsigned`
    - `nothing` now corresponds to Typst's `none`
    - `AbtractMatrix` and `AbstractVector` in `code` mode now correspond to a Typst array
    - `OrdinalRange{<:Integer, <:Integer}` and `StepRangeLen{<:Integer, <:Integer, <:Integer}` in `markup` and `math` mode now correspond to a Typst vector
    - New default setting `parenthesize = true`
        - Used for `Complex` and `Rational`
    - The `inline` setting has been renamed to `block` to be consistent with Typst's `equation` function
        - This toggles the default behavior, which is now inline

### Commands

- Increase coverage of the `Cmd` interface implementation for `TypstCommand`
- Improve error handling
    - The Typst compiler prints error messages to `stderr`
    - If not `ignorestatus`, a Typst compiler error will throw a Julia `TypstError`
