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

// TODO: add a lot of images (even if unused,
// if they are useful place them in the repo)
/*
#slide("Docker image building with GitHub Actions")[
  #body[
    Github Actions allows to automate the building of Docker images and their publication to a container registry, such as the GitHub Container Registry (GHCR). This can be achieved by defining a workflow in a YAML file within the `.github/workflows` directory of the repository. The workflow can include steps to check out the code, build the Docker image using a `Dockerfile`, and then push the image to GHCR. By leveraging GitHub Actions, developers can ensure that their Docker images are built and published automatically whenever changes are pushed to the repository, streamlining the development and deployment process.
    // TODO: refactor and improve
  ]
]
*/
#slide("From source code to a downloadable build", 3)[
  #body(compact: true)[
    We will compile the Python application, automate the build and share its result.
    The program still serves `json/data.json` over HTTP on port `5000`.
    #v(22pt)
    #grid(columns: (1fr, 1fr, 1fr), column-gutter: 16pt,
      card("Nuitka", [Compiles Python into an executable, bundling the required Python components in our onefile build.]),
      card("Docker", [Provides the environments in which we compile and run the application.]),
      card("GitHub Actions", [Runs the build on a runner and uploads the result for download.]),
    )
    #v(22pt)
    #result[Build locally → automate with Actions → download and run.]
    #v(16pt)
  ]
]

#slide("Dockerfile: compile with Nuitka", 3)[
  #body(compact: true)[
    The first stage of `Dockerfile.app` uses Python on Alpine and installs Nuitka,
    the application's dependency and native build tools. These are the compilation instructions:
    #v(18pt)
    #workflowPanel(focus: (5, 6, 7, 8, 9))[
      ```dockerfile
      ENV OUTPUT_DIR=/app/bin
      ENV OUTPUT_FILENAME=app
      RUN mkdir -p ${OUTPUT_DIR}
      COPY . .
      RUN python -m nuitka \
          --standalone --onefile \
          --output-dir=${OUTPUT_DIR} \
          --output-filename=${OUTPUT_FILENAME} \
          src/main.py
      ```
    ]
    #v(18pt)
    #text(size: 17pt)[Nuitka translates Python into C and uses a C compiler. The onefile build produces `app`; `json/data.json` remains separate.]
    #v(18pt)
    #result[The build creates `/app/bin/app` inside Docker, not in a local output folder.]
  ]
]

#slide("Dockerfile: prepare the runtime", 3)[
  #body(compact: true)[
    Each `FROM` starts a new stage. The second stage copies the compiled result into a fresh Alpine environment.
    #v(18pt)
    #workflowPanel(focus: (3, 4))[
      ```dockerfile
      FROM alpine:3.24.2
      WORKDIR /app
      COPY --from=0 /app/bin/app /app/app
      COPY --from=0 /app/json/data.json /app/json/data.json
      RUN chmod +x /app/app
      CMD ["/app/app"]
      ```
    ]
    #v(20pt)
    #grid(
      columns: (1fr, 1fr), column-gutter: 24pt,
      [*Copy the build result*
        #v(10pt)
        #text(size: 17pt)[`--from=0` selects the first stage. The compiler and build tools are not copied.]],
      [*Set the startup command*
        #v(10pt)
        #text(size: 17pt)[`CMD` specifies the executable to start when running a container. It does not run during the build.]],
    )
    #v(20pt)
    #result[The image can run the application locally; Actions will also extract its files for the artifact.]
  ]
]

#slide("Try it locally: build, then run", 3)[
  #body(compact: true)[
    Start Docker and open a terminal at the repository root.
    On Windows, use Linux containers.
    #v(16pt)
    *1. Build the image and compile the program*
    #v(10pt)
    #workflowPanel()[
      ```sh
      docker build --platform linux/amd64 -f Dockerfile.app -t lab-app:local .
      ```
    ]
    #v(12pt)
    #text(size: 16pt)[`--platform` fixes the target; `-f` selects our Dockerfile; `-t` names the image; `.` supplies the build context.]
    #v(16pt)
    *2. Start the compiled application*
    #v(10pt)
    #workflowPanel()[
      ```sh
      docker run --rm -it --platform linux/amd64 -p 5000:5000 lab-app:local
      ```
    ]
    #v(16pt)
    #text(size: 17pt)[Open `http://localhost:5000/json/getData` to see the supplied data. Press *Ctrl+C* to stop.]
  ]
]

