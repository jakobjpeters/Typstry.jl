
module TypstFunctions

import Base: ==, show
import ..Strings: show_typst

using Base: Pairs
using ..Strings: AbstractTypst, Mode, TypstString, code, depth, mode, tab_size
using Typstry: TypstContext
using Typstry.Utilities: enclose, join_with

export TypstFunction


end # TypstFunctions
