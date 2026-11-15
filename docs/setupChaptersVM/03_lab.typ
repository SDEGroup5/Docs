#show raw: set text(size: 1.2em)

#show raw.where(): code => box(
  fill: luma(90%),
  outset: 0.3em,
  radius: 0.4pt,
)[#code]

= Getting started with the laboratory

== Obtaining the files and perform mandatory changes

First, get the latest compressed archive containing the laboratory files at the url: #link("https://github.com/SDEGroup5/github-actions/archive/refs/tags/v1.0.0.zip")

Next, rename the *`.env.example`* file in just *`.env`*. The file should contain the following content:

```env
DATA_PATH="json/data.json"
```
This is necessary for the program to run correctly.

Finally, copy the content of the downloaded folder to the folder of your repository. After that, open the folder of your repository in Visual Studio Code and, from the Terminal in Visual Studio Code, run:

```sh
git add .
git commit -m "Uploaded lab files"
git push
```

Verify that the upload completed successfully, then you successfully completed the laboratory setup.
