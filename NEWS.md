
# News

## v0.8.0

- Implement `show(::IO, ::TypstCommand)`
- Implement interpolation for `@typst_cmd`
- Replace `typst(::String)` with `@run parameters...`
    - Constructs and runs `TypstCommand`
    - Uses `ignorestatus` and catches interrupts
- The default values for `input` and `output` are now `document.typ` and `document.pdf`, respectively

### Bug fixes

- Fixed `show(::IO, ::MIME"text/plain", ::TypstCommand)` failing to print to the `IO`
