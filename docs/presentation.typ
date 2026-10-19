#import "./lib/common.typ": course, labName, labNumber
#import "./lib/commonSlide.typ": cover

#cover([Laboratory #labNumber: #labName])

#show raw: code => box(
  fill: luma(90%),
  outset: 0.3em,
  radius: 0.4pt,
)[#code]

#include "./topics/topic1.typ"
#include "./topics/topic2.typ"
#include "./topics/topic3.typ"
