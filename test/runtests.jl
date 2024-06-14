
using Aqua: test_all, test_ambiguities
using Base: get_extension, disable_logging
using ExplicitImports:
    check_all_explicit_imports_are_public,
    check_all_explicit_imports_via_owners,
    check_all_qualified_accesses_are_public,
    check_all_qualified_accesses_via_owners,
    check_no_implicit_imports,
    check_no_self_qualified_accesses,
    check_no_stale_explicit_imports
using Dates: Dates
using Documenter: DocMeta.setdocmeta!, doctest
using LaTeXStrings: LaTeXStrings
using Logging: Debug, Info, disable_logging
using Markdown: Markdown
using Preferences: set_preferences!
using Test: @testset, @test
using Typstry

_doctest(_module, name) = doctest(_module; manual = "source", testset = "$name.jl Doctests")

_setdocmeta!(_module, x) = setdocmeta!(_module, :DocTestSetup,
    :(using Preferences: set_preferences!; using Typstry; $x; set_preferences!("Typstry", "instability_check" => "error"));
recursive = true)

set_preferences!("Typstry", "instability_check" => "error")

@testset "Aqua.jl" begin
    test_all(Typstry; ambiguities = false)
    test_ambiguities(Typstry)
end

_setdocmeta!(Typstry, nothing)
disable_logging(Info)

@testset "Doctests" begin
    _doctest(Typstry, "Typstry")

    for extension in [:Dates, :LaTeXStrings, :Markdown]
        _module = get_extension(Typstry, Symbol(extension, "Extension"))
        _setdocmeta!(_module, :(using $extension))
        _doctest(_module, extension)
    end
end

disable_logging(Debug)

@testset "ExplicitImports.jl" begin
    @test isnothing(check_all_explicit_imports_are_public(Typstry; ignore = (:MD, :Stateful,
        :code_mode, :depth, :escape_raw_string, :indent, :parse, :print_parameters, :show_raw, :workload)))

    for check in (
        check_all_explicit_imports_via_owners,
        check_all_qualified_accesses_are_public,
        check_all_qualified_accesses_via_owners,
        check_no_implicit_imports,
        check_no_self_qualified_accesses,
        check_no_stale_explicit_imports
    )
        @test isnothing(check(Typstry))
    end
end