#slide("Workflow (1/4): trigger, runner and checkout", 3)[
  #body(compact: true)[
    #grid(
      columns: (1fr, 1fr), column-gutter: 24pt,
      [
        #workflowPanel(focus: (9, 10, 11, 12))[
          ```yaml
          name: Build Linux binary
          on:
            push:
              branches: ["**"]
          permissions:
            contents: read
          jobs:
            build:
              runs-on: ubuntu-latest
              steps:
                - name: Checkout repository
                  uses: actions/checkout@v7
          ```
        ]
      ],
      [
        *Same structure, a new task*
        #v(18pt)
        #text(size: 18pt)[In `.github/workflows/build-binary.yml`, a push to any branch starts the build job.]
        #v(18pt)
        #text(size: 18pt)[GitHub provides an Ubuntu runner. Checkout makes the repository files available to the following steps.]
        #v(18pt)
        #text(size: 17pt)[This workflow does not run pytest or wait for the separate testing workflow.]
      ],
    )
  ]
]

#slide("Workflow (2/4): build and extract", 3)[
  #body(compact: true)[
    Actions builds the same Dockerfile, then copies the executable and JSON to the runner.
    #v(16pt)
    #workflowPanel(focus: (9, 10))[
      ```yaml
      - name: Build application with Docker
        run: |
          docker build --platform linux/amd64 \
            -f Dockerfile.app -t github-actions-app:build .
      - name: Extract executable and data
        run: |
          mkdir -p dist/json
          docker create --name binary-extract github-actions-app:build
          docker cp binary-extract:/app/app dist/app
          docker cp binary-extract:/app/json/data.json dist/json/data.json
          docker rm binary-extract
      ```
    ]
    #v(18pt)
    #text(size: 17pt)[`docker create` prepares a container without starting the program. `docker cp` extracts its files; `docker rm` removes the temporary container.]
    #v(16pt)
    #result[The runner now has `dist/app` and `dist/json/data.json`.]
  ]
]

#slide("Workflow (3/4): package the files", 3)[
  #body(compact: true)[
    Add the supplied launch scripts and create one compressed archive.
    #v(20pt)
    #workflowPanel(focus: (6,))[
      ```yaml
      - name: Create distribution archive
        run: |
          cp run.sh dist/run.sh
          cp run.ps1 dist/run.ps1
          chmod +x dist/run.sh
          tar -czf binary-linux-amd64.tar.gz -C dist app json run.sh run.ps1
      ```
    ]
    #v(22pt)
    #grid(
      columns: (1fr, 1fr), column-gutter: 24pt,
      [*What goes into the archive*
        #v(12pt)
        #text(size: 18pt)[The executable `app`, `json/data.json`, `run.sh` and `run.ps1`.]],
      [*What the commands do*
        #v(12pt)
        #text(size: 18pt)[`chmod +x` makes the shell script executable. `tar -czf` compresses the selected files from `dist`.]],
    )
    #v(22pt)
    #result[This archive contains the compiled files and scripts, not the Docker image.]
  ]
]

#slide("Workflow (4/4): upload the artifact", 3)[
  #body(compact: true)[
    Files created on the runner need an upload step to become downloadable after the job.
    #v(20pt)
    #workflowPanel(focus: (2, 3, 4))[
      ```yaml
      - name: Upload binary artifact
        uses: actions/upload-artifact@v7
        with:
          path: binary-linux-amd64.tar.gz
          archive: false
          if-no-files-found: error
      ```
    ]
    #v(20pt)
    #list(
      [`path` must match the archive created by `tar`.],
      [`archive: false` uploads the single `.tar.gz` file directly.],
      [`if-no-files-found: error` fails the step if the archive is missing.],
    )
    #v(20pt)
    #result[The archive is stored as an artifact of this workflow run.]
  ]
]

