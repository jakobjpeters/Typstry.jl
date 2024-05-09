
module Typstry

import Base:
    IOBuffer, addenv, codeunit, detach, ignorestatus, isvalid,
    iterate, ncodeunits, pointer, run, setenv, show
using Base: Docs.Text, Iterators.Stateful, Meta.parse, escape_raw_string
using PrecompileTools: @compile_workload
using Typst_jll: typst

@static isdefined(Base, :setcpuaffinity) && import Base: setcpuaffinity

include("commands.jl")

export TypstCommand, @typst_cmd

include("strings.jl")

export Mode, TypstString, TypstText, @typst_str, code, markup, math, show_typst

@compile_workload redirect_stdout(devnull) do
    for (x, _) in examples
         show(stdout, typst_mime, x)
    end
end

end # module
