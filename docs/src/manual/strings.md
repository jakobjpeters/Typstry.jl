
# Strings

For a type `T`, implement `show(::IO, ::MIME"text/typst", ::T)` to specify
default settings and `show_typst(::IO, ::T)` to specify its Typst code.

![show](../assets/show.png)

```@docs
TypstString
@typst_str
Mode
show(::IO, ::MIME"text/typst", ::Any)
show_typst
```

## Interface

```@docs
IOBuffer
*
codeunit
isvalid
iterate
ncodeunits
pointer
show(::IO, ::TypstString)
```
