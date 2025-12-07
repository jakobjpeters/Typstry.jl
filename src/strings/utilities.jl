
code_mode(io::IO, tc) = if mode(tc) ≠ code print(io, "#") end

function dates(date_time::DateTime)
    fs = (year, month, day, hour, minute, second)
    :datetime, map(Symbol, fs), map(f -> f(date_time), fs)
end
dates(date::Date) = :datetime, (:year, :month, :day), (year(date), month(date), day(date))
function dates(x::Period)
    io_buffer = IOBuffer()

    print(io_buffer, x)
    seekstart(io_buffer)

    :duration, (duration(x),), (TypstText(readuntil(io_buffer, ' ')),)
end
dates(time::Time) = :datetime, (:hour, :minute, :second), (hour(time), minute(time), second(time))

duration(::Day) = :days
duration(::Hour) = :hours
duration(::Minute) = :minutes
duration(::Second) = :seconds
duration(::Week) = :weeks

"""
    escape(io::IO, count::Int)

Print `\\` to `io` `count` times.

# Examples

```jldoctest
julia> Typstry.escape(stdout, 1)
\\

julia> Typstry.escape(stdout, 2)
\\\\
```
"""
escape(io::IO, count::Int) = join(io, repeated('\\', count))

format(::MIME"application/pdf") = "pdf"
format(::MIME"image/gif") = "gif"
format(::MIME"image/jpg") = "jpg"
format(::MIME"image/png") = "png"
format(::MIME"image/svg+xml") = "svg"
format(::MIME"image/webp") = "webp"

@doc """
    format(::Union{
        MIME"application/pdf",
        MIME"image/gif",
        MIME"image/jpg",
        MIME"image/png",
        MIME"image/svg+xml",
        MIME"image/webp"
    })

Return the image format acronym corresponding to the given `MIME`.

# Examples

```jldoctest
julia> Typstry.format(MIME"application/pdf"())
"pdf"

julia> Typstry.format(MIME"image/png"())
"png"

julia> Typstry.format(MIME"image/svg+xml"())
"svg"
```
""" format

function math_mode(f, io::IO, tc, x; kwargs...)
    _tc = setindex!(copy(tc), math, :mode)
    _io = IOContext(io, :typst_context => _tc)

    enclose((io, x; kwargs...) -> f(_io, _tc, x; kwargs...), _io, x, math_pad(tc); kwargs...)
end

function math_pad(typst_context::TypstContext)
    if mode(typst_context) == math ""
    else block(typst_context) ? "\$ " : "\$"
    end
end

show_parameters(
    io::IO, typst_context::TypstContext, callable, x, keys::Vector{Symbol}
) = show_typst(io, TypstFunction(typst_context, callable, x...; Iterators.map(
    Iterators.filter(key -> haskey(typst_context, key), keys)
) do key
    key => typst_context[key]
end...))

function show_image(io::IO, mime::Union{
    MIME"image/gif", MIME"image/svg+xml", MIME"image/png", MIME"image/jpg", MIME"image/webp"
}, value)
    _typst_context = typst_context(io, value)[2]
    path = tempname() * '.' * format(mime)

    open(path; write = true) do file
        show(IOContext(file, _typst_context), mime, value)
    end

    show_parameters(io, _typst_context, TypstString(TypstText(:image)), (path,), [
        :alt, :fit, :format, :height, :icc, :page, :scaling, :width
    ])
end

show_raw(io::IO, typst_context::TypstContext, mime::MIME, language::Symbol, x) = show_parameters(
    io,
    setindex!(typst_context, string(language), :lang),
    TypstString(TypstText(:raw)),
    (show_raw(io, mime, x),),
    [:block, :lang, :align, :syntaxes, :theme]
)
show_raw(context::IO, mime::MIME"text/markdown", value) = @view sprint(
    show, mime, value; context
)[begin:(end - 1)]
show_raw(context::IO, mime::MIME, value) = sprint(show, mime, value; context)

function show_render(io::IO, mime::Union{
    MIME"application/pdf", MIME"image/png", MIME"image/svg+xml"
}, value)
    io_buffer = IOBuffer()
    typst_command = TypstCommand([
        "compile", "--font-path", julia_mono, "--format", format(mime), "-", "-"
    ])
    _typst_context = typst_context(io, value)[2]

    print(io_buffer, preamble(_typst_context))
    show_typst(io_buffer, _typst_context, value)
    println(io_buffer)

    seekstart(io_buffer)
    run_typst(command -> pipeline(command; stdin = io_buffer, stdout = io), typst_command)
    nothing
end
