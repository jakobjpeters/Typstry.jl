
module TestAqua

using Aqua: test_all, test_ambiguities
using Typstry

function test()
    test_all(Typstry; ambiguities = false)
    test_ambiguities(Typstry)
end

end # TestAqua
