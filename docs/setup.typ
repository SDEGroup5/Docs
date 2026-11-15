#import "lib/commonDoc.typ": docBody, firstPage, indexPage

#let title = "Setup instructions"

#firstPage(title)

#indexPage(tableList: false)

#docBody(title)[
  #include "setupChapters/01_Git.typ"
  #include "setupChapters/02_GitHub.typ"
  #include "setupChapters/03_code.typ"
  #include "setupChapters/04_pip.typ"
  #include "setupChapters/05_docker.typ"
  #include "setupChapters/06_lab.typ"
]
