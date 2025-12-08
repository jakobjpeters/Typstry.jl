
module TestJET

import Typstry
using JET: test_package

@static if VERSION ≥ v"1.12"
    test_package(Typstry; target_modules = [Typstry])
end

end # TestJET
