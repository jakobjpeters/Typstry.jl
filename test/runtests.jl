
using Typstry

module TestTypstry

import LaTeXStrings, Markdown
using Base: get_extension
using Test: @test, @testset
using Typstry

const names = [:LaTeXStrings, :Markdown]
const modules = map(name -> get_extension(Typstry, Symbol(name, :Extension)), names)

test_modes(x, ss) = @testset "modes" begin
    for (mode, s) in zip(instances(Mode), ss)
        test_strings(x, s; mode)
    end
end

function test_strings(x, _string::String; typst_context...)
    @test String(TypstString(x; typst_context...)) == _string
    @test isnothing(render(x; typst_context...))
end
function test_strings(x, typst_string::TypstString; typst_context...)
    test_strings(x, String(typst_string); typst_context...)
end

@testset "Typstry" begin
    for (description, descriptions) in [
        "Utilities" => ["Aqua", "Documenter", "ExplicitImports", "JET"],
        "Interface" => ["Strings", "Commands", "Contexts"],
        "Extensions" => map(string, names),
    ]
        @info "Testing $description"
        @testset "$description" begin
            for _description in descriptions
                @testset "$_description" include(joinpath(lowercasefirst(description),
                    "Test" * _description * (description == "Extensions" ? "Extension" : "") * ".jl"
                ))
            end
        end
    end
end

end # TestTypstry
