
module TestStrings

import Typstry: context, show_typst
using .Meta: parse
using Test: @test, @testset
using Typstry

# TODO: test string escaping in `@typst_str`, `show`, `print`, `regex`, `TypstText`, etc
# TODO: remove unnesessary methods (`IOBuffer`, `codeunit`, `pointer`)?

struct X end

const default_context = Dict(
    :backticks => 3,
    :block => false,
    :depth => 0,
    :mode => markup,
    :parenthesize => true,
    :tab_size => 2
)
const typst_int = Typst(1)
const x = X()
const x_context = Dict(:x => 1)

context(::X) = x_context
show_typst(io, ::X) = print(io, 1)

const pairs = [
    typst"" => ""
    typst"x" => "x"
    typst"(x)" => "(x)"
    typst"𝒂(x)𝒃" => "𝒂(x)𝒃"
    typst"𝒂𝒃(x)𝒄𝒅" => "𝒂𝒃(x)𝒄𝒅"
    typst"\(x)" => "1"
    typst"𝒂\(x)𝒃" => "𝒂1𝒃"
    typst"𝒂𝒃\(x)𝒄𝒅" => "𝒂𝒃1𝒄𝒅"
    typst"\\(x)" => "\\(x)"
    typst"𝒂\\(x)𝒃" => "𝒂\\(x)𝒃"
    typst"𝒂𝒃\\(x)𝒄𝒅" => "𝒂𝒃\\(x)𝒄𝒅"
    typst"\\\(x)" => "\\1"
    typst"𝒂\\\(x)𝒃" => "𝒂\\1𝒃"
    typst"𝒂𝒃\\\(x)𝒄𝒅" => "𝒂𝒃\\1𝒄𝒅"
    typst"\\\\(x)" => "\\\\(x)"
    typst"𝒂\\\\(x)𝒃" => "𝒂\\\\(x)𝒃"
    typst"𝒂𝒃\\\\(x)𝒄𝒅" => "𝒂𝒃\\\\(x)𝒄𝒅"
    typst"\(x)\(x)" => "11"
    typst"𝒂\(x)𝒃\(x)𝒄" => "𝒂1𝒃1𝒄"
    typst"𝒂𝒃\(x)𝒄𝒅\(x)𝒆𝒇" => "𝒂𝒃1𝒄𝒅1𝒆𝒇"
    typst"\\(x)\(x)" => "\\(x)1"
    typst"𝒂\\(x)𝒃\(x)𝒄" => "𝒂\\(x)𝒃1𝒄"
    typst"𝒂𝒃\\(x)𝒄𝒅\(x)𝒆𝒇" => "𝒂𝒃\\(x)𝒄𝒅1𝒆𝒇"
    typst"\(x)\\(x)" => "1\\(x)"
    typst"𝒂\(x)𝒃\\(x)𝒄" => "𝒂1𝒃\\(x)𝒄"
    typst"𝒂𝒃\(x)𝒄𝒅\\(x)𝒆𝒇" => "𝒂𝒃1𝒄𝒅\\(x)𝒆𝒇"
]

test_pairs(f) = @test all(splat(f), pairs)
test_equal(f) = test_pairs((ts, s) -> f(ts) == f(s))

@testset "`Typstry`" begin
    @testset "`Mode`" begin
        @test Mode <: Enum
        @test instances(Mode) == map(Mode, (0, 1, 2)) == (code, markup, math)
    end

    @testset "`Typst`" begin
        @test typst_int == typst_int
        @test typst_int != Typst(1.0)
        @test typeof(typst_int) == Typst{Int}
        @test string(typst_int) == "Typst{Int64}(1)"
    end

    @testset "`TypstString`" begin end

    @testset "`TypstText`" begin end

    @testset "`@typst_str`" begin end

    @testset "`context`" begin
        @test context(1) == Dict{Symbol, Union{}}()
        @test context(X()) == x_context
        @test context(typst_int) == default_context
        @test context(Typst(x)) == merge(default_context, x_context)
    end

    @testset "`show_typst`" begin end
end

@testset "`Base`" begin
    @testset "`AbstractString` Interface" begin
        @testset "`IOBuffer`" begin test_equal(read ∘ IOBuffer) end

        @testset "`codeunit`" begin test_pairs((ts, s) ->
            codeunit(ts) == codeunit(s) && all(i -> codeunit(ts, i) == codeunit(s, i), eachindex(ts))
        ) end

        @testset "`isvalid`" begin end

        @testset "`iterate`" begin test_pairs((ts, s) ->
            iterate(ts) == iterate(s) && all(i -> iterate(ts, i) == iterate(s, i), eachindex(ts))
        ) end

        @testset "`ncodeunits`" begin test_equal(ncodeunits) end

        @testset "`pointer`" begin end

        @testset "`repr`" begin
            test_pairs((ts, s) -> repr(MIME"text/typst"(), ts) === eval(parse(repr(ts))) === ts)
        end

        @testset "`show`" begin end
    end

    @testset "`Symbol`" begin test_equal(Symbol) end

    @testset "`==`" begin test_equal(identity) end

    @testset "`length`" begin test_equal(length) end

    @testset "`print`" begin test_pairs((ts, s) -> ts == sprint(print, ts) == s) end
end

end # TestStrings
