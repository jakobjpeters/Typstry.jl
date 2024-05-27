
# Strings

## `Typstry`

```@docs
Mode
Typst
TypstString
@typst_str
context
show_typst
typst_text
```

## `Base`

```@docs
IOBuffer
codeunit
isvalid
iterate(::TypstString)
ncodeunits
pointer
repr
show(::IO, ::TypstString)
show(::IOContext, ::MIME"text/typst", ::Union{Typst, TypstString})
show(::IO, ::Union{MIME"application/pdf", MIME"image/png", MIME"image/svg+xml"}, ::TypstString)
```
