
module TestCommands

using Test: @test, @testset, @test_throws, @test_warn
using Typstry

const tc = typst`help`
const tc_error = typst`a`
const tc_ignorestatus = ignorestatus(tc_error)

@testset "`Typstry`" begin
    @testset "`TypstCommand`" begin end

    @testset "`TypstError`" begin end

    @testset "`@typst_cmd`" begin end

    @testset "`julia_mono`" begin @test julia_mono isa String end

    @testset "`render`" begin end

    @testset "`compile`" begin
        mktempdir() do tmpdir
            infile = joinpath(tmpdir, "test.typ")
            outfile1 = joinpath(tmpdir, "test.pdf")
            outfile2 = joinpath(tmpdir, "out.pdf")
            write(infile, "= Test Document\n")
            compile(infile)
            @test isfile(outfile1)
            compile(infile, outfile2)
            @test isfile(outfile2)
        end
    end

    @testset "`watch`" begin end
end

@testset "`Base`" begin
    @testset "`==`" begin end

    @testset "`addenv`" begin end

    @testset "`detach`" begin end

    @testset "`eltype`" begin @test eltype(TypstCommand) == String end

    @testset "`firstindex`" begin @test firstindex(tc) == 1 end

    @testset "`getindex`" begin end

    @testset "`hash`" begin end

    @testset "`ignorestatus`" begin
        @test tc_ignorestatus == TypstCommand(tc_error; ignorestatus = true)
        @test_warn "error" run(tc_ignorestatus)
    end

    @testset "`iterate`" begin end

    @testset "`keys`" begin end

    @testset "`lastindex`" begin end

    @testset "`length`" begin end

    @testset "`run`" begin
        # TODO: write more tests
        @test_throws TypstError redirect_stderr(() -> run(tc_error), devnull)
        @test_warn "error" try run(tc_error) catch end
    end

    @testset "`setcpuaffinity`" begin end

    @testset "`setenv`" begin end

    @testset "`show`" begin end

    @testset "`showerror`" begin end
end

end # TestCommands
