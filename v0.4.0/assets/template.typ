
#import table: cell, header

#let template(document) = {
    set page(margin: 1em, height: auto, width: auto, fill: white)
    set text(16pt, font: "JuliaMono")
    
    show cell: c => align(horizon, box(inset: 8pt,
        if c.y < 2 { strong(c) }
        else {
            let x = c.x
            if x in (3, 5, 7) { c }
            else { raw({ c.body.text }, lang: {
                if x < 2 { "julia" } else if x == 2 { "typc" } else if x == 4 { "typ" } else { "typm" }
            } ) }
        }
    ))

    document
}

#let f(examples) = table(columns: 8, header(
    cell(colspan: 2)[Julia],
    cell(colspan: 6)[Typst],
    [Value],
    [Type],
    cell(colspan: 2)[Code], cell(colspan: 2)[Markup], cell(colspan: 2)[Math]
), ..examples)
