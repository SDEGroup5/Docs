#import "lib/commonDoc.typ": docBody, firstPage, indexPage

#let title = "Setup instructions (with VM)"

#firstPage(title)

#indexPage(tableList: false)

#docBody(title)[
  #include "setupChaptersVM/01_GitHub.typ"
  #include "setupChaptersVM/02_code.typ"
  #include "setupChaptersVM/03_lab.typ"
]
