
# Strings

```@eval
using Markdown, Typstry
Markdown.parse("This reference documents " * lowercasefirst(split(string(@doc Typstry.Strings), "\n")[5]))
```

```@docs
ContextError
Mode
Typst
TypstString
TypstText
@typst_str
code
markup
math
context
show_typst(::Any, ::AbstractChar)
```

```@docs
show(::IO, ::MIME"text/plain", ::ContextError)
show(::IO, ::MIME"text/typst", ::Typst)
showerror(::IO, ::ContextError)
```
