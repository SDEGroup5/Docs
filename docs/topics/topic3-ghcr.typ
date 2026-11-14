// A self-contained, approximately 10-minute teaching segment about the EXACT
// workflow at the repository root: .github/workflows/docker-image.yml
// Generated diagrams live in docs/img/topic3/ghcr/. They are schematic, not
// screenshots of live GitHub execution.
// Official documentation:
// https://docs.github.com/en/actions/tutorials/publish-packages/publish-docker-images
// https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry
// https://docs.docker.com/build/ci/github-actions/
#import "../lib/commonSlide.typ": slide
#import "../lib/common.typ": mainColor

#let ghcrBox(contents) = block(
  width: 100%, inset: 12pt, radius: 7pt,
  fill: rgb("F3F5F8"),
)[
  #show raw: set text(font: "DejaVu Sans Mono", size: 13pt)
  #contents
]

#let ghcrPage(title, time, lead, picture, content) = slide(title, 3)[
  #set text(size: 18pt)
  #set par(leading: 0.38em)
  #v(9pt)
  #text(size: 22pt, weight: "bold")[#lead]
  #v(15pt)
  #grid(
    columns: (46%, 1fr),
    column-gutter: 18pt,
    align: (left + top, center + top),
    [#content],
    [#image(picture, width: 100%, height: 260pt, fit: "contain")],
  )
]

#ghcrPage("Github Container Registry", "0:35", [One GitHub release creates a pullable Docker image.], "../../img/topic3/ghcr/pipeline.svg", [
  #v(8pt)
  + Code is stored in *GitHub*.
  + *Actions* runs the workflow in a fresh Ubuntu runner.
  + *Buildx* builds the image; *GHCR* stores it.
  #v(16pt)
  *Output:* `ghcr.io/sdegroup5/github-actions/app:<tag>`
])

#ghcrPage("Find the two files", "0:40", [We already have everything needed in this repository.], "../../img/topic3/ghcr/repo.svg", [
  #v(8pt)
  *`Dockerfile.app`* tells Docker how to create our application image (Nuitka build, then Alpine runtime).
  #v(14pt)
  *`.github/workflows/docker-image.yml`* tells GitHub when and how to build and publish it.
  #v(14pt)
  We will read the real workflow — no invented `backend/` paths.
])

#ghcrPage("1 · Select an event", "0:50", [The workflow runs on pull requests and published releases.], "../../img/topic3/ghcr/triggers.svg", [
  #ghcrBox[
    ```yaml
    on:
      pull_request:
        branches: ["master"]
      release:
        types: [published]
    ```
  ]
  #v(12pt)
  For the exercise, *publish a GitHub release*: its tag becomes the image version.
  #v(10pt)
  *Caution:* the current workflow also tries to push on PRs; forks often lack package write permission.
])

#ghcrPage("2 · Grant package access", "0:45", [The built-in GitHub token is enough inside Actions.], "../../img/topic3/ghcr/permissions.svg", [
  #ghcrBox[
    ```yaml
    permissions:
      contents: read
      packages: write
    ```
  ]
  #v(12pt)
  `contents: read` lets checkout fetch the code.
  #v(12pt)
  `packages: write` allows the workflow to publish to GHCR.
  #v(12pt)
  No personal access token is needed to *push from this workflow*.
])

#ghcrPage("3 · Prepare the runner", "0:40", [Checkout downloads source; Buildx enables the Docker build.], "../../img/topic3/ghcr/builder.svg", [
  #ghcrBox[
    ```yaml
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
      - uses: docker/setup-buildx-action@v4
    ```
  ]
  #v(13pt)
  These steps run on GitHub's runner, not on your laptop.
  #v(11pt)
  The workflow uses the repository root as the build context.
])

#ghcrPage("4 · Log in to GHCR", "0:45", [The workflow authenticates with its temporary `GITHUB_TOKEN`.], "../../img/topic3/ghcr/login.svg", [
  #ghcrBox[
    ```yaml
    - uses: docker/login-action@v4
      with:
        registry: ghcr.io
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}
    ```
  ]
  #v(14pt)
  GitHub supplies the token automatically. Never paste your own password into YAML.
])

#ghcrPage("5 · Give it a version", "0:55", [The image name says where it lives; the tag selects the version.], "../../img/topic3/ghcr/tag.svg", [
  #v(8pt)
  *Image path:* `ghcr.io/<owner>/<repo>/app:<tag>`
  #v(15pt)
  This workflow lowercases the repository name.
  #v(13pt)
  *Release event:* use `GITHUB_REF_NAME` (for example, `v1.0.0`).
  #v(13pt)
  *Pull request:* use the short commit SHA.
  #v(13pt)
  The value is passed to the build step through `$GITHUB_OUTPUT`.
])

#ghcrPage("6 · Build and push", "0:50", [One Docker action executes the build and uploads the image.], "../../img/topic3/ghcr/build.svg", [
  #ghcrBox[
    ```yaml
    - name: Build and push image
      uses: docker/build-push-action@v7
      with:
        context: .
        file: ./Dockerfile.app
        push: true
    ```
  ]
  #v(13pt)
  `tags:` (in the real file) combines the computed repository path and image version.
  #v(10pt)
  `push: true` sends the result to `ghcr.io`.
])

#ghcrPage("A one-line fix before the demo", "0:45", [The attached Dockerfile currently copies JSON from the wrong source path.], "../../img/topic3/ghcr/path-fix.svg", [
  #v(8pt)
  The builder has `WORKDIR /app` and `COPY . .`.
  #v(14pt)
  So the copied file exists at `/app/json/data.json`, *not* `/json/data.json`.
  #v(14pt)
  Correct the second `COPY --from=0` line as shown.
  #v(14pt)
  This is part of the exercise; the provided Dockerfile was not silently changed.
])

#ghcrPage("Check the run and the package", "0:45", [Use two places in GitHub to prove publication succeeded.], "../../img/topic3/ghcr/monitor.svg", [
  #v(5pt)
  + Open the repository's *Actions* tab.
  + Choose *Docker Image* and the run for the published release.
  + Verify the *Build and push image* step passed.
  + Open the owner or repository *Packages* section and find `app` with the release tag.
  #v(8pt)
  *Reminder:* an Actions run is not proof of a package until the push step succeeds.
])

#ghcrPage("Pull and run the result", "0:45", [Now the image can be used on another Docker machine.], "../../img/topic3/ghcr/run.svg", [
  #v(6pt)
  #ghcrBox[
    ```sh
    docker pull ghcr.io/sdegroup5/github-actions/app:v1.0.0
    ```
  ]
  #v(11pt)
  Run the image with port `5000:5000`, then open:
  #v(8pt)
  `http://localhost:5000/json/getData`
  #v(13pt)
  Public packages pull anonymously. Private packages require appropriate authentication.
])

#ghcrPage("Exercise · prove it works", "1:25", [One tiny change, one release, two pieces of evidence.], "../../img/topic3/ghcr/exercise.svg", [
  #v(4pt)
  + In your fork, fix the wrong JSON `COPY --from=0` path in `Dockerfile.app` and commit it.
  + Create a *new published release* with tag `v1.0.0` (or a fresh tag).
  + In *Actions → Docker Image*, check the successful publish step.
  + In *Packages → app*, find the tag matching your release.
  #v(9pt)
  *Submit:* the Actions run URL and a screenshot of the GHCR version. *Bonus:* pull and run it.
])
