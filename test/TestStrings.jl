
module TestStrings

import Typstry: context
using Test: @test, @testset
using Typstry

struct X end

const default_context = Dict(
    :backticks => 3,
    :block => false,
    :depth => 0,
    :mode => markup,
    :parenthesize => true,
    :tab_size => 2
)
const typst = Typst(1)
const x = X()
const x_context = Dict(:x => 1)

context(::X) = x_context

@testset "`Typstry`" begin
    @testset "`Mode`" begin
        @test Mode <: Enum
        @test instances(Mode) == map(Mode, (0, 1, 2)) == (code, markup, math)
    end

    @testset "`Typst`" begin
        @test typst == typst
        @test typst != Typst(1.0)
        @test typeof(typst) == Typst{Int}
        @test string(typst) == "Typst{Int64}(1)"
    end

    @testset "`TypstString`" begin end

    @testset "`TypstText`" begin end

    @testset "`@typst_str`" begin end

    @testset "`context`" begin
        @test context(1) == Dict{Symbol, Union{}}()
        @test context(X()) == x_context
        @test context(typst) == default_context
        @test context(Typst(x)) == merge(default_context, x_context)
    end

    @testset "`show_typst`" begin end
end

@testset "`Base`" begin
    @testset "`IOBuffer`" begin end

    @testset "`codeunit`" begin end

    @testset "`isvalid`" begin end

    @testset "`iterate`" begin end

    @testset "`ncodeunits`" begin end

    @testset "`pointer`" begin end

    @testset "`repr`" begin end

    @testset "`show`" begin end
end

end # TestStrings

