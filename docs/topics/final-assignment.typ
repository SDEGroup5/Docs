#import "../lib/commonSlide.typ": slide

#slide("Final assignment", 4)[
  #align(center + horizon)[
    #text(size: 3em)[*Part 4*\ *Final assignment*]
  ]
]

#slide("Final assignment", 4)[
  #set text(size: 1.5em)

  #grid(
    columns: (50%, 50%),
    gutter: 1em,
    align: (x, y) => {
      if (x == 0) {
        left + horizon
      } else {
        center + horizon
      }
    },
    [
      - *Open* the file `json/data.json`
      - *Complete* the file by inserting your name and surname
      - *Open* the file `compose.yml`
      - *Modify* the file by changing the image path to the one of your repository, as done in the *last exercise of Part 3*
      - *Run* the application by executing ```sh docker compose up```
      - *Make* a request to the application by entering in the browser the address #link("localhost:5000/json/getData")
      - *Take* a screenshot of:
        + The `compose.yml` file
        + The response shown in the *browser*
    ],
    [
      #figure(
        caption: "Screenshot of the docker compose file",
        image("/img/final-assignment/code.png"),
      )
    ],
  )
]
