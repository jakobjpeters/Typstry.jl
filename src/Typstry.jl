
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

export typst, compile, watch, fonts, @T_str

end # module Typst
