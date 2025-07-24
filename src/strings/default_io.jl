
struct DefaultIO end

(::DefaultIO)() = IOContext(stdout, :compact => true)

function show(io::IO, ::DefaultIO)
    print(io, "(() -> ")
    show(io, IOContext)
    print(io, "(stdout, :compact => true))::")
    show(io, DefaultIO)
end
