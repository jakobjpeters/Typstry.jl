
# News

## v0.6.0

- `show_typst` now takes a `TypstContext`
- New default `context` key `io_context = Dict{Symbol, Any}(:compact => true)`
- Improved documentation
- `TypstError` renamed to `TypstCommandError`
- `preamble` and `set_preamble` replaced by `context::TypstContext` and `reset_context`
- New `TypstString(::TypstContext, ::Any)` constructor
- `repr(::MIME"text/typst", ::TypstString)` now returns a `String` instead of a `TypstString`
- `render`
    - May take a `TypstContext` instead of extra keyword parameters
    - Now returns `nothing`
- `TypstContext`
    - `context` function deleted
    - Use `IOContext(io, :typst_context => TypstContext(; ...))`
    - `reset_context`
