
show_typst(io::IO, tc::TypstContext, x::AbstractArray) = math_mode(io, tc, x) do io, tc, x
    _depth, _indent = depth(tc), indent(tc)
    __depth = _depth + 1

    show_parameters(io, tc, "vec", [:delim, :align, :gap], true)
    print(io, _indent ^ __depth)
    join_with(io, x, ", ") do io, x
        show_typst(io, x; depth = __depth, mode = math, parenthesize = false)
    end
    print(io, '\n', _indent ^ _depth, ')')
end
show_typst(io::IO, ::TypstContext, x::AbstractChar) = show_typst(io, string(x))
function show_typst(io::IO, tc::TypstContext, x::AbstractFloat)
    if isinf(x)
        code_mode(io, tc)
        print(io, "float.inf")
    elseif isnan(x)
        code_mode(io, tc)
        print(io, "float.nan")
    else math_mode((io, _, x) -> print(io, x), io, tc, x)
    end
end
show_typst(io::IO, tc::TypstContext, x::AbstractMatrix) = math_mode(io, tc, x) do io, tc, x
    _depth, _indent = depth(tc), indent(tc)
    __depth = _depth + 1

    show_parameters(io, tc, "mat", [
        :delim, :align, :augment, :gap, :row_gap, :column_gap
    ], true)
    join_with(io, eachrow(x), ";\n") do io, x
        print(io, _indent ^ __depth)
        join_with(io, x, ", ") do io, x
            show_typst(io, x; depth = __depth, mode = math, parenthesize = false)
        end
    end
    print(io, '\n', _indent ^ _depth, ')')
end
function show_typst(io::IO, tc::TypstContext, x::AbstractString)
    mode(tc) == markup && print(io, '#')
    enclose((io, x) -> escape_string(io, x, '"'), io, x, '"')
end
function show_typst(io::IO, tc::TypstContext, x::Bool)
    code_mode(io, tc)
    print(io, x)
end
function show_typst(io::IO, tc::TypstContext, x::Complex{<:Union{
    AbstractFloat, AbstractIrrational, Rational{<:Signed}, Signed
}})
    _mode = mode(tc)
    math_mode(io, tc, x) do io, tc, x
        _real, _imag = real(x), imag(x)
        _parenthesize = parenthesize(tc) && !(iszero(_real) || iszero(_imag))
        enclose(io, x, (_mode == math && _parenthesize ? ("(", ")") : ("", ""))...) do io, x
            if iszero(_real) && !iszero(_imag)
                signbit(_imag) && print(io, '-')
                isone(abs(_imag)) || show_typst(io, abs(_imag))
                print(io, 'i')
            else
                show_typst(io, _real)

                if !iszero(_imag)
                    print(io, ' ', signbit(_imag) ? '-' : '+', ' ')
                    isone(abs(_imag)) || show_typst(io, abs(_imag))
                    print(io, 'i')
                end
            end
        end
    end
end
function show_typst(io::IO, ::TypstContext, x::Complex{<:Rational{<:Union{Bool, Unsigned}}})
    _real, _imag = real(x), imag(x)
    show_typst(io, Complex(
        signed(numerator(_real)) // signed(denominator(_real)),
        signed(numerator(_imag)) // signed(denominator(_imag))
    ))
end
show_typst(io::IO, ::TypstContext, x::Complex{<:Union{Bool, Unsigned}}) = show_typst(
    io, Complex(signed(real(x)), signed(imag(x)))
)
function show_typst(io::IO, typst_context::TypstContext, x::Expr)
    (; head, args) = x

    if head == :(=)
        math_mode(io, typst_context, args) do io, _, args
            show_typst(io, args[1])
            print(io, " = ")
            show_typst(io, args[2])
        end
    elseif head == :call show_typst(io, TypstFunction(args[1], Tuple(@view args[2:end])))
    elseif head == :hcat show_typst(io, permutedims(args))
    elseif head == :vect show_typst(io, args)
    elseif head == :vcat
        if all(arg -> arg isa Expr && arg.head == :row, args)
            show_typst(io, stack(Iterators.map(arg -> arg.args, args); dims = 1))
        else show_typst(io, args)
        end
    else error("`show_typst` is not yet implemented for an `Expr` with the head `$head`")
    end
end
show_typst(io::IO, tc::TypstContext, x::HTML) = show_raw(io, tc, MIME"text/html"(), :html, x)
show_typst(io::IO, tc::TypstContext, x::Irrational{T}) where T = math_mode(io, tc, x) do io, _, x
    if T isa Symbol && length(string(T)) == 1 print(io, x)
    else show_typst(io, string(x); mode = math)
    end
end
function show_typst(io::IO, typst_context::TypstContext, x::NamedTuple)
    _indent, _depth = indent(typst_context), depth(typst_context)
    next_depth = _depth + 1

    code_mode(io, typst_context)

    if isempty(x) print(io, "(:)")
    else
        enclose(io, x, "(\n", '\n' * _indent ^ _depth * ')') do io, x
            join_with(io, pairs(x), ",\n") do io, (key, value)
                print(io, _indent ^ next_depth)
                show_typst(io, string(key); depth = next_depth, mode = code)
                print(io, ": ")
                show_typst(io, value; depth = next_depth, mode = code)
            end
        end
    end
