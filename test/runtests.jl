
using Base: get_extension
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
using Markdown: Markdown
using Test: @testset, @test, detect_ambiguities, detect_unbound_args
using Typstry

const MarkdownExtension = get_extension(Typstry, :MarkdownExtension)

@testset "ExplicitImports.jl" begin
    @test isnothing(check_all_explicit_imports_are_public(Typstry; ignore = (:MD, :Stateful,
        :code_mode, :depth, :escape_raw_string, :indent, :parse, :print_parameters, :show_raw, :workload)))
    @test isnothing(check_all_explicit_imports_via_owners(Typstry))
    @test isnothing(check_all_qualified_accesses_are_public(Typstry))
    @test isnothing(check_all_qualified_accesses_via_owners(Typstry))
    @test isnothing(check_no_implicit_imports(Typstry))
    @test isnothing(check_no_self_qualified_accesses(Typstry))
    @test isnothing(check_no_stale_explicit_imports(Typstry))
end

@testset "`detect_ambiguities` and `detect_unbound_args`" begin
    @test isempty(detect_ambiguities(Typstry))
    @test isempty(detect_unbound_args(Typstry))
end

setdocmeta!(
    Typstry,
    :DocTestSetup,
    :(using Typstry),
    recursive = true
)

doctest(Typstry)
