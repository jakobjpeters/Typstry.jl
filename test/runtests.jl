
using Typstry

module TestTypstry

import LaTeXStrings, Markdown, Typstry
using Base: get_extension
using Test: @test, @testset
using Typstry: Mode, TypstString

const names = [:LaTeXStrings, :Markdown]
const modules = map(name -> get_extension(Typstry, Symbol(name, :Extension)), names)

test_modes(x, ss) = @testset "modes" begin
    for (mode, s) in zip(instances(Mode), ss)
        test_strings(x, s; mode)
    end
end

test_strings(x, s; kwargs...) = @test TypstString(x; kwargs...) == s

@testset "Typstry" begin
    for (description, descriptions) in [
        "Utilities" => ["Aqua", "Documenter", "ExplicitImports", "JET"],
        "Interface" => ["Strings", "Commands"],
        "Extensions" => map(string, names),
    ]
        @info "Testing $description"
        @testset "$description" begin
            for _description in descriptions
                @testset "$_description" include(joinpath(lowercasefirst(description),
                    "Test" * _description * (description == "Extensions" ? "Extension" : "") * ".jl"))
            end
        end
    end
end

end # TestTypstry
