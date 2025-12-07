
module Utilities

using .Iterators: Stateful
using Typstry: TypstContext, ContextError, context

export enclose, join_with, typst_context, unwrap

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
function join_with(callback, io::IO, values, delimeter; parameters...)
    stateful_values = Stateful(values)

    for stateful_value in stateful_values
        callback(io, stateful_value; parameters...)
        isempty(stateful_values) || print(io, delimeter)
    end
end

function typst_context(ioc::IOContext, tc::TypstContext, ____tc::TypstContext, value)
    _tc = typst_context(ioc)
    __tc = merge!(copy(_tc), tc)
    ___tc = unwrap(_tc, :context, TypstContext())

    if haskey(ioc, :typst_context) _tc[:context] = __tc
    else ioc = IOContext(ioc, __tc)
    end

    (ioc, merge!(mergewith!((x, _) -> x, ____tc, context), ___tc, __tc), value)
end
typst_context(ioc::IOContext, tc::TypstContext, value) = typst_context(
    ioc, tc, TypstContext(value), value
)
typst_context(io::IO, tc::TypstContext, value) = typst_context(IOContext(io), tc, value)
typst_context(io::IO, value) = typst_context(io, TypstContext(), value)
function typst_context(tc::TypstContext, value)
    _tc = TypstContext(value)
    # TODO: throw a `ContextError`
    typst_context(get(() -> context[:io]()::IO, tc, :io), tc, _tc, value)
end
typst_context(io_context::IOContext) = unwrap(io_context, :typst_context, TypstContext())
typst_context(::IO) = TypstContext()

function _unwrap(data_type::DataType, key::Symbol, value)
    value isa data_type ? value : throw(ContextError(data_type, typeof(value), key))
end

unwrap(collection, key::Symbol, default) = _unwrap(
    typeof(default), key, get(collection, key, default)
)
function unwrap(collection, type::DataType, key)
    value = collection[key]
    _unwrap(type, key, value)
end

end # Utilities
