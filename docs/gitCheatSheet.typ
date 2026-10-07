#set page(margin: (top: 1.2em, bottom: 1.2em))
#set text(size: 1.1em)

#align(center)[
  #image("./../img/gitCheatSheet/mdi--git.svg", width: 15%)
  #title("The Git cheat sheet")
]

#show table.cell.where(x: 0): set text(weight: "bold")

#table(
  columns: (40%, 60%),
  align: (x, y) => {
    if (y == 0) {
      center + horizon
    } else {
      left + horizon
    }
  },
  stroke: black,
  table.header([*Command*], [*Explanation*]),
  [git clone \<repository url>], [Clones the repository available to the specified url to the current directory],

  [git add \<file name>],
  [Move a file from the working directory to the staging area. You can use *git add .* to add *all files*, except deleted ones, to the staging area],

  [git status], [Shows the current status of tracked files, whether they are in the working or in the staging area],

  [git stash],
  [Stash the currently non-committed changes. This is useful when you want to change branch without carrying over the changes you made],

  [git stash apply], [Apply the latest stashed changes to the current working directory],

  [git restore --staged \<file name>],
  [Remove the specified file from the staging area, re-adding it to the working directory],

  [git commit],
  [Commit (translated, permanently save) the changes currently in the staging area. *git commit -m "\<commit message>"* can be use to directly pass the commit message as a command argument],

  [git push], [Push the committed changes to a remote repository],

  [git merge \<branch name>],
  [Merges the specified branch in the *current* branch. By default, this will add all commits in the specified branch int the current branch, use *git merge --squash \<branch name>* to merge and squash all commits of the specified merge in a single one],

  [git branch \<new branch name>],
  [Creates a branch with the chosen name. *git branch -a* will show all currently present branches],

  [git checkout \<branch name>], [Move to the branch with the chosen name],
)
