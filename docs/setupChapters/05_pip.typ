= Venv and pip installation

pip is a package manager that allows to install python libraries in your system: in the lab, pip is used to install pytest, the test environment.

Generally speaking, is a good practice to not install python libraries in the system globally, but it is preferable to install everything in a virtual environment: venv allow to do such operation.

== Venv installation

While venv is *automatically* installed in both *Windows* and *MacOS* upon python installation, this is not the same for Linux.

To install venv in *Debian based* Linux distributions (such as *Ubuntu*), run:

```sh
sudo apt install python3-venv
```

Arch based distribution usually include the package during the normal python installation.

== pip installation

To install pip in *Windows*, run:

```sh
py -m ensurepip --upgrade
```

While to install pip on *Linux* and *MacOS*, run:
```sh
python3 -m ensurepip --upgrade
```

== Verify the installation in Windows

To verify you successfully installed both the requirements, go into the root of your repository and run:

```sh
py -m venv .venv
```

and then:

```sh
.venv\Scripts\activate.bat
```

Finally, run:

```sh
pip install -r app/requirements.txt
```

=== Verify the installation in Linux and MacOS

To verify you successfully installed both the requirements, go into the root of your repository and run:

```sh
python3 -m venv .venv
```

Then run ():

```sh
source .venv/bin/activate
```

Finally, run:

```sh
pip install -r app/requirements.txt
```
