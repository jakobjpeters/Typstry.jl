var documenterSearchIndex = {"docs":
[{"location":"manual/internals/#Internals","page":"Internals","title":"Internals","text":"","category":"section"},{"location":"manual/internals/#Strings","page":"Internals","title":"Strings","text":"","category":"section"},{"location":"manual/internals/","page":"Internals","title":"Internals","text":"Typstry.TypstText\nTypstry.examples\nTypstry.preamble\nTypstry.settings\nTypstry.typst_mime\nTypstry.code_mode\nTypstry.depth\nTypstry.enclose\nTypstry.format\nTypstry.indent\nTypstry.inline\nTypstry.join_with\nTypstry.math_pad\nTypstry.mode\nTypstry.print_parameters\nTypstry.print_quoted\nTypstry.show_image\nTypstry.static_parse","category":"page"},{"location":"manual/internals/#Typstry.TypstText","page":"Internals","title":"Typstry.TypstText","text":"TypstText(::Any)\n\nA wrapper used to construct a TypstString with print instead of show(::IO, ::MIME\"text/typst\", ::Any).\n\nExamples\n\njulia> Typstry.TypstText(\"a\")\nTypstry.TypstText(\"a\")\n\njulia> Typstry.TypstText([1, 2, 3, 4])\nTypstry.TypstText(\"[1, 2, 3, 4]\")\n\n\n\n\n\n","category":"type"},{"location":"manual/internals/#Typstry.examples","page":"Internals","title":"Typstry.examples","text":"examples\n\nA constant Vector of Julia values and their corresponding Types implemented for show(::IO, ::MIME\"text/plain\", ::Any).\n\nExamples\n\njulia> Typstry.examples\n16-element Vector{Pair{Any, Type}}:\n                                       'a' => AbstractChar\n                                       1.2 => AbstractFloat\n Any[true 1; 1.0 Any[true 1; 1.0 nothing]] => AbstractMatrix\n                                       \"a\" => AbstractString\n                            Any[true, [1]] => AbstractVector\n                                      true => Bool\n                                   1 + 2im => Complex\n                                         π => Irrational\n                                   nothing => Nothing\n                                     0:2:6 => OrdinalRange{<:Integer, <:Integer}\n                                      1//2 => Rational\n                                  r\"[a-z]\" => Regex\n                                         1 => Signed\n                                     0:2:6 => StepRangeLen{<:Integer, <:Integer, <:Integer}\n                                     [\"a\"] => Text\n                            typst\"[\\\"a\\\"]\" => TypstString\n\n\n\n\n\n","category":"constant"},{"location":"manual/internals/#Typstry.preamble","page":"Internals","title":"Typstry.preamble","text":"preamble\n\nExamples\n\njulia> print(Typstry.preamble)\n#set page(margin: 1em, height: auto, width: auto, fill: white)\n#set text(16pt, font: \"JuliaMono\")\n\n\n\n\n\n","category":"constant"},{"location":"manual/internals/#Typstry.settings","page":"Internals","title":"Typstry.settings","text":"settings\n\nA constant NamedTuple containing the default IOContext settings for show(::IO, ::MIME\"text/typst\", ::Any).\n\nExamples\n\njulia> Typstry.settings\n(mode = markup, inline = true, indent = \"    \", depth = 0)\n\n\n\n\n\n","category":"constant"},{"location":"manual/internals/#Typstry.typst_mime","page":"Internals","title":"Typstry.typst_mime","text":"typst_mime\n\nExamples\n\njulia> Typstry.typst_mime\nMIME type text/typst\n\n\n\n\n\n","category":"constant"},{"location":"manual/internals/#Typstry.code_mode","page":"Internals","title":"Typstry.code_mode","text":"code_mode(io)\n\nPrint the number sign, unless mode(io) == code.\n\nSee also Mode and mode.\n\nExamples\n\njulia> Typstry.code_mode(IOContext(stdout, :mode => code))\n\njulia> Typstry.code_mode(IOContext(stdout, :mode => markup))\n#\n\njulia> Typstry.code_mode(IOContext(stdout, :mode => math))\n#\n\n\n\n\n\n","category":"function"},{"location":"manual/internals/#Typstry.depth","page":"Internals","title":"Typstry.depth","text":"depth(io)\n\nReturn io[:depth]::Int.\n\nExamples\n\njulia> Typstry.depth(IOContext(stdout, :depth => 0))\n0\n\n\n\n\n\n","category":"function"},{"location":"manual/internals/#Typstry.enclose","page":"Internals","title":"Typstry.enclose","text":"enclose(f, io, x, left, right = reverse(left); settings...)\n\nCall f(io, x; settings...) between printing left and right, respectfully.\n\nExamples\n\njulia> Typstry.enclose((io, i; x) -> print(io, i, x), stdout, 1, \"\\$ \"; x = \"x\")\n$ 1x $\n\n\n\n\n\n","category":"function"},{"location":"manual/internals/#Typstry.format","page":"Internals","title":"Typstry.format","text":"format(::Union{MIME\"image/png\", MIME\"image/svg+xml})\n\nExamples\n\njulia> Typstry.format(MIME\"image/png\"())\n\"png\"\n\njulia> Typstry.format(MIME\"image/svg+xml\"())\n\"svg\"\n\n\n\n\n\n","category":"function"},{"location":"manual/internals/#Typstry.indent","page":"Internals","title":"Typstry.indent","text":"indent(io)\n\nReturn io[:indent]::String.\n\nExamples\n\njulia> Typstry.indent(IOContext(stdout, :indent => ' ' ^ 4))\n\"    \"\n\n\n\n\n\n","category":"function"},{"location":"manual/internals/#Typstry.inline","page":"Internals","title":"Typstry.inline","text":"inline(io)\n\nReturn io[:inline]::Bool.\n\nExamples\n\njulia> Typstry.inline(IOContext(stdout, :inline => true))\ntrue\n\n\n\n\n\n","category":"function"},{"location":"manual/internals/#Typstry.join_with","page":"Internals","title":"Typstry.join_with","text":"join_with(f, io, xs, delimeter; settings...)\n\nSimilar to join, except printing with f(io, x; settings...).\n\nExamples\n\njulia> Typstry.join_with((io, i; x) -> print(io, -i, x), stdout, 1:4, \", \"; x = \"x\")\n-1x, -2x, -3x, -4x\n\n\n\n\n\n","category":"function"},{"location":"manual/internals/#Typstry.math_pad","page":"Internals","title":"Typstry.math_pad","text":"math_pad(io, x)\n\nReturn \"\", \"\\$\", or \"\\$ \" depending on the mode and inline settings.\n\nExamples\n\njulia> Typstry.math_pad(IOContext(stdout, :mode => math))\n\"\"\n\njulia> Typstry.math_pad(IOContext(stdout, :mode => markup, :inline => true))\n\"\\$\"\n\njulia> Typstry.math_pad(IOContext(stdout, :mode => markup, :inline => false))\n\"\\$ \"\n\n\n\n\n\n","category":"function"},{"location":"manual/internals/#Typstry.mode","page":"Internals","title":"Typstry.mode","text":"mode(io)\n\nReturn io[:mode]::Mode.\n\nSee also Mode.\n\nExamples\n\njulia> Typstry.mode(IOContext(stdout, :mode => code))\ncode::Mode = 0\n\n\n\n\n\n","category":"function"},{"location":"manual/internals/#Typstry.print_parameters","page":"Internals","title":"Typstry.print_parameters","text":"print_parameters(io, f, keys)\n\nPrint the name of a Typst function, an opening parenthesis, the parameters to a Typst function, and a newline.\n\nSkip keys that are not in the IOContext.\n\nExamples\n\njulia> Typstry.print_parameters(\n           IOContext(stdout, :delim => \"\\\"(\\\"\"),\n       \"vec\", [:delim, :gap])\nvec(delim: \"(\",\n\n\n\n\n\n","category":"function"},{"location":"manual/internals/#Typstry.print_quoted","page":"Internals","title":"Typstry.print_quoted","text":"print_quoted(io, s)\n\nPrint the string enclosed in quotes and with interior quotes escaped.\n\nExamples\n\njulia> Typstry.print_quoted(stdout, TypstString(\"a\"))\n\"\\\"a\\\"\"\n\n\n\n\n\n","category":"function"},{"location":"manual/internals/#Typstry.show_image","page":"Internals","title":"Typstry.show_image","text":"show_image(io, m, t)\n\n\n\n\n\n","category":"function"},{"location":"manual/internals/#Typstry.static_parse","page":"Internals","title":"Typstry.static_parse","text":"static_parse(args...; filename, kwargs...)\n\nCall Meta.parse with the filename if it is supported in the current Julia version (at least v1.10).\n\n\n\n\n\n","category":"function"},{"location":"manual/internals/#Commands","page":"Internals","title":"Commands","text":"","category":"section"},{"location":"manual/internals/","page":"Internals","title":"Internals","text":"Typstry.typst_program\nTypstry.apply","category":"page"},{"location":"manual/internals/#Typstry.typst_program","page":"Internals","title":"Typstry.typst_program","text":"typst_program\n\nA constant Cmd that is the Typst compiler given by Typst_jll.jl with no additional parameters.\n\n\n\n\n\n","category":"constant"},{"location":"manual/internals/#Typstry.apply","page":"Internals","title":"Typstry.apply","text":"apply(f, tc, args...; kwargs...)\n\n\n\n\n\n","category":"function"},{"location":"getting_started/#Getting-Started","page":"Getting Started","title":"Getting Started","text":"","category":"section"},{"location":"getting_started/#Examples","page":"Getting Started","title":"Examples","text":"","category":"section"},{"location":"getting_started/","page":"Getting Started","title":"Getting Started","text":"This Typst source file and corresponding document were generated from Julia using \nshow(::IO, ::MIME\"text/typst\", ::Any) to print Julia values to a Typst source file and a TypstCommand to render that file.","category":"page"},{"location":"getting_started/","page":"Getting Started","title":"Getting Started","text":"A Mode specifies the current Typst context. The formatting of each type corresponds to the most useful Typst value for the given mode. If no such value exists, it is formatted to render in a canonical representation.","category":"page"},{"location":"getting_started/","page":"Getting Started","title":"Getting Started","text":"note: Note\nAlthough many of the values are rendered similarly across modes, the underlying Typst source code differs between them.","category":"page"},{"location":"getting_started/","page":"Getting Started","title":"Getting Started","text":"using Markdown: parse\nparse(\"```typst\\n\" * read(\"assets/strings.typ\", String) * \"\\n```\")","category":"page"},{"location":"getting_started/","page":"Getting Started","title":"Getting Started","text":"(Image: )","category":"page"},{"location":"manual/strings/#Strings","page":"Strings","title":"Strings","text":"","category":"section"},{"location":"manual/strings/#Typstry","page":"Strings","title":"Typstry","text":"","category":"section"},{"location":"manual/strings/","page":"Strings","title":"Strings","text":"Mode\nTypstString\n@typst_str\nshow_typst\ntypst_text","category":"page"},{"location":"manual/strings/#Typstry.Mode","page":"Strings","title":"Typstry.Mode","text":"Mode\n\nAn Enumerated type used to specify that the current Typst context is in code, markup, or math mode.\n\njulia> Mode\nEnum Mode:\ncode = 0\nmarkup = 1\nmath = 2\n\n\n\n\n\n","category":"type"},{"location":"manual/strings/#Typstry.TypstString","page":"Strings","title":"Typstry.TypstString","text":"TypstString <: AbstractString\nTypstString(::Any, ::Pair{Symbol}...)\n\nConvert the value to a Typst formatted string.\n\nOptional Julia settings and Typst parameters are passed to show(::IO, ::MIME\"text/typst\", ::Any) in an IOContext. See also show_typst for a list of supported types.\n\ninfo: Info\nThis type implements the String interface. However, the interface is unspecified which may result unexpected behavior.\n\nExamples\n\njulia> TypstString(\"a\")\ntypst\"\\\"a\\\"\"\n\njulia> TypstString(\"a\", :mode => code)\ntypst\"\\\"\\\\\\\"a\\\\\\\"\\\"\"\n\n\n\n\n\n","category":"type"},{"location":"manual/strings/#Typstry.@typst_str","page":"Strings","title":"Typstry.@typst_str","text":"@typst_str(s)\ntypst\"s\"\n\nConstruct a TypstString.\n\nControl characters are escaped, except quotation marks and backslashes in the same manner as @raw_str. TypstStrings containing control characters may be created using typst_text. Values may be interpolated by calling the TypstString constructor, except using a backslash instead of the type name.\n\ntip: Tip\nUse show(::IO, ::MIME\"text/typst\", ::Any) to print directly to an IO.See also the performance tip to Avoid string interpolation for I/O.\n\nExamples\n\njulia> x = 1;\n\njulia> typst\"$\\(x) / \\(x + 1)$\"\ntypst\"$1 / 2$\"\n\njulia> typst\"\\(x // 2)\"\ntypst\"$1 / 2$\"\n\njulia> typst\"\\(x // 2, :mode => math)\"\ntypst\"1 / 2\"\n\njulia> typst\"\\\\(x)\"\ntypst\"\\\\(x)\"\n\n\n\n\n\n","category":"macro"},{"location":"manual/strings/#Typstry.show_typst","page":"Strings","title":"Typstry.show_typst","text":"show_typst(io, x)\n\nPrint to Typst format using required settings and parameters in the IOContext.\n\nSettings are used in Julia to format the TypstString and can be any type. Parameters are passed to a function in the Typst source file and must be a String with the same name as in Typst, except that dashes are replaced with underscores.\n\nFor more information on parameters and settings, see also show(::IO, ::MIME\"text/typst\", ::Any) and the Typst Documentation, respectively.\n\nFor more information on printing and rendering, see also Examples.\n\ntip: Tip\nImplement this function for new types to specify their Typst formatting.\n\nwarning: Warning\nThis function's methods are incomplete. Please file an issue or create a pull-request for missing methods.\n\nType Settings Parameters\nAbstractChar :mode \nAbstractFloat  \nAbstractMatrix :mode, :inline, :indent, :depth :delim, :augment, :gap, :row_gap, :column_gap\nAbstractString :mode \nAbstractVector :mode, :inline, :indent, :depth :delim, :gap\nBool :mode \nComplex :mode, :inline \nIrrational :mode \nNothing :mode \nOrdinalRange{<:Integer, <:Integer} :mode \nRational :mode, :inline \nRegex :mode \nSigned  \nStepRangeLen{<:Integer, <:Integer, <:Integer} :mode \nText :mode \nTypstString  \n\nExamples\n\njulia> show_typst(stdout, 1)\n1\n\njulia> show_typst(IOContext(stdout, :mode => code), \"a\")\n\"\\\"a\\\"\"\n\n\n\n\n\n","category":"function"},{"location":"manual/strings/#Typstry.typst_text","page":"Strings","title":"Typstry.typst_text","text":"typst_text(::Any)\n\nConstruct a TypstString using print instead of show(::IO, ::MIME\"text/typst\", ::Any).\n\ntip: Tip\nUse typst_text to print text to a TypstString. Use Text to render the text in a Typst document.\n\nwarning: Warning\nUnescaped control characters in TypstStrings may break formatting in some environments such as the REPL.\n\nExamples\n\njulia> typst_text(\"a\")\ntypst\"a\"\n\njulia> typst_text([1, 2, 3, 4])\ntypst\"[1, 2, 3, 4]\"\n\n\n\n\n\n","category":"function"},{"location":"manual/strings/#Base","page":"Strings","title":"Base","text":"","category":"section"},{"location":"manual/strings/","page":"Strings","title":"Strings","text":"IOBuffer\ncodeunit\nisvalid\niterate\nncodeunits\npointer\nshow(::IO, ::MIME\"text/typst\", ::Any)\nshow(::IO, ::Union{MIME\"image/png\", MIME\"image/svg+xml\"}, ::TypstString)\nshow(::IO, ::TypstString)","category":"page"},{"location":"manual/strings/#Base.IOBuffer","page":"Strings","title":"Base.IOBuffer","text":"IOBuffer(::TypstString)\n\nSee also TypstString.\n\nExamples\n\njulia> IOBuffer(typst\"a\")\nIOBuffer(data=UInt8[...], readable=true, writable=false, seekable=true, append=false, size=1, maxsize=Inf, ptr=1, mark=-1)\n\n\n\n\n\n","category":"type"},{"location":"manual/strings/#Base.codeunit","page":"Strings","title":"Base.codeunit","text":"codeunit(::TypstString)\ncodeunit(::TypstString, ::Integer)\n\nSee also TypstString.\n\nExamples\n\njulia> codeunit(typst\"a\")\nUInt8\n\njulia> codeunit(typst\"a\", 1)\n0x61\n\n\n\n\n\n","category":"function"},{"location":"manual/strings/#Base.isvalid","page":"Strings","title":"Base.isvalid","text":"isvalid(::TypstString, ::Integer)\n\nSee also TypstString.\n\nExamples\n\njulia> isvalid(typst\"a\", 1)\ntrue\n\n\n\n\n\n","category":"function"},{"location":"manual/strings/#Base.iterate","page":"Strings","title":"Base.iterate","text":"iterate(::TypstString)\niterate(::TypstString, ::Integer)\n\nSee also TypstString.\n\nExamples\n\njulia> iterate(typst\"a\")\n('a', 2)\n\njulia> iterate(typst\"a\", 1)\n('a', 2)\n\n\n\n\n\n","category":"function"},{"location":"manual/strings/#Base.ncodeunits","page":"Strings","title":"Base.ncodeunits","text":"ncodeunits(::TypstString)\n\nExamples\n\njulia> ncodeunits(typst\"a\")\n1\n\n\n\n\n\n","category":"function"},{"location":"manual/strings/#Base.pointer","page":"Strings","title":"Base.pointer","text":"pointer(::TypstString)\n\n\n\n\n\n","category":"function"},{"location":"manual/strings/#Base.show-Tuple{IO, MIME{Symbol(\"text/typst\")}, Any}","page":"Strings","title":"Base.show","text":"show(::IO, ::MIME\"text/typst\", ::Any)\n\nPrint to Typst format.\n\nProvides default settings for show_typst which may be specified in an IOContext. Custom default settings may be provided by implementing new methods.\n\nSetting Default Type Description\n:mode markup Mode The current Typst context where code follows the number sign, markup is at the top-level and enclosed in square brackets, and math is enclosed in dollar signs.\n:inline true Bool When :mode => math, specifies whether the enclosing dollar signs are padded with a space to render the element inline or its own block.\n:indent ' ' ^ 4 String The string used for horizontal spacing by some elements with multi-line Typst formatting.\n:depth 0 Int The current level of nesting within container types to specify the degree of indentation.\n\nExamples\n\njulia> show(stdout, \"text/typst\", \"a\")\n\"a\"\n\njulia> show(IOContext(stdout, :mode => code), \"text/typst\", \"a\")\n\"\\\"a\\\"\"\n\n\n\n\n\n","category":"method"},{"location":"manual/strings/#Base.show-Tuple{IO, Union{MIME{Symbol(\"image/png\")}, MIME{Symbol(\"image/svg+xml\")}}, TypstString}","page":"Strings","title":"Base.show","text":"show(::IO, ::Union{MIME\"image/png\", MIME\"image/svg+xml\"}, ::TypstString)\n\nPrint to a Portable Network Graphics (PNG) or Scalable Vector Graphics (SVG) format.\n\nEnvironments such as Pluto.jl notebooks use this function to render TypstStrings to a document. The corresponding Typst source file begins with this preamble:\n\n#set page(margin: 1em, height: auto, width: auto, fill: white)\n#set text(16pt, font: \"JuliaMono\")\n\n\nSee also julia_mono.\n\n\n\n\n\n","category":"method"},{"location":"manual/strings/#Base.show-Tuple{IO, TypstString}","page":"Strings","title":"Base.show","text":"show(::IO, ::TypstString)\n\nSee also TypstString.\n\nExamples\n\njulia> show(stdout, typst\"a\")\ntypst\"a\"\n\n\n\n\n\n","category":"method"},{"location":"","page":"Home","title":"Home","text":"DocTestSetup = :(using Typstry)","category":"page"},{"location":"#Home","page":"Home","title":"Home","text":"","category":"section"},{"location":"#Introduction","page":"Home","title":"Introduction","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Typstry.jl is the interface to convert the computational power of Julia into beautifully formatted Typst documents.","category":"page"},{"location":"#Installation","page":"Home","title":"Installation","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"julia> using Pkg: add\n\njulia> add(\"Typstry\")\n\njulia> using Typstry","category":"page"},{"location":"#Showcase","page":"Home","title":"Showcase","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"julia> show_typst(IOContext(stdout, :mode => code), 'a')\n\"'a'\"\n\njulia> show(stdout, \"text/typst\", [true 1; 1.0 [Any[true 1; 1.0 nothing]]])\n$mat(\n    \"true\", 1;\n    1.0, mat(\n        \"true\", 1;\n        1.0, \"\"\n    )\n)$\n\njulia> TypstString(1 // 2, :inline => false)\ntypst\"$ 1 / 2 $\"\n\njulia> typst\"$ \\(1 + 2im, :mode => math) $\"\ntypst\"$ 1 + 2i $\"\n\njulia> TypstCommand([\"help\"])\ntypst`help`\n\njulia> addenv(typst`compile input.typ output.pdf`, \"TYPST_FONT_PATHS\" => julia_mono)\ntypst`compile input.typ output.pdf`","category":"page"},{"location":"#Features","page":"Home","title":"Features","text":"","category":"section"},{"location":"#Strings","page":"Home","title":"Strings","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Convert Julia values to Typst format using show with the \"text/typst\" MIME type\nSpecify Julia settings and Typst parameters in the IOContext\nImplement show_typst for custom types\nCreate and manipulate TypstStrings\nInterpolate formatted Julia values using @typst_str\nRender in Pluto.jl notebooks","category":"page"},{"location":"#Commands","page":"Home","title":"Commands","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Construct TypstCommands with Vectors of Strings or using @typst_cmd\nRender documents using the Typst compiler\nUse the JuliaMono typeface","category":"page"},{"location":"#Planned","page":"Home","title":"Planned","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Implement show_typst for more types\nBase\nStandard Library\nPackage extensions\nSupport rendering in more environments\nIJulia.jl\nREPL Unicode?\nOther?","category":"page"},{"location":"#Related-Packages","page":"Home","title":"Related Packages","text":"","category":"section"},{"location":"#Typst","page":"Home","title":"Typst","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Labelyst.jl\nSummaryTables.jl\nTypstGenerator.jl\nTypst_jll.jl","category":"page"},{"location":"#LaTeX","page":"Home","title":"LaTeX","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Latexify.jl\nLaTeXStrings.jl\nLatexPrint.jl","category":"page"},{"location":"manual/commands/#Commands","page":"Commands","title":"Commands","text":"","category":"section"},{"location":"manual/commands/#Typstry","page":"Commands","title":"Typstry","text":"","category":"section"},{"location":"manual/commands/","page":"Commands","title":"Commands","text":"TypstCommand\n@typst_cmd\njulia_mono","category":"page"},{"location":"manual/commands/#Typstry.TypstCommand","page":"Commands","title":"Typstry.TypstCommand","text":"TypstCommand(::Vector{String})\nTypstCommand(::TypstCommand; kwargs...)\n\nThe Typst compiler.\n\ninfo: Info\nThis type implements the Cmd interface. However, the interface is unspecified which may result unexpected behavior.\n\nExamples\n\njulia> help = TypstCommand([\"help\"])\ntypst`help`\n\njulia> TypstCommand(help; ignorestatus = true)\ntypst`help`\n\n\n\n\n\n","category":"type"},{"location":"manual/commands/#Typstry.@typst_cmd","page":"Commands","title":"Typstry.@typst_cmd","text":"@typst_cmd(s)\ntypst`s`\n\nConstruct a TypstCommand without interpolation.\n\nEach parameter must be separated by a space.\n\nExamples\n\njulia> typst`help`\ntypst`help`\n\njulia> typst`compile input.typ output.typ`\ntypst`compile input.typ output.typ`\n\n\n\n\n\n","category":"macro"},{"location":"manual/commands/#Typstry.julia_mono","page":"Commands","title":"Typstry.julia_mono","text":"julia_mono\n\nAn artifact containing the JuliaMono typeface.\n\nUse with a TypstCommand and either addenv or the font-path command-line option.\n\n\n\n\n\n","category":"constant"},{"location":"manual/commands/#Base","page":"Commands","title":"Base","text":"","category":"section"},{"location":"manual/commands/","page":"Commands","title":"Commands","text":"addenv\ndetach\nignorestatus\nrun\nsetcpuaffinity\nsetenv\nshow(::IO, ::TypstCommand)","category":"page"},{"location":"manual/commands/#Base.addenv","page":"Commands","title":"Base.addenv","text":"addenv(::TypstCommand, args...; kwargs...)\n\nSee also TypstCommand and julia_mono.\n\nExamples\n\njulia> addenv(typst`compile input.typ output.pdf`, \"TYPST_FONT_PATHS\" => julia_mono)\ntypst`compile input.typ output.pdf`\n\n\n\n\n\n","category":"function"},{"location":"manual/commands/#Base.detach","page":"Commands","title":"Base.detach","text":"detach(::TypstCommand)\n\nSee also TypstCommand.\n\nExamples\n\njulia> detach(typst`help`)\ntypst`help`\n\n\n\n\n\n","category":"function"},{"location":"manual/commands/#Base.ignorestatus","page":"Commands","title":"Base.ignorestatus","text":"ignorestatus(::TypstCommand)\n\nSee also TypstCommand.\n\nExamples\n\njulia> ignorestatus(typst`help`)\ntypst`help`\n\n\n\n\n\n","category":"function"},{"location":"manual/commands/#Base.run","page":"Commands","title":"Base.run","text":"run(::TypstCommand, args...; kwargs...)\n\nSee also TypstCommand.\n\n\n\n\n\n","category":"function"},{"location":"manual/commands/#Base.setcpuaffinity","page":"Commands","title":"Base.setcpuaffinity","text":"setcpuaffinity(::TypstCommand, cpus)\n\nSee also TypstCommand.\n\ncompat: Compat\nRequires at least Julia v0.8.\n\nExamples\n\njulia> setcpuaffinity(typst`help`, nothing)\ntypst`help`\n\n\n\n\n\n","category":"function"},{"location":"manual/commands/#Base.setenv","page":"Commands","title":"Base.setenv","text":"setenv(::TypstCommand, env; kwargs...)\n\nSee also TypstCommand.\n\n\n\n\n\n","category":"function"},{"location":"manual/commands/#Base.show-Tuple{IO, TypstCommand}","page":"Commands","title":"Base.show","text":"show(::IO, ::TypstCommand)\n\nSee also TypstCommand.\n\nExamples\n\njulia> show(stdout, typst`help`)\ntypst`help`\n\n\n\n\n\n","category":"method"}]
}
