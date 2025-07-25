
module TestJET

import Typstry
using JET: test_package

test_package(Typstry; target_modules = [Typstry])

end # TestJET
