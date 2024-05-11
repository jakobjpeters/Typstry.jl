
# Strings

Types should implement [`show(::IO, ::MIME"text/typst", ::Any)`](@ref) to
specify default settings and [`show_typst`](@ref) to specify their Typst code.

![strings](../assets/strings.png)

## `Typstry`

```@docs
Mode
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
iterate
ncodeunits
pointer
show(::IO, ::MIME"image/png", ::TypstString)
show(::IO, ::MIME"text/typst", ::Any)
show(::IO, ::TypstString)
```