#slide("Download and extract the artifact", 3)[
  #body(compact: true)[
    #enum(
      [Sign in to GitHub with repository access and open *Actions*.],
      [Select *Build Linux binary* and a successful run for your branch and commit.],
      [In *Artifacts*, download *binary-linux-amd64.tar.gz*.],
    )
    #v(22pt)
    #text(size: 18pt)[In the download folder, extract the archive into a new directory:]
    #v(14pt)
    #workflowPanel(focus: (2,))[
      ```sh
      mkdir binary-demo
      tar -xzf binary-linux-amd64.tar.gz -C binary-demo
      cd binary-demo
      ```
    ]
    #v(20pt)
    #text(size: 17pt)[Use a Linux shell or Windows PowerShell with `tar` available. Keep `app`, `json/data.json`, `run.sh` and `run.ps1` together.]
  ]
]

#slide("Run the downloaded build", 3)[
  #body(compact: true)[
    Start Docker, then run the supplied script from *binary-demo*.
    On Windows, Docker must use Linux containers.
    #v(20pt)
    #grid(
      columns: (1fr, 1fr), column-gutter: 24pt,
      [*Linux / shell*
        #v(12pt)
        #workflowPanel(size: 20pt)[
          ```sh
          ./run.sh
          ```
        ]],
      [*Windows / PowerShell*
        #v(12pt)
        #workflowPanel(size: 20pt)[
          ```powershell
          .\run.ps1
          ```
        ]],
    )
    #v(20pt)
    #text(size: 17pt)[The scripts mount the extracted folder in `alpine:3.24.2` and run the existing executable, publishing port `5000`. First use may download Alpine.]
    #v(18pt)
    #text(size: 17pt)[Open `http://localhost:5000/json/getData`. Expect HTTP *200* with the supplied JSON serialized in the `data` field. Stop with *Ctrl+C*.]
    #v(18pt)
    #result[The binary targets Linux amd64 (x86-64).]
  ]
]

// https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/unblock-file
#slide("Windows: unblock the downloaded script", 3)[
  #body(compact: true)[
    PowerShell's *RemoteSigned* policy may block an unsigned script marked as downloaded from the internet.
    #v(22pt)
    #enum(
      [Check that the archive comes from the expected repository and workflow run.],
      [Open `run.ps1` in an editor and review it before unblocking it.],
      [In the extracted folder, unblock that file and run it again:],
    )
    #v(20pt)
    #workflowPanel(focus: (1,), size: 20pt)[
      ```powershell
      Unblock-File -LiteralPath .\run.ps1
      .\run.ps1
      ```
    ]
    #v(20pt)
    #result[This unblocks the downloaded file while keeping the execution policy unchanged.]
  ]
]

#slide("Exercise", 3)[
  #body(compact: true)[
    ToDo: Esercizio
  ]
]

#slide("Next: distribute the application image", 3)[
  #body(compact: true)[
    We have compiled the application and shared its executable as a workflow artifact.
    #v(24pt)
    #grid(
      columns: (1fr, 1fr), column-gutter: 24pt,
      card("Artifact: files", [Download an archive, extract the executable and data, then use the scripts to run them inside an Alpine container.]),
      card("GHCR: image", [Download an image that already contains the executable, data and runtime, then start a container from it.]),
    )
    #v(24pt)
    #text(size: 18pt)[The next workflow, `docker-image.yml`, builds `Dockerfile.app` again and publishes the image to GHCR.]
    #v(20pt)
  ]
]

