#show raw: set text(size: 1.2em)

#show raw.where(): code => box(
  fill: luma(90%),
  outset: 0.3em,
  radius: 0.4pt,
)[#code]

= Git Installation

Git is a Version Control System originally developed by #link("https://it.wikipedia.org/wiki/Linus_Torvalds")[*Linus Torvalds*]. The following chapters will explain how to install Git in your operating system. You can find a cheat sheet with the most common Git commands at the #link("https://sdegroup5.github.io/")[laboratory website], under the *Resources* section.

== Linux

If you are using a *Debian based* Linux distribution. such as *Ubuntu*, Git is available directly from the Ubuntu repositories. Please run the following command to install it:

```sh
sudo apt install git
```

In case you are running an *Arch based* operating system, the pacman package manager can be used to install the software:

```sh
sudo pacman -S git
```

For additional system please take a look to the #link("https://git-scm.com/install/linux")[official website]

== Windows

If you are using the *Windows* operating system, please download the installer from the #link("https://github.com/git-for-windows/git/releases/download/v2.56.0.windows.4/Git-2.56.0.4-64-bit.exe")[official website]. After the download has finished, install it as a normal application.

Additional information can be found in the #link("https://git-scm.com/install/windows")[official installation page] of Git.

== MacOS

Unfortunately, no updated binary installer are available for this operating system. However, you will be able to install the software by *compiling from source* or by using the *Homebrew* package manager.

To install Homebrew, please follow the instruction at the #link("https://brew.sh/")[official website of the project].

After that, you will be able to install git by executing:

```sh
brew install git
```

Additional information can be found in the #link("https://git-scm.com/install/mac")[official installation page] of Git.
