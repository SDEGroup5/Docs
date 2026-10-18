#import "../Part2PartialDraft/lib/common.typ": course, labNumber, labName
#import "../Part2PartialDraft/lib/commonSlide.typ": cover, slide

#cover([Laboratory #labNumber: #labName])

#let body(content) = {
  set text(size: 19pt)
  set par(leading: 0.4em)
  set list(spacing: 9pt)
  set enum(spacing: 9pt)
  content
}
#let ask(content) = {
  v(8pt)
  text(size: 17pt, weight: "bold", fill: rgb("B10B25"), content)
}
#let code(content) = {
  set text(size: 18pt)
  content
}
#show raw: code => box(
  fill: luma(90%),
  outset: 0.3em,
  radius: 0.4pt,
)[#code]

#slide("Docker image building with GitHub Actions")[
  #body[

  ]
]

#slide("Packaging application")[
  #body[
   .
  ]
]

#slide("Publication workflow")[
  #body[

  ]
]
#slide("GitHub Container Registry")[
  #body[
   
  ]
]
#slide("Running the published image")[
  #body[
   
  ]
]
#slide("Exercise")[
  #body[
   
  ]
]

