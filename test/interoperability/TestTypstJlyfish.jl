
module TestTypstJlyfish
    using Test: @test
    @test begin
        include("../../scripts/typst_jlyfish.jl")
        true
    end
end
