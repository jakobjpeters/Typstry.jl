
using Luxor: Drawing, julia_blue, julia_red, julia_green, julia_purple, sethue, rect, finish

using Luxor

const scale = 2000
const width, height = 0.21 * scale, 0.297 * scale

function make_logo(directory)
    Drawing(width, height, :svg, directory * "logo.svg")

    for (color, (x_min, y_min)) in zip(
        (julia_purple, julia_green, julia_red, julia_blue),
        map(i -> ((0.3 - i) * width, i * height), 0:0.1:0.3)
    )
        sethue(color)
        rect(x_min, y_min, 0.7 * width, 0.7 * height; action = :fill)
    end

    finish()
end

make_logo((@__DIR__) * "/src/assets/")
