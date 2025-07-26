
module MarkdownExtension

import Typstry: show_typst
using Markdown: MD, @md_str
using Typstry: TypstContext, compile_workload, show_raw

"""
    show_typst(::IO, ::TypstContext, ::Markdown.MD)

Print a raw text block in Typst format.

See also [`TypstContext`](@ref Typstry.TypstContext).

| Type          | Settings                                 | Parameters |
|:--------------|:-----------------------------------------|:-----------|
| `Markdown.MD` | `:block`, `:depth`, `:mode`, `:tab_size` |            |
"""
show_typst(io::IO, tc::TypstContext, x::MD) = show_raw(io, tc, x, "markdown") do _io, x
    buffer = IOBuffer()

    print(buffer, x)
    seekstart(buffer)

    print(_io, read(buffer, String)[begin:(end - 1)])
end

const examples = [md"# A" => MD]

compile_workload(examples)

end # module
