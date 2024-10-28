
module TestAqua

using Aqua: test_all, test_deps_compat
using Typstry: Typstry

# TODO: test package extensions
redirect_stdout(devnull) do
    test_all(Typstry; deps_compat = false)
    test_deps_compat(Typstry; check_weakdeps = (ignore = [:Markdown],), ignore = [:Artifacts, :Dates])
end

end # TestAqua
