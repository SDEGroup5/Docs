#import "../lib/commonSlide.typ": slide
#import "../lib/common.typ": mainColor

#let ghcrBox(contents, size: 12.5pt) = block(
  width: 100%,
  inset: 11pt,
  radius: 7pt,
  fill: rgb("F3F5F8"),
)[
  #show raw: set text(font: "DejaVu Sans Mono", size: size)
  #contents
]

#let ghcrPage(title, time, lead, picture, content) = slide(title, 3)[
  #set text(size: 17.5pt)
  #set par(leading: 0.35em)
  #set enum(spacing: 6pt)
  #v(4pt)
  #grid(
    columns: (1fr, auto),
    column-gutter: 12pt,
    align: (left + horizon, right + horizon),
    [#text(size: 21pt, weight: "bold")[#lead]],
  )
  #v(13pt)
  #grid(
    columns: (48%, 1fr),
    column-gutter: 17pt,
    align: (left + top, center + top),
    [#content], [#image(picture, width: 100%, height: 260pt, fit: "contain")],
  )
]

// ---------- Core teaching ----------

#ghcrPage(
  "GitHub Action to create a Docker image",
  "0:35",
  [Publish a release, get a pullable container image],
  "../../img/topic3/ghcr/pipeline.svg",
  [
    + Code lives on *GitHub*.
    + *Actions* builds an executable with Nuitka.
    + *Docker Buildx* packages that executable.
    + *GitHub Container Registry* stores the resulting image.
    #v(8pt)
    *Result:* a versioned image at `ghcr.io/<owner>/<repo>/app:<tag>`.
  ],
)

#ghcrPage(
  "File overview",
  "0:45",
  [Four files, one publishing workflow],
  "../../img/topic3/ghcr/repo.svg",
  [
    *`Dockerfile.build`* compiles `src/main.py` into a standalone binary with Nuitka.
    #v(8pt)
    *`Dockerfile.app`* places that binary into a slim runtime image.
    #v(8pt)
    *`compose.yml`* pulls the image from the GHCR and runs the image locally.
    #v(8pt)
    *`.github/workflows/docker-image.yml`* automates both builds and the push.
  ],
)

#ghcrPage(
  "Workflow trigger",
  "0:40",
  [Publishing a GitHub Release starts the run],
  "../../img/topic3/ghcr/triggers.svg",
  [
    #ghcrBox[
      ```yaml
      on:
        release:
          types: [published]
      ```
    ]
    #v(14pt)
    Create a *new release* from a tag, such as `v1.0.0`.
    #v(10pt)
    A regular push or a draft release does *not* start this workflow.
  ],
)

#ghcrPage("Give the right access to the workflow", "0:45", [Permissions], "../../img/topic3/ghcr/permissions.svg", [
  #ghcrBox[
    ```yaml
    permissions:
      contents: read
      packages: write
    ```
  ]
  #v(12pt)
  `contents: read` lets checkout fetch the code.
  It's the default permission, but we declare it explicitly for clarity.
  #v(12pt)
  `packages: write` allows the workflow to publish to GHCR.
  #v(12pt)
  No *Personal Access Token* is needed to push from this workflow.
])

#ghcrPage(
  "As always...",
  "0:40",
  [Prepare a fresh Ubuntu runner],
  "../../img/topic3/ghcr/builder.svg",
  [
    #v(20pt)
    #ghcrBox[
      ```yaml
      build:
        runs-on: ubuntu-latest
        steps:
          - name: Checkout code
            uses: actions/checkout@v7
      ```
    ]
    #v(20pt)
    *Checkout* fetches the project files.
  ],
)

#ghcrPage(
  "Set up the build environment",
  "0:40",
  [Install Docker Buildx and prepare for building the image],
  "../../img/topic3/ghcr/builder.svg",
  [
    #v(20pt)
    #ghcrBox[
      ```yaml
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v4
      ```
    ]
    #v(20pt)
    *Set up Docker Buildx* initializes the build environment.
  ],
)

#ghcrPage(
  "Build the binary first",
  "1:05",
  [The first Docker build exports an executable],
  "../../img/topic3/ghcr/binary.svg",
  [
    #ghcrBox(size: 11.5pt)[
      ```yaml
      - uses: docker/build-push-action@v7
        with:
          context: .
          file: ./Dockerfile.build
          target: app-only
          platforms: linux/amd64
          outputs: type=local,dest=./app-only-context
      ```
    ]
    #v(10pt)
    Nuitka compiles the app; the `app-only` stage exports `app` into `./app-only-context/`.
    #v(9pt)
    *Nothing is pushed yet.*
  ],
)

#ghcrPage(
  "Authentication",
  "0:45",
  [GitHub logs in to the container registry],
  "../../img/topic3/ghcr/login.svg",
  [
    #ghcrBox(size: 11.5pt)[
      ```yaml
      - uses: docker/login-action@v4
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      ```
    ]
    #v(12pt)
    GitHub automatically supplies `GITHUB_TOKEN` to the run.
    #v(9pt)
    It uses the earlier `packages: write` permission to push the image.
  ],
)

