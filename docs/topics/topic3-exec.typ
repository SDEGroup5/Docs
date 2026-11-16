#import "../lib/commonSlide.typ": hint, slide
#import "../lib/common.typ": mainColor


#let body(content, compact: false) = {
  set text(size: 19pt)
  set par(leading: 0.4em)
  set list(spacing: if compact { 10pt } else { 9pt })
  set enum(spacing: if compact { 10pt } else { 9pt })
  if compact {
    set par(spacing: 0pt)
    show raw: it => text(font: "DejaVu Sans Mono", size: 0.9em, it.text)
    content
  } else {
    content
  }
}

#let panelColor = rgb("F7F7F8")
#let card(title, content) = block(
  width: 100%, height: 155pt, inset: 18pt, radius: 8pt, fill: panelColor,
)[
  #text(size: 23pt, weight: "bold", fill: mainColor)[#title]
  #v(18pt)
  #text(size: 18pt)[#content]
]

#let workflowPanel(content, focus: (), size: 16pt) = block(
  width: 100%,
  inset: 12pt,
  radius: 7pt,
  fill: panelColor,
)[
  #show raw: it => {
    set text(size: size, font: "DejaVu Sans Mono")
    set par(spacing: 0pt)
    let start = 0
    while start < it.lines.len() {
      let focused = focus.contains(start + 1)
      let end = start + 1
      while end < it.lines.len() and focus.contains(end + 1) == focused {
        end += 1
      }
      block(
        width: 100%,
        above: 0pt,
        below: 0pt,
        stroke: if focused { 2pt + red },
      )[
        #for row in it.lines.slice(start, end) {
          block(
            width: 100%, above: 0pt, below: 0pt,
            inset: (x: 6pt, y: 2pt),
          )[ #row.body ]
        }
      ]
      start = end
    }
  }
  #content
]

#let result(content) = block(
  width: 100%, inset: 12pt, radius: 6pt,
  fill: mainColor.lighten(94%),
)[
  #set par(spacing: 0pt)
  // Two columns: when the text wraps, the new line stays aligned with the
  // text, not under the RESULT label.
  #grid(
    columns: (auto, 1fr),
    column-gutter: 10pt,
    align: (left + horizon, left + horizon),
    text(size: 15pt, weight: "bold", fill: mainColor)[RESULT],
    text(size: 17pt)[#content],
  )
]


#let screenshot(path, width: 100%) = box(
  stroke: 1pt + luma(75%), radius: 6pt, clip: true,
)[#image(path, width: width)]

#show raw: code => box(
  fill: luma(90%),
  outset: 0.3em,
  radius: 0.4pt,
)[#code]


#slide("Building and Publishing with GitHub Actions", 3)[
  #align(center + horizon)[
    #text(size: 3em)[*Part 3*\ *Building and Publishing with GitHub Actions*]
  ]
]

#slide("From source code to a downloadable executable", 3)[
  #body(compact: true)[
    In Part 2, GitHub Actions tested the application on every push.
    Now we let it compile the application and keep the result.
    #v(22pt)
    #grid(columns: (1fr, 1fr, 1fr), column-gutter: 16pt,
      card("Nuitka", [Compiles the Python application into a single Linux executable.]),
      card("Docker", [Provides the build environment, with Python and Nuitka ready to use.]),
      card("GitHub Actions", [Runs the build on every push and keeps the executable as an artifact.]),
    )
    #v(22pt)
    #result[On every push: Docker provides the environment, Nuitka compiles the app, GitHub Actions 
    saves the executable as a downloadable artifact.]
  ]
]

#slide("Why compile with GitHub Actions?", 3)[
  #body(compact: true)[
    Part 1 showed why CI helps: clean, automatic and reproducible runs.
    For a compiled program, it also means:
    #v(22pt)
    #list(
      [*No local setup:* Python and Nuitka live in the build image, not on our laptops.],
      [*Any OS:* developers on Windows or Mac still get a Linux executable.],
      [*Traceable:* each executable is linked to its commit, and the run keeps the build logs.],
      [*Early feedback:* if compilation breaks, the run fails and the commit is marked as failed.],
    )
    #v(22pt)
    // Before/after strip, in place of a RESULT box.
    #let compareBox(title, fill, content) = block(
      width: 100%, inset: 12pt, radius: 6pt, fill: fill,
    )[
      #text(size: 16pt, weight: "bold", fill: mainColor)[#title]
      #v(6pt)
      #text(size: 16pt)[#content]
    ]
    #grid(columns: (1fr, auto, 1fr), column-gutter: 14pt, align: horizon,
      compareBox("Building on our laptops", panelColor,
        [Different OS, Python and library versions.]),
      text(size: 26pt, weight: "bold", fill: mainColor)[→],
      compareBox("Building on GitHub", mainColor.lighten(94%),
        [One clean runner, one recipe, on every push.]),
    )
  ]
]

