
# Strings

## `Typstry`

```@docs
Mode
Typst
TypstString
@typst_str
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
show(::IO, ::MIME"text/typst", ::Union{Typst, TypstString})
show(::IO, ::Union{MIME"application/pdf", MIME"image/png", MIME"image/svg+xml"}, ::TypstString)
```