end
function show_typst(io::IO, tc::TypstContext, ::Nothing)
    code_mode(io, tc)
    print(io, "none")
end
function show_typst(io::IO, tc::TypstContext, x::Rational{<:Signed})
    _mode = mode(tc)
    math_mode(io, tc, x) do io, tc, x
        enclose(io, x, (_mode == math && parenthesize(tc) ? ("(", ")") : ("", ""))...) do io, x
            show_typst(io, numerator(x); mode = math)
            print(io, " / ")
            show_typst(io, denominator(x); mode = math)
        end
    end
end
show_typst(io::IO, ::TypstContext, x::Rational{<:Union{Bool, Unsigned}}) = show_typst(
    io, signed(numerator(x)) // signed(denominator(x))
)
function show_typst(io::IO, tc::TypstContext, x::Regex)
    code_mode(io, tc)
    enclose(io, x, "regex(", ')') do io, x
        buffer = IOBuffer()

        print(buffer, x)
        seek(buffer, 1)
        write(io, read(buffer))
    end
end
function show_typst(io::IO, tc::TypstContext, x::Signed)
    mode(tc) == code ? print(io, x) : enclose(print, io, x, math_pad(tc))
end
show_typst(io::IO, typst_context::TypstContext, x::Symbol) = math_mode(
    show_typst, io, typst_context, string(x)
)
function show_typst(io::IO, tc::TypstContext, x::Text)
    code_mode(io, tc)
    show_typst(io, string(x); mode = code)
end
function show_typst(io::IO, tc::TypstContext, x::Tuple)
    code_mode(io, tc)
    enclose(io, x, '(', ')') do io, x
        join_with(io, x, ", ") do io, x
            show_typst(io, x; parenthesize = false, mode = code)
        end

        if length(x) == 1 print(io, ',') end
    end
end
function show_typst(io::IO, tc::TypstContext, x::Unsigned)
    code_mode(io, tc)
    show(io, x)
end
function show_typst(io::IO, tc::TypstContext, x::VersionNumber)
    code_mode(io, tc)
    enclose(io, x, "version(", ')') do io, x
        join_with(print, io, eachsplit(string(x), '.'), ", ")
    end
end
function show_typst(io::IO, tc::TypstContext, x::Union{Date, DateTime, Period, Time})
    f, keys, values = dates(x)
    _values = map(value -> TypstString(value; mode = code), values)
    _tc = merge!(copy(tc), Dict(zip(keys, _values)))

    code_mode(io, tc)
    show_parameters(io, _tc, f, keys, false)
    print(io, indent(tc) ^ depth(tc), ')')
end
function show_typst(io::IO, tc::TypstContext, x::Union{
    OrdinalRange{<:Signed, <:Signed},
    StepRangeLen{<:Signed, <:Signed, <:Signed, <:Signed}
})
    code_mode(io, tc)
    enclose(io, x, "range(", ')') do io, x
        _step = step(x)

        show_typst(io, first(x); mode = code)
        print(io, ", ")
        show_typst(io, last(x) + 1; mode = code)

        if _step ≠ 1
            print(io, ", step: ")
            show_typst(io, _step; mode = code)
        end
    end
end
show_typst(io::IO, ::TypstContext, x::Union{
    OrdinalRange{<:Integer, <:Integer},
    StepRangeLen{<:Integer, <:Integer, <:Integer, <:Integer}
}) = show_typst(io, signed(first(x)):signed(step(x)):signed(last(x)))
function show_typst(io::IO, ::TypstContext, x)
    if showable(MIME"text/typst"(), x) show(io, MIME"text/typst"(), x)
    elseif showable(MIME"image/gif"(), x) show_image(io, MIME"image/gif"(), x)
    elseif showable(MIME"image/svg+xml"(), x) show_image(io, MIME"image/svg+xml"(), x)
    elseif showable(MIME"image/png"(), x) show_image(io, MIME"image/png"(), x)
    elseif showable(MIME"image/jpg"(), x) show_image(io, MIME"image/jpg"(), x)
    else show_typst(io, repr(x))
    end
end
show_typst(tc::TypstContext, x) = show_typst(typst_context(tc, x)...)
show_typst(io::IO, x; context...) = show_typst(typst_context(io, TypstContext(; context...), x)...)
show_typst(x; context...) = show_typst(typst_context(TypstContext(; context...), x)...)

@doc """
    show_typst(::IO, ::TypstContext, ::Any)::Nothing
    show_typst(::IO, ::Any; context...)::Nothing
    show_typst(::TypstContext, ::Any)::Nothing
    show_typst(::Any; context...)::Nothing

Print in Typst format with Julia settings and Typst
parameters provided by the [`TypstContext`](@ref).

Implement the three-parameter form of this function
for a custom type to specify its Typst formatting.
A setting is a value used in Julia, whose type varies across settings.
A parameter is passed directly to a Typst function and must be a [`TypstString`](@ref)
with the same name as in Typst, except that dashes are replaced with underscores.
Some settings, such as `block`, correspond with a parameter but may also be used in Julia.

See also the [Typst Formatting Examples](@ref).

!!! tip
    Please create an issue or pull-request to implement new methods.
""" show_typst
