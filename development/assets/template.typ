#import table: cell, header

#let template(document) = {
    set page(margin: 1em, height: auto, width: auto, fill: white)
    set text(16pt, font: "JuliaMono")
    
    show cell: c => align(horizon, box(inset: 8pt,
        if c.y < 2 { strong(c) }
        else if c.x == 0 { raw(c.body.text, lang: "julia") }
        else { c }
    ))

    document
}

#let f(examples) = table(columns: 8, header(
    cell(colspan: 2)[Julia],
    cell(colspan: 6)[Typst],
    [Value],
    [Type],
    cell(colspan: 2)[`code`], cell(colspan: 2)[`markup`], cell(colspan: 2)[`math`]
), ..examples)
