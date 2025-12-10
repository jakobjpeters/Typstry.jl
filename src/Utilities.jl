
module Utilities

using .Iterators: Stateful

export enclose, join_with

"""
    enclose(callback, io, value, left, right = reverse(left); parameters...)

Call `callback(io,\u00A0value;\u00A0parameters...)`
between printing `left` and `right`, respectfully.

# Examples

```jldoctest
julia> Typstry.Utilities.enclose((io, i; x) -> print(io, i, x), stdout, 1, "\\\$ "; x = "x")
\$ 1x \$
```
"""
function enclose(callback, io::IO, value, left, right = reverse(string(left)); parameters...)
    print(io, left)
    callback(io, value; parameters...)
    print(io, right)
end

"""
    join_with(callback, io, values, delimeter; keyword_parameters...)

Similar to `join`, except printing with `callback(io, value; keyword_parameters...)`.

# Examples

```jldoctest
julia> Typstry.Utilities.join_with((io, i; x) -> print(io, -i, x), stdout, 1:4, ", "; x = "x")
-1x, -2x, -3x, -4x
```
"""
function join_with(callback, io::IO, values, delimiter; parameters...)
    stateful_values = Stateful(values)

    for stateful_value in stateful_values
        callback(io, stateful_value; parameters...)
        isempty(stateful_values) || print(io, delimiter)
    end
end

end # Utilities
