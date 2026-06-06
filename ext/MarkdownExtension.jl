
module MarkdownExtension

import Typstry: lower

using Markdown: MD, @md_str
using Typstry: TypstRaw, Precompile.compile_workload
using Typstry

lower(markdown::MD) = TypstRaw(MIME"text/markdown"(), :markdown, markdown)

const examples = []

function __init__()
    push!(examples, md"# A" => MD => [
        :block, :depth, :lang, :align, :syntaxes, :theme, :tab_size
    ])
    compile_workload(examples)
end

end # module
