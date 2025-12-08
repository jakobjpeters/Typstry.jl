
module Strings

using Typstry: Contexts.TypstContexts, TypstContext, Utilities.unwrap
using .TypstContexts: TypstContext, context, reset_context

include("AbstractTypsts.jl")
using .AbstractTypsts: AbstractTypst
export AbstractTypst

include("Utilities.jl")
using .Utilities: typst_context

show_typst(io::IO, value; context...) = show_typst(
    typst_context(io, TypstContext(; context...), value)...
)
export show_typst

include("Modes.jl")
using .Modes: Mode, code, markup, math
export Mode, code, markup, math

include("TypstTexts.jl")
using .TypstTexts: TypstText
export TypstText

include("TypstStrings.jl")
using .TypstStrings: TypstString, @typst_str
export TypstString, @typst_str

include("Typsts.jl")
using .Typsts: Typst
export Typst

include("ShowTypst.jl")
include("Dates.jl")

reset_context()

for (key, value) in pairs(context)
    @eval begin
        $key(tc) = unwrap(tc, $(typeof(value)), $(QuoteNode(key)))
    end
end

include("TypstFunctions.jl")
using .TypstFunctions: TypstFunction
export TypstFunction

module Interface

import Base: repr, show

using ..Strings: AbstractTypst, TypstString, TypstText, show_typst

repr(mime::MIME"text/typst", typst::AbstractTypst; context = nothing) = TypstString(
    TypstText(sprint(show, mime, typst; context))
)

show(io::IO, ::MIME"text/typst", typst::AbstractTypst) = show_typst(io, typst)

end # ToDo

end # Strings
