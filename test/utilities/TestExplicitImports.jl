
module TestExplicitImports

import Typstry
using ExplicitImports:
    check_all_explicit_imports_are_public,
    check_all_explicit_imports_via_owners,
    check_all_qualified_accesses_are_public,
    check_all_qualified_accesses_via_owners,
    check_no_implicit_imports,
    check_no_self_qualified_accesses,
    check_no_stale_explicit_imports
using Test: @test

@test isnothing(check_all_explicit_imports_are_public(Typstry;
    ignore = (:Strings, :MD, :Stateful, :parse)))

for check in [
    check_all_explicit_imports_via_owners,
    check_all_qualified_accesses_are_public,
    check_all_qualified_accesses_via_owners,
    check_no_implicit_imports,
    check_no_self_qualified_accesses,
    check_no_stale_explicit_imports
]
    @test isnothing(check(Typstry))
end

end # TestExplicitImports
