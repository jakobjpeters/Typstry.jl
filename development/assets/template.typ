
#import table: cell, header

#let template(document) = {
    set page(margin: 1em, height: auto, width: auto, fill: white)
    set text(16pt, font: "JuliaMono")

    show cell: c => align(horizon, box(inset: 8pt,
        if c.y < 2 { strong(c) }
        else {
            let x = c.x
            if x == 2 or x == 4  { c }
            else { raw({ c.body.text }, lang: { if x < 2 { "julia" } else if x == 3 { "typ" } }) }
        }
    ))

    document
}

#let module(name, examples) = {
    [= #name]
    table(columns: 5, header(
        cell(colspan: 3)[Julia], cell(colspan: 2)[Typst],
        [Value], [Type], [Settings], [Code], [Render]
    ), ..examples)
}