#slide("What is an artifact?", 3)[
  #body(compact: true)[
    An *artifact* is a file that a workflow run uploads to GitHub, so that it is kept after the run ends.
    #v(22pt)
    // Timeline of an artifact: step 3 (grey) is what gets lost without step 2.
    #let lifeStep(number, title, fill, content) = block(
      width: 100%, height: 130pt, inset: 12pt, radius: 6pt, fill: fill,
    )[
      #text(size: 15pt, weight: "bold", fill: mainColor)[#number #title]
      #v(8pt)
      #text(size: 16pt)[#content]
    ]
    #let arrow = text(size: 24pt, weight: "bold", fill: mainColor)[→]
    #grid(columns: (1fr, auto, 1fr, auto, 1fr, auto, 1fr), column-gutter: 8pt, align: horizon,
      lifeStep("1", "BUILD", mainColor.lighten(94%), [The file is created on the runner.]),
      arrow,
      lifeStep("2", "UPLOAD", mainColor.lighten(94%), [A step uploads it to the run on GitHub.]),
      arrow,
      lifeStep("3", "JOB ENDS", luma(92%), [The runner is deleted, with all its files.]),
      arrow,
      lifeStep("4", "KEPT", mainColor.lighten(94%), [90 days on the run page, under *Artifacts*, ready to download.]),
    )
    #v(22pt)
    #result[An artifact keeps a run's output for a while: good for builds, not for permanent releases.]
  ]
]

#slide("Dockerfile.build: compile with Nuitka", 3)[
  #body(compact: true)[
    The file has two stages, each starting with `FROM`. The first, `builder`,
    installs Nuitka, copies the code and compiles it.
    #v(18pt)
    // Code on the left, what each Nuitka option does on the right.
    #grid(columns: (1.6fr, 1fr), column-gutter: 20pt, align: horizon,
      workflowPanel(focus: (6, 7, 8, 9, 10), size: 14pt)[
        ```dockerfile
        FROM python:3.14-slim-bookworm AS builder
        # ... install Nuitka and its build requirements ...
        ENV OUTPUT_DIR=/app/bin
        ENV OUTPUT_FILENAME=app
        COPY . .
        RUN python -m nuitka \
            --mode=onefile \
            --output-dir=${OUTPUT_DIR} \
            --output-filename=${OUTPUT_FILENAME} \
            src/main.py
        ```
      ],
      text(size: 17pt)[#list(
        [`--mode=onefile`: one single file, not a folder.],
        [`--output-dir`: where to write it.],
        [`--output-filename`: its name.],
        [`src/main.py`: the starting point; Nuitka follows its imports.],
      )],
    )
    #v(18pt)
    #text(size: 17pt)[This `RUN` line is where the compilation happens: Nuitka turns the whole program into a single executable. `json/data.json` stays outside: the program reads it when it starts.]
    #v(18pt)
    #result[The executable is ready, but the builder also holds Python, Nuitka and the sources.]
  ]
]

#slide("Dockerfile.build: keep only the executable", 3)[
  #body(compact: true)[
    The second stage, `app-only`, keeps only the file we want to distribute.
    #v(22pt)
    #workflowPanel(size: 20pt)[
      ```dockerfile
      FROM scratch AS app-only
      COPY --from=builder /app/bin/app /app
      ```
    ]
    #v(22pt)
    #list(
      [`scratch` starts with an empty filesystem.],
      [`--from=builder` copies the executable from the compilation stage.],
      [`/app/bin/app` is the executable from `builder`: here it is copied as `/app`, keeping the same name.],
    )
    #v(22pt)
    #result[`app-only` contains just one file: the executable, ready to be taken out of Docker. In the workflow, we will export exactly this stage.]
  ]
]

