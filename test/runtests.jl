
using Test: @testset, @test, detect_ambiguities, detect_unbound_args
using Documenter: DocMeta.setdocmeta!, doctest
using Typstry

@testset "`detect_ambiguities` and `detect_unbound_args`" for detect in (
    :detect_ambiguities, :detect_unbound_args
)
    @eval @test isempty($detect(Typstry, recursive = true))
end

setdocmeta!(
    Typstry,
    :DocTestSetup,
    :(using Typstry),
    recursive = true
)

@testset "`doctest`" doctest(Typstry)
