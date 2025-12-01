
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
"""
compile_workload(examples::Vector) = @compile_workload for example ∈ examples
    render(first(example); open=false)
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
function enclose(f, io::IO, x, left, right = reverse(string(left)); context...)
    print(io, left)
    f(io, x; context...)
    print(io, right)
end

"""
    join_with(callback, io, values, delimeter; keyword_parameters...)

Similar to `join`, except printing with `callback(io, value; keyword_parameters...)`.

# Examples

```jldoctest
julia> Typstry.join_with((io, i; x) -> print(io, -i, x), stdout, 1:4, ", "; x = "x")
-1x, -2x, -3x, -4x
```
"""
function join_with(callback, io::IO, values, delimeter; kwargs...)
    stateful_values = Stateful(values)

    for stateful_value in stateful_values
        callback(io, stateful_value; kwargs...)
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
typst_context(ioc::IOContext) = unwrap(ioc, :typst_context, TypstContext())
typst_context(::IO) = TypstContext()

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
