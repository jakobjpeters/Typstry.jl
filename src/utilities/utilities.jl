
include("context_error.jl")

"""
    enclose(f, io, x, left, right = reverse(left); kwargs...)

Call `f(io,\u00A0x;\u00A0kwargs...)` between printing `left` and `right`, respectfully.

# Examples

```jldoctest
julia> Typstry.enclose((io, i; x) -> print(io, i, x), stdout, 1, "\\\$ "; x = "x")
\$ 1x \$
```
"""
function enclose(f, io, x, left, right = reverse(left); context...)
    print(io, left)
    f(io, x; context...)
    print(io, right)
end

"""
    join_with(f, io, xs, delimeter; kwargs...)

Similar to `join`, except printing with `f(io, x; kwargs...)`.

# Examples

```jldoctest
julia> Typstry.join_with((io, i; x) -> print(io, -i, x), stdout, 1:4, ", "; x = "x")
-1x, -2x, -3x, -4x
```
"""
function join_with(f, io, xs, delimeter; kwargs...)
    _xs = Stateful(xs)

    for x in _xs
        f(io, x; kwargs...)
        isempty(_xs) || print(io, delimeter)
    end
end
