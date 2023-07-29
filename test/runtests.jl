
using Test: @testset, @test, detect_ambiguities, detect_unbound_args
using Typstry

@testset "`detect_ambiguities` and `detect_unbound_args`" begin
    for detect in (:detect_ambiguities, :detect_unbound_args)
        @eval @test isempty($detect(Typstry, recursive = true))
    end
end
