
using Typstry

module TestTypstry

using Test: @test, @testset

test_modes(x, ss) = @testset "modes" begin
    for (mode, s) in zip(instances(Mode), ss)
        test_strings(x, s; mode)
    end
end

test_strings(x, s; kwargs...) = @test TypstString(x; kwargs...).text == s

@testset "Typstry" begin
    for description in [
        "Aqua",
        "Documenter",
        "ExplicitImports",
        "LaTeXStringsExtension",
        "MarkdownExtension"
    ]
        @testset "$description" include("Test" * description * ".jl").test()
    end
end

end # TestTypstry
