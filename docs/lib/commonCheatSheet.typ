#import "common.typ": authors, course, university

#let cover(titleText, img, setDoc: true) = {
  if (setDoc) {
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
    set text(size: 1.1em)
  }

  align(center)[
    #image(img, width: 20%)
    #title(titleText)
  ]
}
