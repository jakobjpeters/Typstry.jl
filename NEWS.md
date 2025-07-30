
# News

## v0.6.0

- New methods for `show_typst`, `TypstString`, and `render` to accept context information with either a `TypstContext` or keyword parameters
- Implementing `show_typst` now requires a `TypstContext`
- New default `context` key `io = DefaultIO()`
- Improved documentation
- `TypstError` renamed to `TypstCommandError`
- `preamble` and `set_preamble` has been generalized to `context::TypstContext` and `reset_context`
- `render` now returns `nothing`
- `TypstContext` implements the dictionary and iteration interfaces
    - Use `IOContext(::IO, TypstContext(; ...))`
    - `reset_context` will return the `context` to its default state
- Several `show_typst` methods have been updated to have a single rendered format regardless of the `Mode`
- `TypstText` and `Typst` implement `repr` with the `text/typst` `MIME` to return a `TypstString`
