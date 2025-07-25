
include("utilities.jl")
include("default_io.jl")
include("mode.jl")
include("show_typst.jl")
include("typst_text.jl")
include("typst.jl")
include("typst_string.jl")

merge!(default_context, TypstContext(;
    backticks = 3,
    block = false,
    depth = 0,
    io = DefaultIO(),
    mode = markup,
    parenthesize = true,
    preamble = TypstString(TypstText(
        "#set page(margin: 1em, height: auto, width: auto, fill: white)\n#set text(16pt, font: \"JuliaMono\")\n"
    )),
    tab_size = 2
))
reset_context()

for (key, value) in pairs(context)
    @eval begin
        $key(tc) = unwrap(tc, $(typeof(value)), $(QuoteNode(key)))
        @doc "$($key)(tc, type, key)" $key
    end
end