#slide("Building Docker images with GitHub Actions", 3)[
  #body[
    GitHub Actions automates the building of Docker images
    and their publication to a container registry, such as GitHub Container Registry (GHCR).

    #v(12pt)

    The workflow performs three main steps:

    #v(6pt)

    #list(
      spacing: 10pt,
      [Check out the application source code.],
      [Build the image using a Dockerfile.],
      [Push the image to GitHub Container Registry.],
    )
  ]
  // Place here the YML snippet of the workflow, and a diagram showing the process
  #move(dx: 53%, dy: -55%)[
    #show figure.caption: set text(size: 1.3em)
    #figure(
      caption: "The Docker logo",
      image("../../img/dockerCheatSheet/mdi--docker.svg", width: 50%),
    )

  ]
]
/*

#slide("Containerizing the application")[
  #body[
    In order to build a Docker image for the application, we need to create a `Dockerfile` that defines the steps to set up the environment and install the necessary dependencies. The `Dockerfile` should specify the base image, copy the application code into the container, install any required packages, and define the command to run the application. Once the `Dockerfile` is created, we can use GitHub Actions to automate the building of the Docker image and its publication to GHCR.
    // TODO: refactor and improve
  ]
]
*/

#slide("Containerizing the application", 3)[
  #body[

    #grid(
      columns: (40%, 60%),
      align: (x, y) => if (x == 0) {
        left + horizon
      } else {
        center + horizon
      },
      [
        A Dockerfile describes how to build an image containing the application and its runtime dependencies.
        #v(12pt)
        // Make the image vertical and more meaningful
        #list(
          spacing: 9pt,
          [Select a base image.],
          [Install dependencies and include the applicaiton code],
          [Build the application.],
          [Place the application in the runtime environment.],
          [Define the comand used when the container is run.],
        )
        #v(14pt)

        #text(size: 17pt)[
          *In our project:* the backend uses a multi-stage build.
          Nuitka produces the executable, which is copied
          into a separate runtime image.
        ]
      ],
      [
        #show figure.caption: set text(size: 0.8em)
        #figure(
          caption: "Docker process by " + link("javacodehouse.com"),
          image(
            "../../img/dockerCheatSheet/docker-sq.png",
            width: 120%,
          ),
        )
      ],
    )

  ]
]
/*
#slide("GitHub Container Registry")[
  #body[
    The GitHub Container Registry (GHCR) is a service provided by GitHub to store and manage Docker container images.
    Similarly to the Docker Hub, GHCR provides a centralized location for storing and managing Docker images. 
    It allows developers to publish and share their Docker images with others, making it easier to distribute and deploy applications. GHCR supports both public and private repositories, enabling users to control access to their images. It integrates seamlessly with GitHub Actions, allowing for automated workflows that can build, test, and deploy Docker images directly from a GitHub repository.
    // TODO: refactor and improve
  ]
]
*/
#slide("GitHub Container Registry", 3)[
  #body[
    GitHub Container Registry (GHCR) is GitHub's service
    for storing and distributing Docker and OCI images,
    similar to Docker Hub.

    #v(16pt)
    #grid(
      columns: (1.2fr, 1fr),
      column-gutter: 20pt,
      align: (x, y) => if (x == 0) {
        left + horizon
      } else {
        center + horizon
      },

      [
        #list(
          spacing: 12pt,

          [
            *Publish and share:* make application images
            available for other machines to download.
          ],

          [
            *Control access:* choose public or private
            packages and configure their permissions.
          ],

          [
            *Identify versions:* use image names and tags
            to select the version to run.
          ],
        )
      ],

      [
        #figure(
          caption: "The GitHub logo",
          image("../../img/topic1/mdi--github.svg", width: 50%),
        )
      ],
    )
    #v(16pt)
    #text(size: 17pt)[
      *GitHub Actions integration:* a workflow can build
      an image and publish it to GHCR using `GITHUB_TOKEN`
      with the appropriate package permissions.
    ]
  ]
]
/*
#slide("Publication workflow")[
  #body[
    The publication workflow involves defining a GitHub Actions workflow in a YAML file within the `.github/workflows` directory. This workflow will include steps to check out the code, build the Docker image, and push it to the GitHub Container Registry.
    // TODO: refactor and improve
  ]
]
*/
#slide("Publication workflow", 3)[
  #body[
    The publication process is defined in a GitHub Actions
    YAML workflow stored in `.github/workflows/`.

    #v(-1em)

    #align(center + horizon)[
      #show figure.caption: set text(size: 0.8em)
      #figure(
        caption: "Image upload with GitHub Action example",

        text(size: 15pt)[
          ```yaml
          steps:
            - name: Checkout code
              uses: actions/checkout@v7

            # Intermediate steps omitted

            - name: Build and push image
              uses: docker/build-push-action@v5
              with:
                context: ./backend
                file: ./backend/Dockerfile.backend
                push: true
                tags: ghcr.io/sdegroup5/github-actions/backend:<tag>
          ```
        ],
      )
    ]

    #text(size: 17pt)[
      #list(
        spacing: 8pt,

        [
          *Checkout:* downloads the repository files
          to the runner.
        ],

        [
          *Build:* uses the specified Dockerfile and
          the files in `./backend` to create the image.
        ],

        [
          *Publish:* `push: true` uploads the image
          to GHCR using the name and tag specified in `tags`.
        ],
      )
    ]
  ]
]
/*
#slide("Running the published image")[
  #body[
    Once published to the GitHub Container Registry, the Docker image can be pulled and run on any machine with Docker installed. To run the published image, you can use the `docker pull` command followed by the image name and tag, and then use the `docker run` command to start a container from that image. This allows for easy deployment and testing of the application in different environments.
    // TODO: refactor and improve
  ]
]
*/
#slide("Running the published image", 3)[
  #body[
    Once published to GHCR, an image can be downloaded
    and run in a compatible Docker environment.

    #v(12pt)

    #enum(
      spacing: 10pt,

      [
        *Select a version:* identify the image name and tag
        to use.
      ],

      [
        *Pull the image:* download that version
        from the registry.
      ],

      [
        *Start a container:* run the image with the required
        configuration and port mappings.
      ],
    )

    #v(-2em)

    #align(center + horizon)[
      #show figure.caption: set text(size: 0.8em)
      #figure(
        caption: "Docker commands example",
        text(size: 15pt)[
          ```bash
          docker pull <image>:<tag>

          docker run -d --name my-app \
            -p <host-port>:<container-port> \
            <image>:<tag>

          docker ps
          docker logs my-app
          ```
        ],
      )

    ]

    #text(size: 17pt)[
      Use `docker ps` to check whether the container is running
      and `docker logs` to inspect its output.
      Publishing a new image does not automatically
      update an existing container.
    ]
  ]
]

