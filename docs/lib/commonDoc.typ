#import "./common.typ": academicYear, authors, course, date, groupColor, labNumber, linkColor, mainColor, university

#let firstPage(titleText) = {
  show link: set text(fill: linkColor)
  set document(
    title: [#titleText - #course - #university],
    author: (
      authors.lorenzoc.name + " " + authors.lorenzoc.surname + " - Student Id " + authors.lorenzoc.stid,
      authors.filippo.name + " " + authors.filippo.surname + " - Student Id " + authors.filippo.stid,
      authors.lorenzor.name + " " + authors.lorenzor.surname + " - Student Id " + authors.lorenzor.stid,
      authors.matteo.name + " " + authors.matteo.surname + " - Student Id " + authors.matteo.stid,
      authors.david.name + " " + authors.david.surname + " - Student Id " + authors.david.stid,
    ),
    description: [#titleText document for the Service Design and Engineering course laboratory at #university],
  )

  set page(
    margin: 0em,
  )

  grid(
    columns: (35%, 65%),
    [#rect(fill: groupColor, width: 100%, height: 105%)],

    [
      #align(center + top)[
        #v(2em)
        #text(size: 2em, weight: "bold")[*#course*]
      ]

      #align(center + horizon)[#image("/img/mdi--gear-outline.svg", width: 30%) #text(
          size: 2em,
          weight: "bold",
        )[Laboratory #labNumber \ #titleText]]

      #v(10em)

      #align(center + horizon)[
        #grid(
          grid.vline(x: 1, start: 0, stroke: black),
          columns: (30%, 40%),
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
          [], [#authors.filippo.name #authors.filippo.surname (#authors.filippo.stid)],
          [], [#authors.lorenzor.name #authors.lorenzor.surname (#authors.lorenzor.stid)],
          [],
          [#authors.matteo.name #authors.matteo.surname (#authors.matteo.stid)],
          [],
          [#authors.david.name #authors.david.surname (#authors.david.stid)],
        )
      ]

      #align(center + bottom)[
        *#university - AY #academicYear*
        #v(2em)
      ]

    ],
  )
}

#let indexPage(imageList: true, tableList: true) = {
  set page(
    margin: auto,
    footer: [
      #align(center)[#context [#counter(page).display("1 of 1", both: true)]] \
      #place(dx: -71pt, dy: -2pt)[#rect(height: 55%, width: 135%, stroke: none, fill: groupColor)]
    ],
  )

  show outline.entry.where(level: 1): it => {
    v(12pt, weak: true)
    text(size: 1.2em)[*#it*]
  }

  outline(depth: 4, title: text(size: 2em)[#v(0em) Index #v(0.5em)], indent: 1em)

  if (imageList == true) {
    text(size: 2em)[#v(0.5em) *Images* #v(-0.5em)]

    show outline: set text(weight: "thin")
    outline(
      title: [],
      target: figure.where(kind: image),
    )
  }

  if (tableList == true) {
    text(size: 2em)[#v(0.5em) *Tables* #v(-0.5em)]

    show outline: set text(weight: "thin")
    outline(
      title: [],
      target: figure.where(kind: table),
    )
  }
}

#let docBody(title, body) = {
  show figure: set block(breakable: true)
  show link: it => underline(text(fill: linkColor)[#it])
  show ref: rf => underline(text(fill: mainColor)[#rf])

  set heading(numbering: "1.")

  show heading.where(level: 1): h => {
    set text(size: 1.5em)
    pagebreak()
    h
    v(0.25em)
  }

  set page(
    margin: auto,
    header: [

      #grid(
        columns: (33%, 33%, 33%),
        align: (x, y) => {
          if x == 0 {
            left + horizon
          } else if x == 1 {
            center + horizon
          } else {
            right + horizon
          }
        },
        [*Laboratory #labNumber*], [*#title*], [*#date*],
      )

      #line(length: 100%)


    ],
    footer: [
      #align(center)[#context [#counter(page).display("1 of 1", both: true)]] \
      #place(dx: -71pt, dy: -2pt)[#rect(height: 50%, width: 135%, stroke: none, fill: groupColor)]
    ],
  )

  body
}
