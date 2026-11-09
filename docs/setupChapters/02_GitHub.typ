#show raw: set text(size: 1.2em)

#show raw.where(): code => box(
  fill: luma(90%),
  outset: 0.3em,
  radius: 0.4pt,
)[#code]

= GitHub Setup

While Git is designed to work offline, you can push your codebase to a specialized hosting service: this also helps in case you want to code with other people. Several services are available, this laboratory will use #link("https://github.com/")[GitHub].

== Create an account

Follow this section only if you currently don't have an account with GitHub.

#figure(
  image("/img/setupGuide/mainPage.png"),
  caption: "GitHub landing page",
) <gmp>

#place(dy: -37%, dx: 79.3%)[
  #rect(stroke: 2pt + red, width: 5%)
]

To create an account, open a web browser and connect to #link("https://github.com/"), then click the top right black box named *Sign Up*, as shown on @gmp. In the new screen follow the guided procedure and create the account: take note of the *username* you choose, as it will be needed in the next steps.

== Setup Git with the GitHub email

// global.email and global.username

When an important change has been implemented in the codebase, you should *commit* such changes and push it on GitHub. However, in order to commit, Git needs to know your identity, specifically your *username* and *email*. To allow GitHub to recognize who committed the code, it is a good practice to set as username and email the information used to create the GitHub account.

Firstly, to setup your username, open a new *terminal* (in *Linux*, in *Windows* a *Command Prompt* instance can be used while on *MacOS* go to your application and open *Terminal*), then paste the following command, replacing *\<your-username>* with your *actual username*:

```sh
git config --global user.name "<your-username>"
```

To configure the email, a similar process has to be followed but, while using the email you registered in GitHub will work, is *strongly suggested* to not use it and use the *GitHub generated one* instead.

#figure(
  kind: image,
  grid(
    columns: (39%, 61%),
    align: center + horizon,
    gutter: 1em,
    [
      #image("/img/setupGuide/emailStep1.png")
    ],
    [
      #image("/img/setupGuide/emailStep2.png")
    ],
  ),
  caption: "GitHub generated email discovery steps",
) <github-email>

#place(dy: -39%, dx: 35%)[
  #rect(stroke: 2pt + red, width: 4%, height: 3%)
]

#place(dy: -19%, dx: 18%)[
  #rect(stroke: 2pt + red, width: 15%, height: 2%)
]

#place(dy: -15%, dx: 42%)[
  #rect(stroke: 2pt + red, width: 15%, height: 2%)
]

#place(dy: -22%, dx: 74%)[
  #rect(stroke: 2pt + red, width: 26%, height: 2%)
]

To find your *GitHub email*, go to the #link("https://github.com/")[GitHub] website, log in to the service using your account, then click your *profile icon* in the upper-right corner of the page and then the *Settings* options. On the lateral panel, click *Emails* and copy the generated email you can find in the page text as shown in @github-email.

Once you got the email, please run the following command replacing *\<your-email>* with the email you just copied:

```sh
git config --global user.email "<your-email>"
```

#pagebreak()

== Creating a public repository

#figure(
  kind: image,
  grid(
    columns: (39%, 61%),
    align: center + horizon,
    gutter: 1em,
    [
      #image("/img/setupGuide/emailStep1.png")
    ],
    [
      #image("/img/setupGuide/newRepoLink.png")
    ],
    grid.cell(colspan: 2)[
      #image("/img/setupGuide/repoCreation.png", width: 60%)
    ],
  ),
  caption: "GitHub public repository creation steps",
) <repo-creation>

#place(dy: -71%, dx: 35%)[
  #rect(stroke: 2pt + red, width: 4%, height: 3%)
]

#place(dy: -61.5%, dx: 18%)[
  #rect(stroke: 2pt + red, width: 15%, height: 2%)
]

#place(dy: -58.5%, dx: 96%)[
  #rect(stroke: 2pt + red, width: 5%, height: 2%)
]

#place(dy: -28.5%, dx: 40%)[
  #rect(stroke: 2pt + red, width: 19%, height: 3%)
]

#place(dy: -19.3%, dx: 32%)[
  #rect(stroke: 2pt + red, width: 38.5%, height: 3%)
]

#place(dy: -13.5%, dx: 32%)[
  #rect(stroke: 2pt + red, width: 38.5%, height: 3%)
]

The next step will create a *public repository* on your GitHub account.

From the #link("https://github.com/")[GitHub] website, log in to the service using your account, then click your *profile icon* in the upper-right corner of the page and then the *Repositories* options.

On the next page, click the *New* option, then assign a name to the repository. Please, *be sure* to:
- *Set* the *visibility* to *Public*;
- *Activate* the *Add README* option.

The second option will automatically create an example README file, it is to avoid unnecessary complication due to the fact that, without the first commit already made, you will clone an empty repository.

For displayed steps, take a look at @repo-creation

#pagebreak()

== Cloning a repository

#figure(
  image("/img/setupGuide/repoLink.png"),
  caption: "Repository clone link retrieval",
) <repo-link-copy>

#place(dy: -31.5%, dx: 86%)[
  #rect(stroke: 2pt + red, width: 13%, height: 4%)
]

#place(dy: -19%, dx: 56%)[
  #rect(stroke: 2pt + red, width: 42%, height: 3.5%)
]

Once you have created a repository, you should be automatically redirected to such repository. If not, just go again in the *Repositories* menu as shown in the first picture of @repo-creation: you should see your newly created repository.

To clone the repository locally, please click the *Code* green button, then copy the url, as shown in the example in @repo-link-copy.

Finally, move in your preferred folder, open a terminal in such folder: most of the time you can find an option in right-click menu of your operating system. In case you are using *MacOS*, you can find how to do it in the #link("https://support.apple.com/en-gb/guide/terminal/trmlb20c7888/mac")[Official Apple support] website. In *Windows* you can write *cmd* in the Windows explorer path bar.

In case you are not able to open a Terminal in such way, please open your terminal application and move between directories via the *cd* command. For example, supposing that your folder is in \ "C:\\Users\\user\\Desktop\\Folder", just run:

```cmd
cd C:\Users\user\Desktop\Folder
```

When you are in the folder, copy and execute the following command by having care of changing *\<your-url>* with the link you copied from GitHub:

```sh
git clone <your-link>
```
