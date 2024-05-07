
# Strings

"""
    *(::TypstString, ::TypstString)
"""
x::TypstString * y::TypstString = TypstString(x.text * y.text)

"""
    show(::IO, ::TypstString)
"""
function show(io::IO, ts::TypstString)
    print(io, "typst")
    escape_quote(io, ts.text)
end

for f in (:IOBuffer, :codeunit, :iterate, :ncodeunits, :pointer)
    @eval begin
        "\t$($f)(::TypstString)"
        $f(ts::TypstString) = $f(ts.text)
    end
end

for f in (:codeunit, :isvalid, :iterate)
    @eval begin
        "\t$($f)(::TypstString, ::Integer)"
        $f(ts::TypstString, i::Integer) = $f(ts.text, i)
    end
end

# Commands

"""
    addenv(::TypstCommand, args...; kwargs...)
"""
addenv(tc::TypstCommand, args...; kwargs...) =
    TypstCommand(addenv(tc.typst, args...; kwargs...), tc.parameters)

"""
    detach(::TypstCommand)
"""
detach(tc::TypstCommand) =
    TypstCommand(detach(tc.typst), tc.parameters)

"""
    ignorestatus(::TypstCommand)
"""
ignorestatus(tc::TypstCommand) =
    TypstCommand(ignorestatus(tc.typst), tc.parameters)

"""
    run(::TypstCommand, args...; kwargs...)
"""
run(tc::TypstCommand, args...; kwargs...) =
    run(Cmd(`$(tc.typst) $(tc.parameters)`), args...; kwargs...)

"""
    setcpuaffinity(::TypstCommand, cpus)
"""
setcpuaffinity(tc::TypstCommand, cpus) =
    TypstCommand(setcpuaffinity(tc.typst, cpus), tc.parameters)

"""
    setenv(::TypstCommand, env; kwargs...)
"""
setenv(tc::TypstCommand, env; kwargs...) =
    TypstCommand(setenv(tc.typst, env; kwargs...), tc.parameters)

"""
    show(::IO, ::TypstCommand)
"""
show(io::IO, tc::TypstCommand) = print(io, "typst", tc.parameters)
