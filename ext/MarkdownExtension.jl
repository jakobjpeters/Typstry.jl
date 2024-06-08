
module MarkdownExtension

import Typstry: show_typst
using Base: Iterators.Stateful
using Markdown: MD
using Typstry: show_raw

show_typst(io, x::MD) = show_raw(io, x, "markdown") do io, x
    buffer = IOBuffer()

    print(buffer, x)
    seekstart(buffer)

    characters = Stateful(readeach(buffer, Char))

    for character in characters
        isempty(characters) || print(io, character)
    end
end

end # module
