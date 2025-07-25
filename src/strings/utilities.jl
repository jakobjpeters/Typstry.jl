
# """
#     parameters
# """
# const parameters = Dict(
#     :image => [:alt, :fit, :height, :width],
#     :mat => [:align, :augment, :column_gap, :delim, :gap, :row_gap],
#     :raw => [:align, :block, :lang, :syntaxes, :tab_size, :theme],
#     :text => [
#         :alternates, :baseline, :bottom_edge, :cjk_latin_spacing, :costs, :dir,
#         :discretionary_ligatures, :fallback, :features, :fill, :font, :fractions,
#         :historical_ligatures, :hyphenate, :kerning, :lang, :ligatures, :number_type,
#         :number_width, :overhang, :region, :script, :size, :slashed_zero, :spacing,
#         :stretch, :stroke, :style, :stylistic_set, :top_edge, :tracking, :weight
#     ],
#     :vec => [:align, :delim, :gap]
# )

"""
    format(::Union{MIME"application/pdf", MIME"image/png", MIME"image/svg+xml"})

Return the image format acronym corresponding to the given `MIME`.

# Examples

```jldoctest
julia> Typstry.format(MIME"application/pdf"())
"pdf"

julia> Typstry.format(MIME"image/png"())
"png"

julia> Typstry.format(MIME"image/svg+xml"())
"svg"
```
"""
format(::MIME"application/pdf") = "pdf"
format(::MIME"image/png") = "png"
format(::MIME"image/svg+xml") = "svg"

function show_render(io::IO, m::Union{
    MIME"application/pdf", MIME"image/png", MIME"image/svg+xml"
}, x)
    input = tempname()
    output = input * '.' * format(m)

    render(typst_context(io), x; input, output, open = false, ignorestatus = false)
    write(io, read(output))

    nothing
end
