
module MarkdownExtension

import Typstry: show_typst
using Markdown: MD, @md_str
using Typstry: compile_workload, show_raw

# Strings

"""
    show_typst(io, ::Markdown.MD)

Print in Typst format for Markdown.jl.

| Type          | Settings                                 | Parameters |
|:--------------|:-----------------------------------------|:-----------|
| `Markdown.MD` | `:block`, `:depth`, `:mode`, `:tab_size` |            |
"""
show_typst(io, tc, x::MD) = show_raw(io, tc, x, "markdown") do io, x
    buffer = IOBuffer()

    print(buffer, x)
    seekstart(buffer)

    print(io, read(buffer, String)[begin:end - 1])
end

# Internals

const examples = [md"# A" => MD]

compile_workload(examples)

end # module
