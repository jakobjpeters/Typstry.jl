
# News

## v0.2.0

- Support `show(::IO, ::MIME"application/pdf", ::TypstString)`
- Improve error handling
    - The Typst compiler prints error messages to `stderr`
    - If not `ignorestatus`, a Typst compiler error will throw a Julia `TypstError`
