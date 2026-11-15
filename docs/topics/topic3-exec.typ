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
      card("Docker", [Provides the build environment: Python, Nuitka and a C compiler.]),
      card("GitHub Actions", [Runs the build on every push and keeps the executable as an artifact.]),
    )
    #v(22pt)
    #result[Dockerfile → workflow → artifact → run the executable.]
  ]
]

#slide("Why compile with GitHub Actions?", 3)[
  #body(compact: true)[
    Part 1 showed why CI helps: clean, automatic and reproducible runs.
    For a compiled program, it also means:
    #v(22pt)
    #list(
      [*No local toolchain:* Nuitka and the C compiler live in the build image, not on our laptops.],
      [*Same output for everyone:* any developer gets the same Linux executable.],
      [*Traceable:* each executable is linked to its commit, and the run keeps the build logs.],
      [*Early feedback:* if compilation breaks, the run fails and the commit is marked as failed.],
    )
    #v(22pt)
    #result[The executable is built by GitHub, not by one of us: same recipe, every push.]
  ]
]

#slide("Dockerfile: compile with Nuitka", 3)[
  #body(compact: true)[
    `Dockerfile.app` has several stages: each `FROM` starts one. `builder`
    (`python:3.14-slim-bookworm`) installs Nuitka, a C compiler and `patchelf`.
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
    #text(size: 17pt)[Nuitka translates Python into C and invokes a compiler. The JSON is external data: this build does not bundle it.]
    #v(18pt)
    #result[The compiled program is `/app/bin/app` inside the builder.]
  ]
]

#slide("Dockerfile: export the executable", 3)[
  #body(compact: true)[
    The `binary` stage keeps only the file we want to distribute.
    #v(22pt)
    #workflowPanel(focus: (1, 2), size: 20pt)[
      ```dockerfile
      FROM scratch AS binary
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
    #result[This stage contains only the executable; the compiler stays in `builder`.]
  ]
]

#slide("Workflow (1/3): trigger and checkout", 3)[
  #body(compact: true)[
    #grid(columns: (1.2fr, 1fr), column-gutter: 24pt,
      [#workflowPanel(focus: (3, 4, 9))[
        ```yaml
        name: Build Linux binary
        on:
          push:
            branches: ["docker-build"]
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
        #text(size: 18pt)[A push to `docker-build` starts this workflow on an Ubuntu runner.]
        #v(16pt)
        #text(size: 18pt)[Checkout retrieves the repository files with read permission.]
        #v(16pt)
        #text(size: 17pt)[This build job does not run pytest or wait for the separate test workflow.]
      ],
    )
  ]
]

#slide("Workflow (2/3): build and export", 3)[
  #body(compact: true)[
    In `.github/workflows/build-binary.yml`, the runner builds `Dockerfile.app` with Docker.
    #v(20pt)
    #workflowPanel(focus: (5, 6))[
      ```yaml
      - name: Build application with Docker
        run: |
          docker build --platform linux/amd64 \
            -f Dockerfile.app \
            --target binary \
            --output type=local,dest=dist .
      ```
    ]
    #v(22pt)
    #grid(columns: (1fr, 1fr), column-gutter: 24pt,
      [*Inside Docker*
        #v(12pt)
        Nuitka compiles the program in `builder`; `binary` selects the resulting file.],
      [*On the runner*
        #v(12pt)
        The local exporter writes `dist/app`, ready for the upload step.],
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
        -f Dockerfile.app \
        --target binary \
        --output type=local,dest=dist .
      ```
    ]
    #v(20pt)
    #list(
      [`--platform linux/amd64` selects the executable's target.],
      [`-f` selects the Dockerfile; `.` supplies the files available to the build.],
      [`--target binary` selects the export stage.],
      [`--output` saves its filesystem into the local `dist` directory.],
    )
    #v(18pt)
    #result[Here, local means the runner filesystem: the next step reads dist/app.]
  ]
]

#slide("Workflow (3/3): upload the artifact", 3)[
  #body(compact: true)[
    Upload the output so it remains downloadable after the runner finishes.
    #v(16pt)
    #grid(columns: (1fr, 1fr), column-gutter: 24pt, align: horizon,
      workflowPanel(focus: (4, 5))[
        ```yaml
        - name: Upload binary artifact
          uses: actions/upload-artifact@v7
          with:
            path: dist/app
            archive: false
            if-no-files-found: error
        ```
      ],
      list(
        [`path` selects the executable produced by the build.],
        [`archive: false` uploads the single file directly.],
        [`if-no-files-found: error` fails the step if that file is missing.],
      ),
    )
    #v(14pt)
    #show figure.caption: set text(size: 14pt)
    #figure(
      screenshot("../../img/topic3/exec/artifact.png", width: 80%),
      caption: [The `app` artifact in the run's summary, ready to download.],
    )
  ]
]

#slide("Follow the workflow in Actions", 3)[
  #body(compact: true)[
    We open *Build Linux binary* in Actions and inspect a run on `docker-build`.
    #v(16pt)
    #grid(columns: (1fr, 1.5fr), column-gutter: 20pt, align: horizon,
      enum(
        [*Source:* the run shows the commit that triggered it.],
        [*Build:* the longest step: a clean runner has no Docker cache, so Nuitka compiles everything again.],
        [*Export:* the build writes `app` into the runner's `dist` directory.],
        [*Upload:* the file appears in the run's *Artifacts* section.],
      ),
      screenshot("../../img/topic3/exec/build_complete.png"),
    )
  ]
]


#slide("Run the executable", 3)[
  #body(compact: true)[
    Download `app` from the run's *Artifacts*, move it to the repository root and start it:
    #v(16pt)
    #workflowPanel(focus: (2,), size: 15pt)[
      ```sh
      $ chmod +x app       # browser downloads drop the executable bit
      $ ./app
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

#slide("What are the limits of the executable?", 3)[
  #body(compact: true)[
    The artifact is a single file, but it does not run everywhere on its own.
    #v(22pt)
    #grid(columns: (1fr, 1fr), column-gutter: 24pt,
      card("Where it runs", [Linux x86-64 with a C library compatible with Debian 12, the builder's base.]),
      card("What it needs", [`json/data.json` in the directory it is started from: the data is not inside the file.]),
    )
    #v(22pt)
    #text(size: 18pt)[It runs only on that system: supporting other operating systems or CPU architectures requires one executable for each, built on a matching runner.]
    #v(18pt)
    #result[To share a ready-to-run application, a file is not enough.]
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
      - `--target binary` stops at the `binary` stage, which starts `FROM scratch` and copies just that file.
      - It is not an image (A): `--output` writes files to the runner.
      - The repository files (B) stay in `builder`.
      - `--output` does not need `docker push` (D).
    ],
    [
      *Fill in the gaps — `binary` / `upload-artifact`* \
      - `--target binary` builds only up to the stage that contains the executable.
      - `actions/upload-artifact` saves `dist/app` in the run, because the runner is destroyed when the job ends.
    ],
  )

]
