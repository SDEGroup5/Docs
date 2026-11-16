#import "../lib/commonSlide.typ": slide
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
  #text(size: 15pt, weight: "bold", fill: mainColor)[RESULT]
  #h(10pt)
  #text(size: 17pt)[#content]
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
    #result[`Dockerfile.build` → workflow → downloadable artifact.]
  ]
]

#slide("Why compile with GitHub Actions?", 3)[
  #body(compact: true)[
    Part 1 showed why CI helps: clean, automatic and reproducible runs.
    For a compiled program, it also means:
    #v(22pt)
    #list(
      [*No local setup:* Python and Nuitka live in the build image, not on our laptops.],
      [*Same output for everyone:* any developer gets the same Linux executable.],
      [*Traceable:* each executable is linked to its commit, and the run keeps the build logs.],
      [*Early feedback:* if compilation breaks, the run fails and the commit is marked as failed.],
    )
    #v(22pt)
    #result[The executable is built by GitHub, not by one of us: same recipe, every push.]
  ]
]

#slide("Dockerfile.build: compile with Nuitka", 3)[
  #body(compact: true)[
    `Dockerfile.build` has two stages: each `FROM` starts one. The first, `builder`
    (`python:3.14-slim-bookworm`), installs Nuitka, copies the code and compiles it.
    #v(18pt)
    #workflowPanel(focus: (5, 6, 7, 8, 9))[
      ```dockerfile
      ENV OUTPUT_DIR=/app/bin
      ENV OUTPUT_FILENAME=app
      RUN mkdir -p ${OUTPUT_DIR}
      COPY . .
      RUN python -m nuitka \
          --mode=onefile \
          --output-dir=${OUTPUT_DIR} \
          --output-filename=${OUTPUT_FILENAME} \
          src/main.py
      ```
    ]
    #v(18pt)
    #text(size: 17pt)[Nuitka compiles `src/main.py` and everything it imports into one file (`--mode=onefile`). `json/data.json` is not included: the program reads it at run time.]
    #v(18pt)
    #result[The compiled program is `/app/bin/app` inside the builder.]
  ]
]

#slide("Dockerfile.build: keep only the executable", 3)[
  #body(compact: true)[
    The second stage, `app-only`, keeps only the file we want to distribute.
    #v(22pt)
    #workflowPanel(focus: (1, 2), size: 20pt)[
      ```dockerfile
      FROM scratch AS app-only
      COPY --from=builder /app/bin/app /app
      ```
    ]
    #v(22pt)
    #list(
      [`scratch` starts with an empty filesystem.],
      [`--from=builder` copies the executable from the compilation stage.],
      [`/app` is the exported file's path, not a directory here.],
    )
    #v(22pt)
    #result[`app-only` contains only the executable; Python, Nuitka and the sources stay in `builder`.]
  ]
]

#slide("Workflow (1/4): trigger and checkout", 3)[
  #body(compact: true)[
    #grid(columns: (1.2fr, 1fr), column-gutter: 24pt,
      [#workflowPanel(focus: (2, 3, 8))[
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
        *When and where?*
        #v(16pt)
        #text(size: 18pt)[Every push, on any branch, starts this workflow on an Ubuntu runner.]
        #v(16pt)
        #text(size: 18pt)[Checkout retrieves the repository files with read permission.]
        #v(16pt)
        #text(size: 17pt)[This build job does not run pytest or wait for the separate test workflow.]
      ],
    )
  ]
]

#slide("Workflow (2/4): build and export", 3)[
  #body(compact: true)[
    In `.github/workflows/build-binary.yml`, the runner builds `Dockerfile.build` with Docker.
    #v(20pt)
    #workflowPanel(focus: (4, 5, 6))[
      ```yaml
      - name: Build application with Docker
        run: |
          docker build --platform linux/amd64 \
            -f Dockerfile.build \
            --target app-only \
            --output type=local,dest=dist .
      ```
    ]
    #v(22pt)
    #grid(columns: (1fr, 1fr), column-gutter: 24pt,
      [*Inside Docker*
        #v(12pt)
        Nuitka compiles the program in `builder`; `app-only` keeps the resulting file.],
      [*On the runner*
        #v(12pt)
        The local exporter writes `dist/app`, ready for the next steps.],
    )
    #v(22pt)
    #result[The build produces a Linux AMD64 executable.]
  ]
]

#slide("Understanding the export command", 3)[
  #body(compact: true)[
    These options produce a file on the runner instead of a Docker image:
    #v(18pt)
    #workflowPanel(focus: (3, 4))[
      ```sh
      docker build --platform linux/amd64 \
        -f Dockerfile.build \
        --target app-only \
        --output type=local,dest=dist .
      ```
    ]
    #v(20pt)
    #list(
      [`--platform linux/amd64` selects the executable's target.],
      [`-f` selects the Dockerfile; `.` supplies the files available to the build.],
      [`--target app-only` selects the stage that holds only the executable.],
      [`--output` saves its filesystem into the local `dist` directory.],
    )
    #v(18pt)
    #result[Here, local means the runner filesystem: the next steps read `dist/app`.]
  ]
]

#slide("Workflow (3/4): name the executable", 3)[
  #body(compact: true)[
    Before uploading, the workflow renames the file after the platform it was built for.
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
        The file runs only on Linux x86-64 (amd64): the name says so before anyone downloads it.],
      [*One file per platform*
        #v(12pt)
        Other targets would need their own builds, e.g. `app-linux-arm64` or `app-windows-amd64.exe`.],
    )
    #v(22pt)
    #result[The file to upload is now `dist/app-linux-amd64`.]
  ]
]

#slide("What is an artifact?", 3)[
  #body(compact: true)[
    An *artifact* is a file produced by a workflow run and saved by GitHub together with that run.
    #v(22pt)
    #grid(columns: (1fr, 1fr, 1fr), column-gutter: 16pt,
      card("Why", [The runner is deleted when the job ends, together with every file it created.]),
      card("Where", [On the run's summary page, under *Artifacts*, ready to download.]),
      card("How long", [90 days by default, then GitHub deletes it automatically.]),
    )
    #v(22pt)
    #result[An artifact keeps a run's output for a while: good for builds, not for permanent releases.]
  ]
]

#slide("Workflow (4/4): upload the artifact", 3)[
  #body(compact: true)[
    Upload the executable so it remains downloadable after the runner finishes.
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
        [`archive: false` uploads the file as it is, without a zip.],
        [`if-no-files-found: error` fails the step if that file is missing.],
      ),
    )
    #v(14pt)
    #show figure.caption: set text(size: 14pt)
    // TODO: retake this screenshot: the artifact is now called app-linux-amd64, not app.
    #figure(
      screenshot("../../img/topic3/exec/artifact.png", width: 80%),
      caption: [The `app-linux-amd64` artifact in the run's summary, ready to download.],
    )
  ]
]


// Demo slide: commented out for now. Uncomment it to show how to run the executable.
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
      card("Where it runs", [Linux x86-64, with system libraries compatible with Debian 12, the builder's base.]),
      card("What it needs", [`json/data.json` in the directory it is started from: the data is not inside the file.]),
    )
    #v(22pt)
    #text(size: 18pt)[Other systems or CPU architectures need their own executable, built on a matching runner.]
    #v(18pt)
    #result[A file is not enough to share a ready-to-run app: next, the same `app-only` executable goes into a Docker image.]
  ]
]


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
