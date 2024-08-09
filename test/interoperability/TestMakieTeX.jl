
module TestMakieTeX
    using Test: @test
    @test begin
        include("../../scripts/include_makie_tex.jl")
        true
    end
end
