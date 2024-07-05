
using Typstry

module TestTypstry

using Base: get_extension
using LaTeXStrings: LaTeXStrings
using Markdown: Markdown
using Test: @test, @testset
using Typstry: Typstry, Mode, TypstString

const names = [:LaTeXStrings, :Markdown]
const modules = map(name -> get_extension(Typstry, Symbol(name, :Extension)), names)

test_modes(x, ss) = @testset "modes" begin
    for (mode, s) in zip(instances(Mode), ss)
        test_strings(x, s; mode)
    end
end

test_strings(x, s; kwargs...) = @test TypstString(x; kwargs...).text == s

@testset "Typstry" begin
    for (description, descriptions) in [
        "Packages" => ["Aqua", "Documenter", "ExplicitImports"],
        "Interface" => ["Strings", "Commands"],
        "Extensions" => map(string, names)
    ]
        @info "Testing $description"
        @testset "$description" begin
            for _description in descriptions
                @testset "$_description" include("Test" * _description * (
                    description == "Extensions" ? "Extension" : ""
                ) * ".jl")
            end
        end
    end
end

end # TestTypstry
