#import "../Part2PartialDraft/lib/common.typ": course, labNumber, labName
#import "../Part2PartialDraft/lib/commonSlide.typ": cover, slide

#cover([Laboratory #labNumber: #labName])

#let body(content) = {
  set text(size: 19pt)
  set par(leading: 0.4em)
  set list(spacing: 9pt)
  set enum(spacing: 9pt)
  content
}
#let ask(content) = {
  v(8pt)
  text(size: 17pt, weight: "bold", fill: rgb("B10B25"), content)
}
#let code(content) = {
  set text(size: 18pt)
  content
}
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
#slide("Building Docker images with GitHub Actions")[
  #body[
    GitHub Actions automates the building of Docker images
    and their publication to a container registry, such as GHCR.

    #v(12pt)

    The workflow performs three main steps:

    #v(6pt)

    #list(
      spacing: 10pt,
      [Check out the application source code.],
      [Build the image using a Dockerfile.],
      [Push the image to GitHub Container Registry.],
    )

    #v(14pt)

    The automation is defined in a YAML workflow stored
    in the repository's `.github/workflows/` directory.

    #v(12pt)

    #text(size: 17pt)[
      The workflow runs when a configured event occurs,
      such as a push, pull request or release.
    ]
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

#slide("Containerizing the application")[
  #body[
  A DockerFile describes how to build an image containing the application and its runtime dependencies.
  #v(12pt)

  #list(
    spacing: 9pt,
    [Select a base image.],
    [Install dependencies and include the applicaiton code],
    [Build the application.],
    [Define the comand used when the container is run.],
  )
  #v(14pt)

  #text(size: 17pt)[
      *In our project:* the backend uses a multi-stage build.
      Nuitka produces the executable, which is copied
      into a separate runtime image.
    ]

  #align(center)[
    #image(
      "/img/dockerCheatSheet/docker-sq.png",
      width: 100%,
      height: 100pt,
      fit: "contain",
    )
  ] 

  #align(center)[
    #text(size: 9pt)[Source: javacodehouse.com]
  ]
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
#slide("GitHub Container Registry")[
  #body[
    GitHub Container Registry (GHCR) is GitHub's service
    for storing and distributing Docker and OCI images,
    similar to Docker Hub.

    #v(16pt)
    #grid(
      columns: (1.2fr, 1fr),
      column-gutter: 20pt,
      align: left + top,

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
       Immagine da aggiungere?
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
#slide("Publication workflow")[
  #body[
    The publication process is defined in a GitHub Actions
    YAML workflow stored in `.github/workflows/`.

    #v(14pt)

        #v(14pt)

    #text(size: 15pt)[
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
#slide("Running the published image")[
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

    #v(12pt)

    #text(size: 15pt)[
      ```bash
      docker pull <image>:<tag>

      docker run -d --name my-app \
        -p <host-port>:<container-port> \
        <image>:<tag>

      docker ps
      docker logs my-app
      ```
    ]

    #v(12pt)

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
#slide("Docker Compose demonstration")[
  #body[
    Docker Compose defines and runs multi-container
    applications using a single YAML configuration file.

    #v(12pt)

    #list(
      spacing: 10pt,

      [
        *Services:* define the application components,
        their images and runtime configuration.
      ],

      [
        *Networks:* allow the service containers
        to communicate with each other.
      ],

      [
        *Volumes:* provide persistent storage
        when mounted into the containers.
      ],
    )

    #v(14pt)

    #text(size: 15pt)[
      ```bash
      docker compose up -d
      docker compose ps
      docker compose logs
      docker compose down
      ```
    ]

  
   #align(center)[
    #image(
      "/img/dockerCheatSheet/compose-application.webp",
      width: 75%,
      height: 150pt,
      fit: "contain",
    )
    ]
  ]
]
#slide("Exercise")[
  #body[
   
  ]
]

