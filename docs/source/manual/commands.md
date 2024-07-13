
# Commands

## `Typstry`

```@docs
TypstCommand
TypstError
@typst_cmd
julia_mono
preamble
render
```

## `Base`

```@docs
==
addenv
detach
eltype
firstindex
getindex
hash
ignorestatus
iterate(::TypstCommand)
keys
lastindex
length
run
setcpuaffinity
setenv
show(::IO, ::MIME"text/plain", ::TypstCommand)
show(::IO, ::Union{MIME"application/pdf", MIME"image/png", MIME"image/svg+xml"}, ::Union{Typst, TypstString, TypstText})
showerror
```
