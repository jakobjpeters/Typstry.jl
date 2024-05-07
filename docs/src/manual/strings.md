
# Strings

For a type `T`, implement `show(::IO, ::MIME"text/typst", ::T)` to specify
default settings and `show_typst(::IO, ::T)` to specify its Typst code.

![strings](../assets/strings.png)

## `Typstry`

```@docs
Mode
TypstString
TypstText
@typst_str
show_typst
```

## `Base`

```@docs
IOBuffer
*
codeunit
isvalid
iterate
ncodeunits
pointer
show(::IO, ::MIME"text/typst", ::Any)
show(::IO, ::TypstString)
```
