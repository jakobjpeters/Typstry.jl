
# News

## v0.8.0

- Implement `show(::IO, ::TypstCommand)`
- Replace `typst(::String)` with `@run parameters...`
    - Constructs and runs `TypstCommand`
    - Uses `ignorestatus` and catches interrupts

### Bug fixes

- Fixed `show(::IO, ::MIME"text/plain", ::TypstCommand)` failing to print to the `IO`
