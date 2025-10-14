
module TestCommands

import Typst_jll
using Test: @test, @testset, @test_throws, @test_warn
using Typstry

const tc = typst`help`
const tc_error = typst`a`
const tc_ignorestatus = ignorestatus(tc_error)

@testset "`Typstry`" begin
    @testset "`TypstCommand`" begin
        @test TypstCommand([]) isa TypstCommand
        @test TypstCommand(["help"]) isa TypstCommand
    end

    @testset "`TypstCommandError`" begin
        @test TypstCommandError(TypstCommand([])) isa TypstCommandError
        @test TypstCommandError(TypstCommand(["help"])) isa TypstCommandError
    end

    @testset "`@typst_cmd`" begin
        @test typst`` isa TypstCommand
    end

    @testset "`julia_mono`" begin
        @test julia_mono isa String
    end

    @testset "`render`" begin
        @test isnothing(render(typst""; open = false))
    end

    @testset "`typst`" begin
        mktempdir() do tmpdir
            infile = joinpath(tmpdir, "test.typ")
            outfile1 = joinpath(tmpdir, "test.pdf")
            outfile2 = joinpath(tmpdir, "out.pdf")
            write(infile, "= Test Document\n")
            cd(tmpdir) do
                typst("compile test.typ")
                typst("c test.typ out.pdf")
            end
            @test isfile(outfile1)
            @test isfile(outfile2)
            # Only check that it runs without error.
            redirect_stdout(devnull) do
                typst("--help")
                typst("fonts --variants")
            end
        end
    end
end

@testset "`Base`" begin
    @testset "`==`" begin
        @test typst`` == typst``
    end

    @testset "`Cmd`" begin
        @test Cmd(typst``) isa Cmd
    end

    @testset "`addenv`" begin end

    @testset "`detach`" begin end

    @testset "`eltype`" begin @test eltype(TypstCommand) == String end

    @testset "`firstindex`" begin @test firstindex(tc) == 1 end

    @testset "`getindex`" begin
        @test typst``[1] == Typst_jll.typst()[1]
        @test typst`help`[2] == "help"
    end

    @testset "`hash`" begin
        @test hash(typst``) isa UInt
    end

    @testset "`ignorestatus`" begin
        @test tc_ignorestatus == TypstCommand(tc_error; ignorestatus = true)
        @test_warn "error" run(tc_ignorestatus)
    end

    @testset "`iterate`" begin
        @test iterate(typst``, 1) == (Typst_jll.typst()[1], 2)
        @test iterate(typst``, 2) == nothing
        @test iterate(typst``) == (Typst_jll.typst()[1], 2)
        @test iterate(typst`help`, 2) == ("help", 3)
    end

    @testset "`keys`" begin end

    @testset "`lastindex`" begin
        @test length(typst``) == 1
        @test length(typst`help`) == 2
    end

    @testset "`length`" begin
        @test length(typst``) == 1
        @test length(typst`help`) == 2
    end

    @testset "`read`" begin
        @test read(typst`help`) isa Vector{UInt8}
        @test read(typst`help`, String) isa String
        @test_throws TypstCommandError read(typst``, String)
        @test_throws TypstCommandError read(typst``)
    end

    @testset "`run`" begin
        # TODO: write more tests
        @test_throws TypstCommandError redirect_stderr(() -> run(tc_error), devnull)
        @test_warn "error" try run(tc_error) catch end
    end

    @testset "`setcpuaffinity`" begin end

    @testset "`setenv`" begin end

    @testset "`show`" begin
        @test isnothing(show(devnull, typst``))
        @test isnothing(show(devnull, MIME"text/plain"(), TypstCommandError(typst``)))
    end

    @testset "`showerror`" begin
        @test isnothing(showerror(devnull, TypstCommandError(typst``)))
    end
end

end # TestCommands
