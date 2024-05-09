
using Test: @testset, @test, detect_ambiguities, detect_unbound_args
using Documenter: DocMeta.setdocmeta!, doctest
using Typstry

@testset "`detect_ambiguities` and `detect_unbound_args`" all(
    detect -> isempty(detect(Typstry)), (detect_ambiguities, detect_unbound_args))

setdocmeta!(
    Typstry,
    :DocTestSetup,
    :(using Typstry),
    recursive = true
)

doctest(Typstry)
