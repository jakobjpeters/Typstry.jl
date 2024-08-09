
using Typstry: @typst_str, julia_mono, preamble

const ts = typst"""
\(preamble)#import "@preview/jlyfish:0.1.0": *
#read-julia-output(json("typst_jlyfish.json"))
#jl-pkg("Typstry")
#jl(`using Typstry; typst"$1 / x$"`)
"""

const _using, compile = [
    "using TypstJlyfish, Typstry",
    "TypstJlyfish.compile(\"typst_jlyfish.typ\";\n           evaluation_file = \"typst_jlyfish.json\",\n           typst_compile_args = \"--format=svg --font-path=\$julia_mono\"\n       )"
]

write("typst_jlyfish.typ", ts)
eval(Meta.parse(_using))
redirect_stderr(() -> eval(Meta.parse(compile)), devnull)
