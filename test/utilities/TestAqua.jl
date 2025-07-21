
module TestAqua

import Typstry
using Aqua: test_all, test_deps_compat

# TODO: test package extensions
redirect_stdout(devnull) do
    test_all(Typstry; deps_compat = false, persistent_tasks = false)
    test_deps_compat(Typstry; check_weakdeps = (ignore = [:Markdown],), ignore = [:Artifacts, :Dates])
end

end # TestAqua
