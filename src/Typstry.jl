
module Typstry

import Base:
    IOBuffer, ==, addenv, codeunit, convert, detach, eltype, firstindex,
    getindex, hash, ignorestatus, isvalid, iterate, keys, lastindex,
    length, ncodeunits, pointer, run, setenv, show, showerror
using Artifacts: @artifact_str
using Base: Docs.Text, Iterators.Stateful, Meta.parse, escape_raw_string
using PrecompileTools: PrecompileTools, @compile_workload
using Typst_jll: typst

@static isdefined(Base, :setcpuaffinity) && import Base: setcpuaffinity

include("commands.jl")

export TypstCommand, TypstError, @typst_cmd

include("strings.jl")

export Mode, TypstString, @typst_str, julia_mono, code, markup, math, show_typst, typst_text

@compile_workload for (x, _) in examples
    typst"\(x)"
end

end # module
