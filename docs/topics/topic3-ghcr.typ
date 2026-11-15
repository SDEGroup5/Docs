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

#ghcrPage("GitHub Action to create a Docker image",
"0:35",
[GitHub release can create a pullable Docker image],
"../../img/topic3/ghcr/pipeline.svg",
[
  #v(8pt)
  + Code is stored in *GitHub*.
  + *Actions* runs the workflow in a fresh Ubuntu runner.
  + *Buildx* builds the image
  + *GitHub Container Registry* stores it.
  #v(16pt)
  *Output:* `ghcr.io/<owner>/<repo>/app:<tag>`
])

#ghcrPage("File overview", "0:40",
[We already have everything needed in this repository],
"../../img/topic3/ghcr/repo.svg",
[
  #v(8pt)
  *`Dockerfile.build`* docker image builds the application binary with Nuitka.
  #v(8pt)
  *`Dockerfile.app`* runs the binary in a minimal image.
  #v(8pt)
  *`compose.yml`* runs the application pulling the image from the GHCR.
  #v(14pt)
  *`.github/workflows/docker-image.yml`* tells GitHub when and how to build and publish it.
  #v(14pt)
])

#ghcrPage("Workflow trigger", "0:50", [When does the workflow run?], "../../img/topic3/ghcr/triggers.svg", [
  #ghcrBox[
    ```yaml
    on:
      release:
        types: [published]
    ```
  ]
  #v(12pt)
  This workflow is triggered when a pull request is opened against `master` or when a release is published.
  #v(10pt)
  *Caution:* the current workflow also tries to push on PRs; forks often lack package write permission.
])

#ghcrPage("Github Container Registry", "0:45", [Permissions], "../../img/topic3/ghcr/permissions.svg", [
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
  No *Personal Access Token* is needed to push from this workflow.
])

#ghcrPage("Github Container Registry", "0:40", [Checkout], "../../img/topic3/ghcr/builder.svg", [
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

#ghcrPage("Github Container Registry", "0:45", [Authentication], "../../img/topic3/ghcr/login.svg", [
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
  GitHub supplies the token automatically.
  This is done in order to have the permissions to push to the registry.
  Since the workflow runs in the context of the repository, it can push to the registry without needing a *Personal Access Token*.
])

#ghcrPage("Github Container Registry", "0:55", [Nomenclature], "../../img/topic3/ghcr/tag.svg", [
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

#ghcrPage("Github Container Registry", "0:50", [Image uploading], "../../img/topic3/ghcr/build.svg", [
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

#ghcrPage("Github Container Registry", "0:45", [Use two places in GitHub to prove publication succeeded.], "../../img/topic3/ghcr/monitor.svg", [
  #v(5pt)
  + Open the repository's *Actions* tab.
  + Choose *Docker Image* and the run for the published release.
  + Verify the *Build and push image* step passed.
  + Open the owner or repository *Packages* section and find `app` with the release tag.
  #v(8pt)
  *Reminder:* an Actions run is not proof of a package until the push step succeeds.
])

#ghcrPage("Github Container Registry", "0:45", [Pull and run the result], "../../img/topic3/ghcr/run.svg", [
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

#ghcrPage("Github Container Registry", "1:25", [One tiny change, one release, two pieces of evidence.], "../../img/topic3/ghcr/exercise.svg", [
  #v(4pt)
  + In your fork, fix the wrong JSON `COPY --from=0` path in `Dockerfile.app` and commit it.
  + Create a *new published release* with tag `v1.0.0` (or a fresh tag).
  + In *Actions → Docker Image*, check the successful publish step.
  + In *Packages → app*, find the tag matching your release.
  #v(9pt)
  *Submit:* the Actions run URL and a screenshot of the GHCR version. *Bonus:* pull and run it.
])
