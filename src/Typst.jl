
module Typst

import Base: show, ncodeunits, iterate, getindex, isvalid
using Typst_jll

struct TypstString <: AbstractString
    s::String
end

function show(io::IO, ts::TypstString)
    print(io, "T")
    show(io, ts.s)
end

ncodeunits(t::TypstString) = ncodeunits(t.s)
iterate(t::TypstString) = iterate(t.s)
iterate(t::TypstString, state::Integer) = iterate(t.s, state)
isvalid(t::TypstString, i::Integer) = Base.isvalid(t.s, i)

export TypstString

end # module Typst
