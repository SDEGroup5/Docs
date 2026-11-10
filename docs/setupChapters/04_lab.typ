#show raw: set text(size: 1.2em)

#show raw.where(): code => box(
  fill: luma(90%),
  outset: 0.3em,
  radius: 0.4pt,
)[#code]

= Getting started with the laboratory

== Cloning the laboratory repository

The last step is to clone the laboratory repository and copy it into your repository folder. To clone the repository, execute the following command in the folder where you want the files:

```sh
git clone https://github.com/SDEGroup5/github-actions.git
```

Next, copy the content of the downloaded folder to the folder of your repository. After that, open the folder of your repository in Visual Studio Code and, from the Terminal in Visual Studio Code, run:

```sh
git add .
git commit -m "Uploaded lab files"
git push
```

Verify that the upload completed successfully, then you successfully completed the laboratory setup.
