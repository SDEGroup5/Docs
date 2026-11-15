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
  This workflow is triggered when a release is *published* in the repository.
])

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

#ghcrPage("As always...", "0:40", [Checkout], "../../img/topic3/ghcr/builder.svg", [
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

#ghcrPage("Authentication", "0:45", [GitHub handles the authentication], "../../img/topic3/ghcr/login.svg", [
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

#ghcrPage("Nomenclature", "0:55", [Each image has a unique path], "../../img/topic3/ghcr/tag.svg", [
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

#ghcrPage("Build and push image", "0:50", [Image uploading], "../../img/topic3/ghcr/build.svg", [
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

#ghcrPage("Exercise", "0:45", [Publish a new release and verify the run the image], "../../img/topic3/ghcr/monitor.svg", [
  #v(5pt)
  + Open your Repository on Github.
  + In *Releases*, create a new release with tag `v1.0.0` (or a fresh tag).
  + Wait for the *Actions → Docker Image* workflow to complete.
  + In `compose.yml`, change the image to match your registry path and tag.
  + Run `docker compose up` and check application running.
  #v(8pt)
])
