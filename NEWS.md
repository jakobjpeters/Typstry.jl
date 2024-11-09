
# News

## v0.5.0

- Improved documentation
- `TypstError` renamed to `TypstCommandError`
- `TypstContext`
- `preamble` and `set_preamble` replaced by `context::TypstContext` and `set_context`
- New `TypstString(::TypstContext, ::Any)` constructor
- `repr(::MIME"text/typst", ::TypstString)` now returns a `String` instead of a `TypstString`
- `render` takes a `context = TypstContext()` instead of extra keyword parameters
- `TypstContext`
    - `context` function deleted
    - Use `IOContext(io, :typst_context => TypstContext(; ...))`
    - `set_context`
    - `context`
