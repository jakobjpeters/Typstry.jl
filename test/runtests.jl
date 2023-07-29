
using Test: @testset, @test, detect_ambiguities, detect_unbound_args
using Typst

@testset "`detect_ambiguities` and `detect_unbound_args`" begin
    for detect in (:detect_ambiguities, :detect_unbound_args)
        @eval @test isempty($detect(Typst, recursive = true))
    end
end
