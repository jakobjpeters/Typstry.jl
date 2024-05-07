
using Base: Iterators.Stateful
using Typstry

const modes = instances(Mode)
const cases = Stateful([
    'a' => AbstractChar,
    1.2 => AbstractFloat,
    [true 1; 1.0 [Any[true 1; 1.0 nothing]]] => AbstractMatrix,
    typst"a" => AbstractString,
    [true, [1]] => AbstractVector,
    true => Bool,
    1 + 2im => Complex,
    π => Irrational,
    nothing => Nothing,
    1:4 => OrdinalRange{<:Integer, <:Integer},
    1 // 2 => Rational,
    r"[a-z]" => Regex,
    1 => Signed,
    text"[\"a\"]" => Text,
    TypstText("[\"a\"]") => TypstText,
])

open("show.typ"; truncate = true) do file
    print(file, "\n#set page(paper: \"a4\", margin: 1em)\n#set text(9pt, font: \"JuliaMono\")\n\n#let julia(s) = raw(s, lang: \"julia\")\n\n")
    for s in [
        "#table(align: horizon, columns: 5",
        "table.cell(rowspan: 2)[*Value*]",
        "table.cell(rowspan: 2)[*Type*]",
        "table.cell(colspan: 3, align: center)[*`Mode`*]"
    ]
        print(file, s, ",\n    ")
    end
    join(file, map(mode -> "[*`$mode`*]", modes), ", ")
    println(file, ",")

    for (v, t) in cases
        _modes = Stateful(modes)
        is_matrix, is_vector = t <: AbstractMatrix, t <: AbstractVector && !(t <: OrdinalRange)

        print(file, "    julia(")

        if is_vector print(file, "\"[true [1]]\"")
        elseif is_matrix print(file, "\"[true 1; 1.0 Any[[\\n    true 1; 1.0 nothing\\n]]]\"")
        elseif t <: Text print(file, "\"Text(\\\"[\\\\\\\"a\\\\\\\"]\\\")\"")
        else show(file, repr(v))
        end

        print(file, "), `", t, "`,", is_vector || is_matrix ? "\n        " : " ")

        for mode in _modes
            s = TypstString(v, :mode => mode, :depth => 2)

            if mode == math print(file, "\$", s, "\$")
            else
                print(file, "[")
                mode == code && print(file, "#")
                print(file, s, "]")
            end

            isempty(_modes) || print(file, ", ")
        end

        isempty(cases) || print(file, ",\n")
    end

    println(file, "\n)")
end

run(typst`compile show.typ src/assets/show.png`)
