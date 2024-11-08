
# News

## v0.5.0

- `TypstError` renamed to `TypstCommandError`
- `set_preamble` no longer returns its value
- `TypstContext`
    - `context` function deleted
    - Use `IOContext(io, :typst_context => TypstContext(; ...))`
    - `set_context`
    - `context`
