
# Commands

```@eval
using Markdown, Typstry
Markdown.parse("This reference documents " * lowercasefirst(split(string(@doc Typstry.Commands), "\n")[5]))
```

## `Typstry`

```@docs
TypstCommand
TypstCommandError
@typst_cmd
julia_mono
preamble
render
set_preamble
typst
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
read
run
setcpuaffinity
setenv
show(::IO, ::MIME"text/plain", ::TypstCommand)
show(::IO, ::MIME"text/plain", ::TypstCommandError)
show(::IO, ::Union{MIME"application/pdf", MIME"image/png", MIME"image/svg+xml"}, ::Union{Typst, TypstString, TypstText})
showerror(::IO, ::TypstCommandError)
```
