
# News

## v0.2.0

- Support `show(::IO, ::MIME"application/pdf", ::TypstString)`
- Improve error handling
    - The Typst compiler prints error messages to `stderr`
    - If not `ignorestatus`, a Typst compiler error will throw a Julia `TypstError`
- Increase coverage of the `Cmd` interface implementation for `TypstCommand`
- Patch incorrect output from an assumption in `repr(::MIME, ::TypstString)`
