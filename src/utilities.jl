
# """
#     counter
# """
# const counter = Stateful(countfrom())

# """
#     lock
# """
# const lock = ReentrantLock()

"""
    compile_workload(examples)

Given an iterable of value-type pairs, interpolate each value into
a `@typst_str` within a `PrecompileTools.@compile_workload` block.
"""
compile_workload(examples::Vector) = @compile_workload for example ∈ examples
    render(first(example))
end

"""
    enclose(f, io, x, left, right = reverse(left); kwargs...)

Call `f(io,\u00A0x;\u00A0kwargs...)` between printing `left` and `right`, respectfully.

# Examples

```jldoctest
julia> Typstry.enclose((io, i; x) -> print(io, i, x), stdout, 1, "\\\$ "; x = "x")
\$ 1x \$
```
"""
function enclose(f, io::IO, x, left::String, right::String = reverse(left); context...)
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
function join_with(f, io::IO, xs, delimeter; kwargs...)
    _xs = Stateful(xs)

    for x in _xs
        f(io, x; kwargs...)
        isempty(_xs) || print(io, delimeter)
    end
end

"""
    merge_contexts!(tc, context)
"""
merge_contexts!(tc, context) = mergewith!((x, _) -> x, tc, context)

"""
    typst_context(::IO)
"""
# typst_context(ioc::IOContext) = unwrap(ioc, :typst_context, TypstContext())
# typst_context(::IO) = TypstContext()
typst_context(ioc::IOContext, tc::TypstContext, _tc::TypstContext, value) = merge!(
    merge_contexts!(_tc, context),
    typst_context(ioc),
    ioc, tc, value
)
typst_context(ioc::IOContext, tc::TypstContext, value) = typst_context(
    ioc, tc, TypstContext(value), value
)
typst_context(io::IO, tc::TypstContext, value) = typst_context(IOContext(io), tc, value)
function typst_context(tc::TypstContext, value)
    _tc = TypstContext(value)
    typst_context(get(() -> context[:io], tc, :io), tc, _tc, value)
end

function _unwrap(dt::DataType, key::Symbol, value)
    value isa dt ? value : throw(ContextError(dt, typeof(value), key))
end

unwrap(x, key::Symbol, default) = _unwrap(typeof(default), key, get(x, key, default))
function unwrap(x, type::Type, key)
    value = x[key]
    _unwrap(type, key, value)
end

@doc """
    unwrap(x, key::Symbol, default)
    unwrap(x, type::Type, key)
""" unwrap
