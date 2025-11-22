
module TestStrings

import Typstry: TypstContext, show_typst
using .Meta: parse
using Test: @test, @test_throws, @testset
using ..TestTypstry: test_strings
using Typstry

# TODO: test string escaping in `@typst_str`, `show`, `print`, `regex`, `TypstText`, etc
# TODO: remove unnesessary methods (`IOBuffer`, `codeunit`, `pointer`)?

struct X end

const typst_int = Typst(1)
const x = X()

TypstContext(::X) = TypstContext(; x = 1)
show_typst(io::IO, tc::TypstContext, ::X) = print(io, tc[:x]::Int)

const pairs = [
    typst"" => ""
    typst"\\" => "\\" # \
    typst"\ " => "\\ "
    typst"\\ " => "\\\\ "
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

    @testset "`TypstString`" begin
        test_strings(TypstString(x), "1")
        test_strings(TypstString(x; x = 2), "2")
    end

    @testset "`TypstText`" begin
        @test TypstText(x) isa TypstText{X}
        @test repr(MIME"text/typst"(), TypstText(x)) isa TypstString

        for mime in ["application/pdf", "image/png", "image/svg+xml"]
            @test isnothing(show(devnull, MIME(mime), TypstText(x)))
        end
    end

    @testset "`@typst_str`" begin end

    @testset "`show_typst`" begin
        for example in Typstry.examples
            for mode in instances(Mode)
                @test isnothing(render(example; mode))
            end
        end

        @testset "`AbstractChar`" begin
            test_strings('a', typst"\"a\""; mode = code)
            test_strings('a', typst"#\"a\""; mode = markup)
            test_strings('a', typst"\"a\""; mode = math)

            test_strings('"', typst"#\"\\\"\"")
        end

        @testset "`AbstractFloat`" begin
            test_strings(1.0, typst"$1.0$"; mode = code)
            test_strings(1.0, typst"$1.0$"; mode = markup)
            test_strings(1.0, typst"1.0"; mode = math)

            test_strings(1.0, typst"$ 1.0 $"; block = true)
            test_strings(Inf, typst"#float.inf")
            test_strings(NaN, typst"#float.nan")
        end

        @testset "`AbstractString`" begin
            test_strings("a", typst"\"a\""; mode = code)
            test_strings("a", typst"#\"a\""; mode = markup)
            test_strings("a", typst"\"a\""; mode = math)

            test_strings("\"", typst"#\"\\\"\"")
        end

        @testset "`Bool`" begin
            test_strings(true, typst"true"; mode = code)
            test_strings(true, typst"#true"; mode = markup)
            test_strings(true, typst"#true"; mode = math)
        end

        @testset "`Complex`" begin
            test_strings(im, typst"$i$"; mode = code)
            test_strings(im, typst"$i$"; mode = markup)
            test_strings(im, typst"i"; mode = math)

            test_strings(0im, typst"$0$")
            test_strings(-im, typst"$-i$")
            test_strings(2im, typst"$2i$")
            test_strings(-2im, typst"$-2i$")
            test_strings(1 + 0im, typst"$1$")
            test_strings(-1 + 0im, typst"$-1$")
            test_strings(1 + im, typst"$1 + i$")
            test_strings(1 - im, typst"$1 - i$")
            test_strings(1 + 2im, typst"$1 + 2i$")
        end

        @testset "`Irrational`" begin
            test_strings(π, typst"$π$"; mode = code)
            test_strings(π, typst"$π$"; mode = markup)
            test_strings(π, typst"π"; mode = math)

            test_strings(π, typst"$ π $"; block = true)
        end

        @testset "`Nothing`" begin
            test_strings(nothing, typst"none"; mode = code)
            test_strings(nothing, typst"#none"; mode = markup)
            test_strings(nothing, typst"#none"; mode = math)
        end

        @testset "`Signed`" begin
            test_strings(1, typst"1"; mode = code)
            test_strings(1, typst"$1$"; mode = markup)
            test_strings(1, typst"1"; mode = math)

            test_strings(1, typst"$ 1 $"; block = true)
        end

        @testset "`Symbol`" begin
            test_strings(:a, typst"$\"a\"$"; mode = code)
            test_strings(:a, typst"$\"a\"$"; mode = markup)
            test_strings(:a, typst"\"a\""; mode = math)

            test_strings(:a, typst"$ \"a\" $"; block = true)
            test_strings(Symbol('"'), typst"$\"\\\"\"$")
        end

        @testset "`Unsigned`" begin
            test_strings(0x01, typst"0x01"; mode = code)
            test_strings(0x01, typst"#0x01"; mode = markup)
            test_strings(0x01, typst"#0x01"; mode = math)
        end

        @testset "`VersionNumber`" begin
            test_strings(v"1.2.3", typst"version(1, 2, 3)"; mode = code)
            test_strings(v"1.2.3", typst"#version(1, 2, 3)"; mode = markup)
            test_strings(v"1.2.3", typst"#version(1, 2, 3)"; mode = math)
        end
    end

    for ((value, _), mode) ∈ Iterators.product(Typstry.examples, instances(Mode))
        @test begin
            buffer = IOBuffer()

            if mode == markup show_typst(buffer, value; mode)
            elseif mode == math
                print(buffer, '$')
                show_typst(buffer, value; mode)
                print(buffer, '$')
            elseif mode == code
                print(buffer, "#{")
                show_typst(buffer, value; mode)
                print(buffer, '}')
            end

            render(TypstText(String(take!(buffer))))
            true
        end
    end
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
            test_pairs((ts, s) -> repr(MIME"text/typst"(), ts) == eval(parse(repr(ts))) == ts)
        end

        @testset "`show`" begin
            for mime in ["application/pdf", "image/png", "image/svg+xml"]
                @test isnothing(show(devnull, MIME(mime), typst""))
                @test_throws TypstCommandError show(devnull, MIME(mime), typst"$")
            end
        end
    end

    @testset "`Symbol`" begin test_equal(Symbol) end

    @testset "`==`" begin test_equal(identity) end

    @testset "`length`" begin test_equal(length) end

    @testset "`print`" begin test_pairs((ts, s) -> ts == sprint(print, ts) == s) end
end

end # TestStrings
