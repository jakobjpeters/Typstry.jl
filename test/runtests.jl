
using ExplicitImports: check_no_implicit_imports, check_no_stale_explicit_imports
using Test: @testset, @test, detect_ambiguities, detect_unbound_args
using Documenter: DocMeta.setdocmeta!, doctest
using Typstry

@testset "`check_no_implicit_imports` and `check_no_stale_explicit_imports`" begin
    @test isnothing(check_no_implicit_imports(Typstry))
    @test isnothing(check_no_stale_explicit_imports(Typstry; ignore = (:Docs, :Iterators, :Meta)))
end

@testset "`detect_ambiguities` and `detect_unbound_args`" begin
    @test isempty(detect_ambiguities(Typstry))
    @test isempty(detect_unbound_args(Typstry))
end

setdocmeta!(
    Typstry,
    :DocTestSetup,
    :(using Typstry),
    recursive = true
)

doctest(Typstry)
