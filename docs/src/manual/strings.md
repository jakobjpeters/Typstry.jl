
# Strings

Types should implement [`show(::IO, ::MIME"text/typst", ::Any)`](@ref) to
specify default settings and [`show_typst`](@ref) to specify their Typst code.

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
