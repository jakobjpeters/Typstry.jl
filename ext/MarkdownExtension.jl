
module MarkdownExtension

import Typstry: show_typst
using Markdown: MD, @md_str
using Typstry: TypstContext, Precompile.compile_workload, Strings.Utilities.show_raw

show_typst(io::IO, tc::TypstContext, x::MD) = show_raw(io, tc, MIME"text/markdown"(), :markdown, x)

const examples = []

function __init__()
    append!(examples, [
        md"# A" => MD => [:block, :depth, :lang, :align, :syntaxes, :theme, :tab_size]
    ])
    compile_workload(examples)
end

end # module
