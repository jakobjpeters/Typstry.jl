
module Typstry

import Base: *, addenv, detach, ignorestatus, run, setcpuaffinity, setenv, show
using Base: Docs.Text, Iterators.Stateful, Meta.parse
using Typst_jll: typst

include("commands.jl")

export TypstCommand, @typst_cmd, render

include("strings.jl")

export Mode, TypstString, @typst_str, code, markup, math, print_typst, format

end # module