#slide("Workflow (1/4): trigger and checkout", 3)[
  #body(compact: true)[
    The workflow lives in `.github/workflows/build-binary.yml`. Its structure is the one
    seen in Part 1: trigger, job, runner, steps.
    #v(16pt)
    #grid(columns: (1.2fr, 1fr), column-gutter: 24pt,
      [#workflowPanel(focus: (2, 3, 5))[
        ```yaml
        name: Build Linux binary
        on:
          push
        permissions:
          contents: read
        jobs:
          build:
            runs-on: ubuntu-latest
            steps:
              - name: Checkout repository
                uses: actions/checkout@v7
        ```
      ]],
      [
        *What is specific here?*
        #v(14pt)
        #text(size: 18pt)[#list(
          [Every push, on any branch, starts a build.],
          [Read-only permission: the workflow changes nothing in the repository.],
          [It does not run pytest or wait for the test workflow of Part 2.],
        )]
      ],
    )
    #v(16pt)
    #result[Every push produces a new executable, built from the pushed commit.]
  ]
]

#slide("Workflow (2/4): build and export", 3)[
  #body(compact: true)[
    This step runs `docker build` on the runner: Docker follows `Dockerfile.build` up to the `app-only` stage.
    #v(16pt)
    #grid(columns: (1.3fr, 1fr), column-gutter: 24pt, align: horizon,
      workflowPanel(focus: (5, 6), size: 15pt)[
        ```yaml
        - name: Build application with Docker
          run: |
            docker build --platform linux/amd64 \
              -f Dockerfile.build \
              --target app-only \
              --output type=local,dest=dist .
        ```
      ],
      text(size: 17pt)[#list(
        [`--platform`: the executable's target, Linux x86-64 (amd64).],
        [`-f`: the Dockerfile to use; `.` gives the build the repository files.],
        [`--target app-only`: stop at the stage that holds only the executable.],
        [`--output`: copy that stage's files into `dist` on the runner.],
      )],
    )
    #v(16pt)
    #result[The build leaves a single file on the runner, instead of an image: `dist/app`.]
  ]
]

#slide("Workflow (3/4): name the executable", 3)[
  #body(compact: true)[
    The Dockerfile gives the file a generic name; the workflow, which chooses the platform, renames it accordingly.
    #v(22pt)
    #workflowPanel(focus: (2,), size: 20pt)[
      ```yaml
      - name: Name binary for its target platform
        run: mv dist/app dist/app-linux-amd64
      ```
    ]
    #v(22pt)
    #grid(columns: (1fr, 1fr), column-gutter: 24pt,
      [*Why the name matters*
        #v(12pt)
        The file runs only on Linux amd64: the name says so before anyone downloads it.],
      [*One file per platform*
        #v(12pt)
        Other targets would need their own builds, e.g. `app-linux-arm64` or `app-windows-amd64.exe`.],
    )
    #v(22pt)
    #result[The file is now `dist/app-linux-amd64`, and this will also be the artifact's name.]
  ]
]

#slide("Workflow (4/4): upload the artifact", 3)[
  #body(compact: true)[
    The last step uses a ready-made action, `actions/upload-artifact`, to save the executable in the run, so it stays available after the runner is deleted.
    #v(16pt)
    #grid(columns: (1fr, 1fr), column-gutter: 24pt, align: horizon,
      workflowPanel(focus: (4, 5))[
        ```yaml
        - name: Upload binary artifact
          uses: actions/upload-artifact@v7
          with:
            path: dist/app-linux-amd64
            archive: false
            if-no-files-found: error
        ```
      ],
      list(
        [`path` selects the renamed executable.],
        [`archive: false` uploads the file as it is, without a zip, under its own name.],
        [`if-no-files-found: error` fails the step if that file is missing.],
      ),
    )
    #v(14pt)
    #show figure.caption: set text(size: 14pt)
    #figure(
      screenshot("../../img/topic3/exec/artifact.png", width: 80%),
      caption: [The `app-linux-amd64` artifact in the run's summary, ready to download.],
    )
  ]
]



/*
#slide("Run the executable", 3)[
  #body(compact: true)[
    Download `app-linux-amd64` from the run's *Artifacts*, move it to the repository root and start it:
    #v(16pt)
    #workflowPanel(focus: (2,), size: 15pt)[
      ```sh
      $ chmod +x app-linux-amd64   # browser downloads drop the executable bit
      $ ./app-linux-amd64
      Server has started!

      $ curl http://localhost:5000/json/getData    # in a second terminal
      {"data": "{\"characters\": [\"Mario\", \"Rossi\", \"Luigi\", \"Verdi\"]}"}
      ```
    ]
    #v(18pt)
    #list(
      [No Python, Nuitka or Docker is needed to run it.],
      [The program reads `./json/data.json` from the current directory: the repository root has it.],
      [`data` holds the file contents serialized as a string.],
    )
    #v(16pt)
    #result[The file produced by GitHub Actions works on its own.]
  ]
]
*/

