#set page(margin: (top: 1.2em, bottom: 1.2em))

#align(center)[
  #image("./img/gitCheatSheet/mdi--git.svg", width: 15%)
  #title("The Git cheat sheet")
]

#show table.cell.where(x: 0): set text(weight: "bold")

#table(
  columns: (30%, 70%),
  align: (x, y) => {
    if (y == 0) {
      center + horizon
    } else {
      left + horizon
    }
  },
  stroke: black,
  table.header([*Command*], [*Explanation*]),
  [git add \<file>],
  [Move a file from the working directory to the staging area. You can use *git add .* to add *all files*, except deleted ones, to the staging area],

  [git commit],
  [Commit (translated, permanently save) the changes currently in the staging area. *git commit -m "\<commit message>"* can be use to directly pass the commit message as a command argument],

  [],
)