#ghcrPage(
  "Build and push image",
  "0:55",
  [The second build packages and publishes `app`],
  "../../img/topic3/ghcr/build.svg",
  [
    #ghcrBox(size: 11pt)[
      ```yaml
      - uses: docker/build-push-action@v7
        with:
          context: .
          file: ./Dockerfile.app
          build-contexts: app-only=./app-only-context
          platforms: linux/amd64
          push: true
          tags: |
            ghcr.io/${{ steps.image-version.outputs.image_repository }}/app:${{ github.sha }}
            ghcr.io/${{ steps.image-version.outputs.image_repository }}/app:${{ steps.image-version.outputs.image_version }}
            ${{ github.event_name == 'release' && format('ghcr.io/{0}/app:latest', steps.image-version.outputs.image_repository) || '' }}

      ```
    ]
    #v(9pt)
    `COPY --from=app-only` takes the binary from the *named build context*.
  ],
)

#ghcrPage("Nomenclature", "0:55", [Each image has a unique path], "../../img/topic3/ghcr/tag.svg", [
  #v(8pt)
  *Image path:* `ghcr.io/<owner>/<repo>/app:<tag>`
  #v(15pt)
  This workflow lowercases the repository name.
  #v(13pt)
  *Tags:*
  + `1.0.0` is the release tag
  + `latest` is a conventional alias to set the most recent release
  + `sha` is the short commit SHA.
  #v(13pt)
  The value is passed to the build step through `$GITHUB_OUTPUT`.
])

//#ghcrPage(
//  "Verify the publication", "0:45",
//  [Check both the Action and the package],
//  "../../img/topic3/ghcr/monitor.svg",
//  [
//    + Open *Actions → Docker Image* and select the release run.
//    + Confirm the *build* job is green.
//    + Find the container package under the owner's *Packages*.
//    + Check the tags: `v1.0.0` and `latest` (or your chosen tag).
//    #v(10pt)
//    A green workflow alone is not the same as verifying the published package.
//  ],
//)

//#ghcrPage(
//  "Pulling from GHCR", "0:45",
//  [Publishing and pulling use different permissions],
//  "../../img/topic3/ghcr/visibility.svg",
//  [
//    A newly published GHCR package is usually *private*.
//    #v(10pt)
//    For the exercise, either:
//    + sign in to GHCR with Docker and *read* access, or
//    + deliberately make the package public in its settings.
//    #v(10pt)
//    Public images can be pulled without signing in.
//    #v(8pt)
//    *Do not change visibility unintentionally.*
//  ],
//)

#ghcrPage(
  "Exercise",
  "1:10",
  [Publish a release and prove the image runs],
  "../../img/topic3/ghcr/exercise.svg",
  [
    + Open your repository → *Releases*.
    + Publish a release tagged `v1.0.0` (or a fresh tag).
    + Open *Actions → Docker Image*; inspect the successful run.
    + Check the version and `latest` in *Packages*.
    + In `compose.yml`, point `image:` at *your* GHCR path and version.
    + Prepare `.env`, run `docker compose up -d`, and test `localhost:5000/json/getData`.
  ],
)

// ---------- Instructor answer key: not part of the 09:40 ----------
// The following are illustrated example outcomes, not screenshots of a real run.

#ghcrPage(
  "Solution: release and Action",
  "ANSWER KEY",
  [Proof 1: a published release starts the build],
  "../../img/topic3/ghcr/solution-release.svg",
  [
    1. Open *Releases → Draft a new release*.
    2. Choose a new tag, e.g. `v1.0.0`, and publish.
    3. Open *Actions → Docker Image → build*.
    4. Check that *Build app-only stage*, *Log in*, and *Build and push image* succeeded.
    #v(13pt)
    *Expected:* the run was triggered by a *release* event and all build steps are green.
  ],
)

#ghcrPage(
  "Solution: GHCR and Compose",
  "ANSWER KEY",
  [Proof 2: the tags and image path match],
  "../../img/topic3/ghcr/solution-ghcr.svg",
  [
    Open the owner's *Packages* page and the `app` image.
    #v(10pt)
    *Expected tags:* `1.0.0`, `latest` and the short SHA of the commit that triggered the run.
    #v(12pt)
    In your local `compose.yml`, set:
    #ghcrBox(size: 11pt)[
      ```yaml
      services:
        app:
          image: ghcr.io/<owner>/<repo>/app:v1.0.0
      ```
    ]
    #v(10pt)
    Replace `<owner>` and `<repo>` with *your own lowercase repository path*. Keep the other Compose settings unchanged.
  ],
)

#ghcrPage(
  "Solution: run and test",
  "ANSWER KEY",
  [Proof 3: your container answers an HTTP request],
  "../../img/topic3/ghcr/solution-local.svg",
  [
    From the repository root, with Docker running:
    #ghcrBox(size: 13pt)[
      ```sh
      cp .env.example .env
      docker compose up -d
      curl -i http://localhost:5000/json/getData
      ```
    ]
    #v(10pt)
    *Expected:* `HTTP/1.0 200 OK` and JSON with a `data` field.
    #v(9pt)
    If the pull is denied, the package is private: authenticate to GHCR or adjust access intentionally or make the package public.
  ],
)
