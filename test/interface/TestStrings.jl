
module TestStrings

import Typstry: TypstContext, show_typst

using Dates: Day, Hour, Minute, Second, Week
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

test_pairs(callback) = @test all(splat(callback), pairs)
test_equal(callback) = test_pairs() do typst_string, string
    callback(typst_string) == callback(string)
end

@testset "`Typstry`" begin
    @testset "`Mode`" begin
        @test Mode <: Enum
        @test instances(Mode) == map(Mode, (0, 1, 2)) == (code, markup, math)
    end

    @testset "`Typst`" begin
        @test Typst([]) == Typst([])
        @test typst_int == typst_int
        @test typst_int != Typst(1.0)
        @test typeof(typst_int) == Typst{Int}
        @test string(typst_int) == "Typst{Int64}(1)"
        @test repr("text/typst", Typst(1)) == typst"$1$"
        @test repr("text/typst", Typst(1); context = IOContext(stdout, TypstContext(; mode = math))) == typst"1"

        buffer = IOBuffer()
        show(buffer, "text/typst", Typst(1))
        @test String(take!(buffer)) == "\$1\$"

        for mime in ["application/pdf", "image/png", "image/svg+xml"]
            @test isnothing(show(devnull, mime, Typst(1)))
        end
    end

    @testset "`TypstString`" begin
        test_strings(TypstString(x), "1")
        test_strings(TypstString(x; x = 2), "2")

        @test typst"a" * typst"b" isa TypstString
        @test typst"a" * typst"b" == typst"ab"
        @test repr("text/plain", typst"") == "typst\"\""
        @test isnothing(show(devnull, "text/typst", typst""))
    end

    @testset "`TypstText`" begin
        @test TypstText([]) == TypstText([])
        @test TypstText(x) isa TypstText{X}
        @test repr(MIME"text/typst"(), TypstText(x)) isa TypstString

        for mime in ["application/pdf", "image/png", "image/svg+xml"]
            @test isnothing(show(devnull, MIME(mime), TypstText(x)))
        end
    end

    @testset "`@typst_str`" begin end

    @testset "`show_typst`" begin
        @testset "`AbstractChar`" begin
            test_strings('a', typst"\"a\""; mode = code)
            test_strings('a', typst"#\"a\""; mode = markup)
            test_strings('a', typst"\"a\""; mode = math)

            test_strings('"', typst"#\"\\\"\"")
        end

        @testset "`AbstractFloat`" begin
            test_strings(1.0, typst"1.0"; mode = code)
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
            test_strings(im, typst"$0 + 1i$"; mode = code)
            test_strings(im, typst"$0 + 1i$"; mode = markup)
            test_strings(im, typst"(0 + 1i)"; mode = math)

            test_strings(im, typst"0 + 1i"; mode = math, parenthesize = false)
        end

        @testset "`Irrational`" begin
            test_strings(π, typst"$π$"; mode = code)
            test_strings(π, typst"$π$"; mode = markup)
            test_strings(π, typst"π"; mode = math)

            test_strings(π, typst"$ π $"; block = true)
        end

        @testset "`NamedTuple`" begin
            # test_strings((;), typst"(:)"; mode = code)
            # test_strings((;), typst"#(:)"; mode = markup)
            # test_strings((;), typst"#(:)"; mode = math)

            # test_strings((; a = 1, b = 2), TypstString(TypstText("#(\n  a: 1,\n  b: 2\n)")))
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

        @testset "`Tuple`" begin
            test_strings((), typst"()"; mode = code)
            test_strings((), typst"#()"; mode = markup)
            test_strings((), typst"#()"; mode = math)

            test_strings((1,), typst"#(1,)")
            test_strings((1, 2), TypstString(TypstText("#(\n  1,\n  2\n)")))
        end

        @testset "`TypstFunction`" begin
            typst_function = TypstFunction(TypstContext(; depth = 0, mode = markup, tab_size = 2), typst"")
            @test typst_function == deepcopy(typst_function)

            for (mode, expected) in zip(instances(Mode), [
                "arguments()", "#arguments()", "#arguments()"]
            )
                test_strings(
                    TypstFunction(setindex!(copy(context), mode, :mode), typst"arguments"),
                    TypstString(TypstText(expected))
                )
            end

            test_strings(
                TypstFunction(context, typst"arguments", 1, 2; a = 3, b = 4),
                TypstString(TypstText("#arguments(\n  1,\n  2,\n  a: 3,\n  b: 4\n)"))
            )

            @test repr("text/typst", typst_function) == "#()"

            for mime in ["application/pdf", "image/png", "image/svg+xml", "text/typst"]
                @test isnothing(show(devnull, MIME(mime), typst_function))
            end

            @test eval(Meta.parse(string(typst_function))) == typst_function
        end

        @testset "`Unsigned`" begin
            test_strings(0x01, typst"0x01"; mode = code)
            test_strings(0x01, typst"#0x01"; mode = markup)
            test_strings(0x01, typst"#0x01"; mode = math)
        end

        @testset "`VersionNumber`" begin
            test_strings(v"1.2.3", TypstString(TypstText("version(\n  1,\n  2,\n  3\n)")); mode = code)
            test_strings(v"1.2.3", TypstString(TypstText("#version(\n  1,\n  2,\n  3\n)")); mode = markup)
            test_strings(v"1.2.3", TypstString(TypstText("#version(\n  1,\n  2,\n  3\n)")); mode = math)
        end

        @testset "Dates.jl" begin
            for (key, value) in Any[
                :days => Day(0)
                :hours => Hour(0)
                :minutes => Minute(0)
                :seconds => Second(0)
                :weeks => Week(0)
            ]
                @test Typstry.Strings.Dates.duration(value) == key
            end
        end

        @testset "fallback" begin
            struct A end
            @test isnothing(show_typst(devnull, A()))
        end
    end

    @testset "`examples`" begin
        for ((value, _), mode) ∈ Iterators.product(Typstry.Precompile.examples, instances(Mode))
            io_buffer = IOBuffer()

            if mode == markup show_typst(io_buffer, value; mode)
            elseif mode == math
                print(io_buffer, '$')
                show_typst(io_buffer, value; mode)
                print(io_buffer, '$')
            elseif mode == code
                print(io_buffer, "#{")
                show_typst(io_buffer, value; mode)
                print(io_buffer, '}')
            end

            # TODO:
            # @test isnothing(render(TypstText(String(take!(buffer)))))
        end
    end
end

@testset "`Base`" begin
    @testset "`AbstractString` Interface" begin
        @testset "`IOBuffer`" begin test_equal(read ∘ IOBuffer) end

        @testset "`codeunit`" begin
            test_pairs() do ts, s
                codeunit(ts) == codeunit(s) && all(eachindex(ts)) do i
                    codeunit(ts, i) == codeunit(s, i)
                end
            end
        end

        @testset "`isvalid`" begin end

        @testset "`iterate`" begin
            test_pairs() do ts, s
                iterate(ts) == iterate(s) && all(eachindex(ts)) do i
                    iterate(ts, i) == iterate(s, i)
                end
            end
        end

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

@testset "Utilities" begin
    @testset "`format`" begin
        for (mime, extension) in [
            "application/pdf" => :pdf
            "image/gif" => :gif
            "image/jpg" => :jpg
            "image/png" => :png
            "image/svg+xml" => :svg
            "image/webp" => :webp
        ]
            @test Typstry.Strings.Utilities.format(MIME(mime)) == string(extension)
        end
    end
end

end # TestStrings
