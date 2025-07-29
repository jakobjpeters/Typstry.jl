
module MarkdownExtension

import Typstry: show_typst
using Markdown: MD, @md_str
using Typstry: TypstContext, compile_workload, show_raw

show_typst(io::IO, tc::TypstContext, x::MD) = show_raw(io, tc, MIME"text/markdown"(), :markdown, x)

const examples = [md"# A" => MD => [:backticks, :block, :depth, :indent, :mode]]

compile_workload(examples)

end # module