/*
#slide("Docker Compose demonstration")[
  #body[
    Docker Compose is a tool that allows you to define and manage multi-container Docker applications. It uses a YAML file to configure the application's services, networks, and volumes. With Docker Compose, you can easily start, stop, and manage all the services defined in the configuration file with a single command. This is particularly useful for applications that require multiple interconnected services, such as a web server, database, and cache. In this demonstration, we will show how to use Docker Compose to run the application and its dependencies in a local development environment.
    // TODO: refactor and improve
  ]
]
*/
#slide("Docker Compose demonstration", 3)[
  #body[

    #grid(
      columns: (40%, 60%),
      align: (x, y) => if (x == 0) {
        left + horizon
      } else {
        center + horizon
      },
      [
        Docker Compose defines and runs multi-container
        applications using a single YAML configuration file.

        #list(
          spacing: 10pt,

          [
            *Services:* define the application components,
            their images and \ runtime configuration.
          ],

          [
            *Networks:* allow the service containers
            to communicate with \ each other.
          ],

          [
            *Volumes:* provide persistent \ storage
            when mounted into the containers.
          ],
        )

        #align(center)[
          #show figure.caption: set text(size: 0.8em)
          #figure(
            caption: "Docker compose commands example",
            text(size: 15pt)[
              ```bash
              docker compose up -d
              docker compose ps
              docker compose logs
              docker compose down
              ```
            ],
          )
        ]

      ],
      [
        #align(center)[
          #show figure.caption: set text(size: 0.8em)
          #figure(
            caption: "Example architecture",
            image(
              "../../img/dockerCheatSheet/compose-application.webp",
              width: 120%,
            ),
          )
        ]
      ],
    )

  ]
]

#slide("Exercise", 3)[
  #body[
    #text(size: 1.2em, weight: "bold")[This will be on the website!!!!!]

    Complete the workflow to make the github action publish a new image. Verify that the changes can be pulled. Optionally, the docker registry could also be used.
  ]
]

