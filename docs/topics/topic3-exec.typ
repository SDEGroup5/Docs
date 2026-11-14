// Teaching segment: run the app with Docker, then explain the binary CI workflow.
// Source of truth: SDEGroup5/github-actions, branch docker-build.
// Paths below are relative to that application repository, not to Docs:
// Dockerfile.app, .github/workflows/build-binary.yml, src/main.py,
// src/service/json_service.py and json/data.json.
// Live walkthrough: Docker startup and HTTP response, followed by CI logs and artifact.
// Students observe; no binary download, native setup or copying is required.
// TODO: add an exercise after its scope has been agreed with the group.
// Official references:
// https://nuitka.net/user-documentation/user-manual.html
// https://docs.docker.com/build/building/multi-stage/
// https://docs.docker.com/build/exporters/local-tar/
// https://github.com/actions/upload-artifact

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

#show raw: code => box(
  fill: luma(90%),
  outset: 0.3em,
  radius: 0.4pt,
)[#code]

#slide("From a running app to an automated build", 3)[
  #body(compact: true)[
    First, we run the application with Docker and check its response.
    Then we follow the workflow that compiles and saves its executable.
    #v(22pt)
    #grid(columns: (1fr, 1fr, 1fr), column-gutter: 16pt,
      card("Docker", [Builds the application image and runs the service in its runtime environment.]),
      card("Nuitka", [Compiles the Python application into a Linux executable during the build.]),
      card("GitHub Actions", [Automates compilation and preserves the executable as a workflow artifact.]),
    )
    #v(22pt)
    #result[Run with Docker → inspect the workflow → observe the build result.]
  ]
]

#slide("Run the application with Docker", 3)[
  #body(compact: true)[
    With Docker running, we build the image from the application repository root and start a container:
    #v(18pt)
    #workflowPanel()[
      ```sh
      docker build --platform linux/amd64 \
        -f Dockerfile.app -t lab-app:local .

      docker run --rm -it --platform linux/amd64 \
        -p 5000:5000 lab-app:local
      ```
    ]
    #v(20pt)
    #list(
      [`docker build` compiles the program and prepares the image.],
      [`docker run` starts the application already contained in that image.],
      [`-p 5000:5000` connects the host port to the service in the container.],
    )
    #v(18pt)
    #result[The service is available on localhost:5000 while the container runs.]
  ]
]

#slide("Check the application response", 3)[
  #body(compact: true)[
    We open the application's endpoint in the browser:
    #v(16pt)
    #workflowPanel(size: 20pt)[
      ```text
      http://localhost:5000/json/getData
      ```
    ]
    #v(20pt)
    #grid(columns: (1fr, 1fr), column-gutter: 24pt,
      card("Data in the image", [The image includes `json/data.json` from the repository: Mario, Rossi, Luigi and Verdi.]),
      card("Expected response", [HTTP 200 and a JSON object. Its `data` field contains the file contents serialized as a string.]),
    )
    #v(20pt)
    #text(size: 18pt)[This checks startup, access to the data and HTTP handling. Ctrl+C stops the app; `--rm` removes the stopped container.]
  ]
]

#slide("Automate the build with GitHub Actions", 3)[
  #body(compact: true)[
    The application works in the container. We now look at how CI produces its executable.
    #v(22pt)
    #grid(columns: (1fr, 1fr), column-gutter: 24pt,
      card("Local demonstration", [Docker builds an image and starts the service so we can see its behavior.]),
      card("Binary workflow", [A runner builds the same source, exports `app` and uploads that file as an artifact.]),
    )
    #v(22pt)
    #text(size: 18pt)[The workflow lives in `.github/workflows/build-binary.yml`. We will follow its configuration and inspect a run in Actions.]
    #v(18pt)
    #result[Checkout → compile and export → upload the executable.]
  ]
]

#slide("Dockerfile: compile with Nuitka", 3)[
  #body(compact: true)[
    The `builder` stage uses `python:3.14-slim-bookworm`.
    It installs Nuitka, `python-dotenv`, a C compiler and `patchelf`.
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

