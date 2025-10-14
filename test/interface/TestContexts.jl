
module TestContexts

using Test: @testset, @test
using Typstry

const context_error = ContextError(String, Symbol, :value)

@testset "`ContextErrors`" begin
    @testset "`ContextError`" begin
        @test context_error isa ContextError
    end

    @testset "`showerror`" begin
        @testset isnothing(showerror(devnull, context_error))
    end

    @testset "`show`" begin
        @testset isnothing(show(devnull, MIME"text/plain"(), context_error))
    end
end

@testset "`DefaultIOs`" begin
    @testset "`DefaultIO`" begin
        @test DefaultIO() isa DefaultIO
        @test DefaultIO()() isa IOContext
    end

    @testset "`show`" begin
        @test isnothing(show(devnull, DefaultIO()))
    end
end

@testset "`TypstContext`" begin
    @test TypstContext() isa TypstContext
    @test context isa TypstContext
    @test IOContext(IOContext(stdout), TypstContext()) isa IOContext
    @test copy(TypstContext()) isa TypstContext
    @test Any <: eltype(TypstContext())
    @test getkey(TypstContext(), :key_1, :key_2) == :key_2
    @test get(TypstContext(), :key, :value) == :value
    @test get(() -> :value, TypstContext(), :key) == :value
    @test isnothing(iterate(TypstContext()))
    @test length(TypstContext()) == 0
    @test mergewith(*, TypstContext()) isa TypstContext
    @test merge!(TypstContext()) isa TypstContext
    @test merge(TypstContext()) isa TypstContext
    @test setindex!(TypstContext(), :value, :key) == TypstContext(; key = :value)
    @test isnothing(show(devnull, TypstContext()))
    @test sizehint!(TypstContext(), 0) isa TypstContext
end

end # TestContexts
