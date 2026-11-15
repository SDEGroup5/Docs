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
      - *Open* the file `.github/workflows/final-exercise.yml`
      - *Complete* the workflow by inserting the steps to:
        - *Test* the application *with the script* completed during the *Part 2*
        - *Publish* the Docker image to the GitHub Registry (GHCR)
      - *Compile* the form by attaching a screenshot of the successfully executed action:
        - *Go* to your repository
        - *Go* to the "Actions" tab
        - *Click* the run regarding the final assignment
        - *Click* the *`exercise`* job
        - *Take* a *screenshot* of the page, including *all* steps and your *user profile picture*
    ],
    [
      #figure(
        caption: "Screenshot of the final workflow",
        image("/img/final-assignment/code.png"),
      )
    ],
  )
]