#slide("Dockerfile: the runtime image", 3)[
  #body(compact: true)[
    The `runtime` stage creates the image used in our opening demonstration.
    #v(18pt)
    #workflowPanel(focus: (1, 3, 4))[
      ```dockerfile
      FROM debian:bookworm-slim AS runtime
      WORKDIR /app
      COPY --from=builder /app/bin/app /app/app
      COPY json/data.json /app/json/data.json
      RUN chmod +x /app/app
      CMD ["/app/app"]
      ```
    ]
    #v(20pt)
    #text(size: 18pt)[This image contains the executable, the repository's example data and a Debian runtime. The compiler stays in the builder stage.]
    #v(20pt)
    #result[Without --target, Docker builds this final stage to produce the application image.]
  ]
]

#slide("Dockerfile: export the executable", 3)[
  #body(compact: true)[
    Each `FROM` starts a stage. The `binary` stage collects the executable produced by the build.
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
    #result[This stage contains only the executable; it is used for file export.]
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
    In `.github/workflows/build-binary.yml`, the runner executes our build command.
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
    These options select the binary output instead of the runtime image:
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
    #v(20pt)
    #workflowPanel(focus: (4, 5))[
      ```yaml
      - name: Upload binary artifact
        uses: actions/upload-artifact@v7
        with:
          path: dist/app
          archive: false
          if-no-files-found: error
      ```
    ]
    #v(20pt)
    #list(
      [`path` selects the executable produced by the build.],
      [`archive: false` uploads the single file directly.],
      [`if-no-files-found: error` fails the step if that file is missing.],
    )
    #v(20pt)
    #result[The artifact preserves `app` from this workflow run for later verification.]
  ]
]

#slide("Follow the workflow in Actions", 3)[
  #body(compact: true)[
    We open *Build Linux binary* in Actions and inspect a run on `docker-build`.
    #v(22pt)
    #enum(
      [*Source:* the run identifies the branch and commit being built.],
      [*Build:* the log shows the Docker stages and Nuitka compilation.],
      [*Export:* the build writes `app` into the runner's `dist` directory.],
      [*Upload:* the saved file appears in the run's *Artifacts* section.],
    )
    #v(22pt)
    #text(size: 18pt)[The build may take time. A completed run lets us inspect the logs and artifact together. Cached steps may appear as CACHED.]
    #v(18pt)
    #result[We can connect each workflow step to its visible output.]
  ]
]

#slide("What did the workflow produce?", 3)[
  #body(compact: true)[
    The artifact contains the compiled `app` file from the selected source revision.
    #v(22pt)
    #grid(columns: (1fr, 1fr), column-gutter: 24pt,
      card("Build output", [A Linux AMD64 executable. The JSON remains external; the artifact contains only the program.]),
      card("Build status", [A successful run confirms compilation, export and upload. This workflow does not start the server.]),
    )
    #v(22pt)
    #text(size: 18pt)[The opening Docker demo checks application behavior. Native execution of the artifact would also require compatible Linux system libraries.]
    #v(18pt)
    #result[The CI build result and the running application are separate checks.]
  ]
]

#slide("From an artifact to a published image", 3)[
  #body(compact: true)[
    We have seen the application run and the executable produced by CI.
    Next, we publish the application image to GHCR.
    #v(24pt)
    #grid(columns: (1fr, 1fr), column-gutter: 24pt,
      card("Actions artifact", [Preserves the compiled file as an output of a specific workflow run.]),
      card("GHCR image", [Distributes the executable together with example data and a runtime environment, ready to start as a container.]),
    )
    #v(24pt)
    #text(size: 18pt)[`docker-image.yml` builds the runtime image from the Dockerfile and publishes it. It does not download the binary artifact.]
    #v(18pt)
    #result[Same application and Dockerfile; two different build outputs.]
  ]
]
