
using Logging, CairoMakie, Typstry
disable_logging(Warn)
using MakieTeX
disable_logging(Debug)
f = Figure(; size = (100, 100))
LTeX(f[1, 1], TypstDocument(typst"\(preamble)$ 1 / x $"); scale = 2)
save("makie_tex.svg", f)
