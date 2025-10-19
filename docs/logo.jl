
using Luxor:
    Drawing, PathCurve, PathLine, PathMove, Path, Point,
    julia_blue, julia_green, julia_purple, julia_red, paper_sizes,
    drawpath, finish, poly, rect, setfont, sethue, settext

const logo = joinpath(@__DIR__, "source", "assets", "logo.svg")
const sheet_width, sheet_height = paper_sizes["A4"] ./ 4
const spacing = 0.2
const drawing_width, drawing_height = (3 * spacing + 1) .* (sheet_width, sheet_height)
const fold_height = spacing * sheet_height

path_curves(xs::NTuple{3, NTuple{2, Float64}}...) = map(x -> PathCurve(Point.(x)...), xs)

Drawing(drawing_width, drawing_height, :svg, logo)

for (hue, top_left) in zip(
    (julia_purple, julia_green, julia_red, julia_blue),
    map(i -> Point((3 * spacing - i) * sheet_width, i * sheet_height), 0:spacing:(3 * spacing))
)
    bottom_left = top_left + Point(0, sheet_height)
    bottom_right = bottom_left + Point(sheet_width, 0)
    top_rights = (top_left + Point(sheet_width, 0)) .+ (
        Point(0, fold_height), Point(-fold_height, 0)
    )

    sethue(hue)
    poly([top_left, bottom_left, bottom_right, top_rights...]; action = :fill)
    sethue(@. 0.25 * (1 - hue) + hue)
    poly([top_rights..., Point(top_rights[2].x, top_rights[1].y)]; action = :fill)
end

sethue("white")
setfont("Buenard Bold", drawing_height / 2)
settext(
    "t",
    Point(sheet_width / 2, drawing_height - sheet_height / 2);
    halign = "center",
    valign = "center"
)

finish()

using Luxor: preview
preview()