#slide("What are the limits of the executable?", 3)[
  #body(compact: true)[
    The artifact is a single file, but it does not run everywhere on its own.
    #v(22pt)
    #grid(columns: (1fr, 1fr), column-gutter: 24pt,
      card("Where it runs", [Linux amd64 only, on systems as recent as Debian 12 (the builder's base) or newer.]),
      card("What it needs", [`json/data.json` in the directory it is started from: the data is not inside the file.]),
    )
    #v(16pt)
    #hint(txtSize: 17pt)[*Note:* a browser download loses the execute permission: run `chmod +x app-linux-amd64` before starting it.]
    #v(16pt)
    #result[In our case the executable is not ready to run on its own: it still needs `json/data.json` and a Linux amd64 system.]
  ]
]

/*
#slide("Exercises", 3)[

  #align(center + horizon)[
    #text(size: 2.5em, weight: "bold")[On the website!]

    #v(2em)

    #text(size: 2.3em)[
      Go to: #link("https://sdegroup5.github.io/")[#text(fill: rgb("1565c0"))[*sdegroup5.github.io*]]
    ]

    #v(1em)
  ]

]

#slide("Solutions: Exercises", 3)[
  #set text(1.3em)
  #set list(spacing: 0.8em)
  #show grid: set text(size: 1.15em)

  #grid(
    columns: (1fr, 1fr),
    align: left + top,
    inset: 1em,
    row-gutter: 1.5em,
    [
      *Multiple choice — Answer: C* \
      `dist` contains only the `app` executable.
      - `--target app-only` stops at the `app-only` stage, which starts `FROM scratch` and copies just that file.
      - It is not an image (A): `--output` writes files to the runner.
      - The repository files (B) stay in `builder`.
      - `--output` does not need `docker push` (D).
    ],
    [
      *Fill in the gaps — `app-only` / `upload-artifact`* \
      - `--target app-only` builds only up to the stage that contains the executable.
      - `actions/upload-artifact` saves the executable in the run, because the runner is destroyed when the job ends.
    ],
  )

]
*/


// Exercise: the build workflow only starts on the branch written in
// `branches`. In the students' project it is `[TODO]`, so the workflow does not
// run during the previous parts (the build takes about two minutes).
// Starter workflow and site text: docs/topics/topic3-exec-exercise-starter.md

#slide("Exercise: start the build", 3)[
  #body(compact: true)[
    In your repository, the build workflow does not start yet: it only runs on the branch written in `branches`.
    #v(16pt)
    #grid(columns: (1fr, 1.2fr), column-gutter: 24pt, align: horizon,
      workflowPanel(focus: (4,), size: 16pt)[
        ```yaml
        on:
          push:
            # TODO: your branch name
            branches: [TODO]
        ```
      ],
      text(size: 17pt)[#enum(
        [*Open* `.github/workflows/build-binary.yml`.],
        [*Replace* `TODO` with the name of your branch (shown on GitHub, above the file list).],
        [*Commit and push*: \ `git add .` \ `git commit -m "Start the build"` \ `git push`],
        [*Open* Actions → _Build Linux binary_ and wait about two minutes.],
        [*Check* that the run is green and that `app-linux-amd64` is under _Artifacts_.],
      )],
    )
    #v(16pt)
    #hint(txtSize: 17pt)[*Tip:* until `branches` matches your branch, no build starts: no error, simply no run.]
  ]
]

#slide("Solution: start the build", 3)[
  #body(compact: true)[
    The trigger decides *whether* the workflow starts. Both versions below are correct.
    #v(16pt)
    #grid(columns: (1fr, 1fr), column-gutter: 24pt,
      [*Only your branch*
        #v(10pt)
        #workflowPanel(size: 16pt)[
          ```yaml
          on:
            push:
              branches: [main]
          ```
        ]
        #v(10pt)
        #text(size: 17pt)[Pushes to other branches do not start a build.]],
      [*Every branch* (as in our workflow)
        #v(10pt)
        #workflowPanel(size: 16pt)[
          ```yaml
          on:
            push
          ```
        ]
        #v(10pt)
        #text(size: 17pt)[Every push starts a build, on any branch.]],
    )
    #v(16pt)
    #result[A green run with `app-linux-amd64` under Artifacts: GitHub Actions built the executable from your push.]
  ]
]
