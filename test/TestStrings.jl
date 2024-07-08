
module TestStrings

import Typstry: context, show_typst
using .Meta: parse
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
const typst_int = Typst(1)
const x = X()
const x_context = Dict(:x => 1)

context(::X) = x_context
show_typst(io, ::X) = print(io, 1)

const empty_ts = typst""
const tss = [
    empty_ts,
    typst"x",
    typst"(x)",
    typst"a(x)b",
    typst"ab(x)cd",
    typst"\(x)",
    typst"a\(x)b",
    typst"ab\(x)cd",
    typst"\\(x)",
    typst"a\\(x)b",
    typst"ab\\(x)cd",
    typst"\\\(x)",
    typst"a\\\(x)b",
    typst"ab\\\(x)cd",
    typst"\\\\(x)",
    typst"a\\\\(x)b",
    typst"ab\\\\(x)cd",
    typst"\(x)\(x)",
    typst"a\(x)b\(x)c",
    typst"ab\(x)cd\(x)ef",
    typst"\\(x)\(x)",
    typst"a\\(x)b\(x)c",
    typst"ab\\(x)cd\(x)ef",
    typst"\(x)\\(x)",
    typst"a\(x)b\\(x)c",
    typst"ab\(x)cd\\(x)ef"
]

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

    @testset "`@typst_str`" begin
        for (ts, s) in zip(tss, [
            "",
            "x",
            "(x)",
            "a(x)b",
            "ab(x)cd",
            "1",
            "a1b",
            "ab1cd",
            "\\(x)",
            "a\\(x)b",
            "ab\\(x)cd",
            "\\1",
            "a\\1b",
            "ab\\1cd",
            "\\\\(x)",
            "a\\\\(x)b",
            "ab\\\\(x)cd",
            "11",
            "a1b1c",
            "ab1cd1ef",
            "\\(x)1",
            "a\\(x)b1c",
            "ab\\(x)cd1ef",
            "1\\(x)",
            "a1b\\(x)c",
            "ab1cd\\(x)ef"
        ])
            @test ts == sprint(print, ts) == s
        end
    end

    @testset "`context`" begin
        @test context(1) == Dict{Symbol, Union{}}()
        @test context(X()) == x_context
        @test context(typst_int) == default_context
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

    @testset "`repr`" begin
        @test repr(MIME"text/typst"(), empty_ts) === empty_ts

        for ts in tss
            @test eval(parse(repr(ts))) === ts
        end
    end

    @testset "`show`" begin end
end

end # TestStrings

