#import "common.typ": authors, course, date, labName, labNumber, linkColor, mainColor, university

#let cover(title) = {
  set document(
    title: [#title - #course - #university],
    author: (
      authors.lorenzoc.name + " " + authors.lorenzoc.surname + " - Student Id " + authors.lorenzoc.stid,
      authors.lorenzor.name + " " + authors.lorenzor.surname + " - Student Id " + authors.lorenzor.stid,
      authors.matteo.name + " " + authors.matteo.surname + " - Student Id " + authors.matteo.stid,
    ),
    description: [Laboratory presentation for the Service Design and Engineering course at #university],
  )

  set page(
    paper: "presentation-16-9",
    margin: (top: 0pt, left: 0pt, right: 0pt, bottom: 0pt),
    background: rect(fill: mainColor, width: 103%, height: 105%),
  )

  set text(fill: white)
  show grid: set text(size: 1.3em)
  align(center + horizon)[
    #text(size: 3em)[#course]
    #line(length: 80%, stroke: white)
    #text(size: 2em)[#title]
    #v(2em)
    #grid(
      grid.vline(x: 1, start: 0, stroke: white),
      columns: (30%, 30%),
      align: (x, y) => {
        if (x == 0) {
          right
        } else if (x == 1) {
          left
        }
      },
      inset: 0.4em,
      [*Team members*],
      [#authors.lorenzoc.name #authors.lorenzoc.surname (#authors.lorenzoc.stid)],
      [], [#authors.lorenzor.name #authors.lorenzor.surname (#authors.lorenzor.stid)],
      [],
      [#authors.matteo.name #authors.matteo.surname (#authors.matteo.stid)],
      [],
      [#authors.david.name #authors.david.surname (#authors.david.stid)],
    )
  ]

  align(bottom + center)[
    #date \ - \ University of Trento
    #v(2em)
  ]
}

#let slide(title, part, body) = {
  show link: set text(fill: linkColor)
  pagebreak()
  set page(
    paper: "presentation-16-9",
    margin: (top: 0pt, left: 0pt, right: 0pt, bottom: 0pt),
    background: rect(fill: white, width: 103%, height: 105%),
  )

  align(top)[
    #rect(fill: mainColor, width: 110%, height: 4.5em)[
      #align(horizon)[
        #h(2em) #text(fill: white, size: 2em)[Part #part - #title]
      ]

    ]
  ]

  align(center + horizon)[
    #box(width: 95%, height: 76%)[#align(top + left)[#body]]
  ]

  align(bottom)[
    #show grid: set text(size: 1.1em, fill: white, weight: "medium")
    #grid(
      align: (x, y) => {
        if (x == 0) {
          left
        } else if (x == 1) {
          center
        } else {
          right
        }
      },
      fill: mainColor,
      columns: (30%, 40%, 30%),
      inset: 1em,
      stroke: mainColor,
      [#course],
      [Laboratory #labNumber: #labName],
      [Slide #context (counter(page).display()) of #context (counter(page).final().at(0))],
    )
  ]
}

#let hint(body, txtSize: 1.3em) = {
  block(
    fill: rgb("1e88e5").transparentize(80%),
    inset: 10pt,
    radius: 6pt,
    stroke: 1pt + rgb("90caf9"),
    width: 100%,
  )[
    #text(size: txtSize)[
      #body
    ]
  ]
}
