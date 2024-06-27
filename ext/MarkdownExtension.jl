
module MarkdownExtension

import Typstry: show_typst
using DispatchDoctor: @stable
using Markdown: MD, @md_str
using PrecompileTools: @compile_workload
using Typstry: show_raw, workload

@stable begin

# Strings

"""
    show_typst(io, ::Markdown.MD)

Print in Typst format for Markdown.jl.

| Type          | Settings                                 | Parameters |
|:--------------|:-----------------------------------------|:-----------|
| `Markdown.MD` | `:block`, `:depth`, `:mode`, `:tab_size` |            |
"""
show_typst(io, x::MD) = show_raw(io, x, "markdown") do io, x
    buffer = IOBuffer()

    print(buffer, x)
    seekstart(buffer)

    print(io, read(buffer, String)[begin:end - 1])
end

# Internals

const examples = [md"# A" => MD]

@compile_workload workload(examples)

end # @stable

end # module
