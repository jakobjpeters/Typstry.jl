
module DefaultIOs

import Base: show

export DefaultIO

"""
    DefaultIO
    DefaultIO()

A type used to initialize the default `io` in [`context`](@ref Typstry.Contexts.TypstContexts.context).

!!! info
    This is a workaround for `stdout` being invalid when assigned to a global variable.

# Examples

```julia-repl
julia> io = context[:io]::DefaultIO
(() -> IOContext(stdout, :compact => true))::DefaultIO

julia> io == DefaultIO()() == IOContext(stdout, :compact => true)
true
```
"""
struct DefaultIO end

(::DefaultIO)() = IOContext(stdout, :compact => true)

function show(io::IO, ::DefaultIO)
    print(io, "(() -> ")
    show(io, IOContext)
    print(io, "(stdout, :compact => true))::")
    show(io, DefaultIO)
end

end # DefaultIOs
