#show raw: set text(size: 1.2em)

#show raw.where(): code => box(
  fill: luma(90%),
  outset: 0.3em,
  radius: 0.4pt,
)[#code]

= Visual Studio Code setup

While the usage of #link("https://code.visualstudio.com/")[Visual Studio Code] is not strictly mandatory, it is the fastest way to automatically configure the necessary permissions to push the changes made in your copy of the project files directly to your GitHub repository.

If you prefer to setup GitHub in a general way, so that you can push via your preferred console or IDE-integrated console, please see @ssh.

== Installing Visual Studio Code

To install Visual Studio Code in your machine go to the #link("https://code.visualstudio.com/download")[official website] and download the version corresponding to your operating system.

When the package has been downloaded, install it as you would do with any other application.

If your are using a *Debian based* Linux distribution such as *Ubuntu* you can install the downloaded *.deb* file by execute in Terminal (change *\<downloaded-deb-file>*) with the actual deb name:

```sh
sudo dpkg -i <downloaded-deb-file>.deb
```

Confirm when asked to add Microsoft repositories.

== Signing into GitHub from Visual Studio Code

The easiest way to enable Visual Studio Code integrated support for GitHub is by pushing a commit in the GitHub service.

To do that:
- *Open* the *Visual Studio Code* application;
- *Click* on *File* in the upper-left corner;
- *Click* *Open folder* in the opened menu;
- *Navigate* to the cloned repository and click *Open*. *Note*: you *MUST* navigate your file system until you see the *README.md* file in the cloned repository;
- *Open* the *README.md* file and perform any change;
- *Click* the *Terminal* window in the upper menu of Visual Studio Code;
- *Click* *New terminal* in the opened menu;
- *Execute* the following commands in the opened terminal:
  ```sh
  git add .
  git commit -m "Changes to README.md"
  git push
  ```

You will be prompted to log in to GitHub. Follow the steps shown on screen and in your web browser. If the procedure completed successfully, you will se the change you made in the GitHub page of your repository. Any future operations need to be performed from this terminal if they require GitHub authentication.

== Setting up general GitHub access <ssh>

This step is *NOT MANDATORY* if you already logged in to GitHub in Visual Studio Code. If you wish to not use the mentioned editor, however, you can configure GitHub access so it is globally available in your system. To do that, please follow the guide in the #link("https://docs.github.com/en/authentication/connecting-to-github-with-ssh")[official GitHub website].
