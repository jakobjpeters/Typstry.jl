
module Typstry

import Typst_jll

"""
    typst(args...)
"""
typst(args...) = Typst_jll.typst(exe -> run(Cmd([exe, args...])))

"""
    compile(args...)
"""
compile(args...) = typst("compile", args...)

"""
    watch(args...)
"""
watch(args...) = typst("watch", args...)

"""
    fonts(args...)
"""
fonts(args...) = typst("fonts", args...)

macro T_str(s)
    s
end

# function pdf(path; delete = false)
#     compile(path)
#     delete && rm(path)
#     nothing
# end

# function pdf(s, path = "out.typ"; delete = false)
#     write(path, s)
#     pdf(path; delete)
# end

export typst, compile, watch, fonts, @T_str, pdf

end # module Typst



#=

# compile(doc, name = "out.pdf")

pdf(s, delete = false, open = true)
pdf(s::TypstString; path = out.pdf, delete = false, open = true)


watch -> use threads?


mutable struct X <: AbstractString
    s::String
end

=#
