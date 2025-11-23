
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

for (check, ignore) ∈ [
    check_all_explicit_imports_are_public => (:MD, :Stateful, :compile_workload, :parse, :show_raw, :isoperator)
    check_all_explicit_imports_via_owners => ()
    check_all_qualified_accesses_are_public => (:map,)
    check_all_qualified_accesses_via_owners => ()
    check_no_implicit_imports => ()
    check_no_self_qualified_accesses => ()
    check_no_stale_explicit_imports => (:Typstry, :MathConstants)
]
    @test isnothing(check(Typstry; ignore))
end

end # TestExplicitImports
