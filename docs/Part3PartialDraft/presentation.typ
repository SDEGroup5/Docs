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

#slide("Docker image building with GitHub Actions")[
  #body[
    Github Actions allows to automate the building of Docker images and their publication to a container registry, such as the GitHub Container Registry (GHCR). This can be achieved by defining a workflow in a YAML file within the `.github/workflows` directory of the repository. The workflow can include steps to check out the code, build the Docker image using a `Dockerfile`, and then push the image to GHCR. By leveraging GitHub Actions, developers can ensure that their Docker images are built and published automatically whenever changes are pushed to the repository, streamlining the development and deployment process.
    // TODO: refactor and improve
  ]
]

#slide("Containerizing the application")[
  #body[
    In order to build a Docker image for the application, we need to create a `Dockerfile` that defines the steps to set up the environment and install the necessary dependencies. The `Dockerfile` should specify the base image, copy the application code into the container, install any required packages, and define the command to run the application. Once the `Dockerfile` is created, we can use GitHub Actions to automate the building of the Docker image and its publication to GHCR.
    // TODO: refactor and improve
  ]
]

#slide("GitHub Container Registry")[
  #body[
    The GitHub Container Registry (GHCR) is a service provided by GitHub to store and manage Docker container images.
    Similarly to the Docker Hub, GHCR provides a centralized location for storing and managing Docker images. 
    It allows developers to publish and share their Docker images with others, making it easier to distribute and deploy applications. GHCR supports both public and private repositories, enabling users to control access to their images. It integrates seamlessly with GitHub Actions, allowing for automated workflows that can build, test, and deploy Docker images directly from a GitHub repository.
    // TODO: refactor and improve
  ]
]
#slide("Publication workflow")[
  #body[
    The publication workflow involves defining a GitHub Actions workflow in a YAML file within the `.github/workflows` directory. This workflow will include steps to check out the code, build the Docker image, and push it to the GitHub Container Registry.
    // TODO: refactor and improve
  ]
]
#slide("Running the published image")[
  #body[
    Once published to the GitHub Container Registry, the Docker image can be pulled and run on any machine with Docker installed. To run the published image, you can use the `docker pull` command followed by the image name and tag, and then use the `docker run` command to start a container from that image. This allows for easy deployment and testing of the application in different environments.
    // TODO: refactor and improve
  ]
]

#slide("Docker Compose demonstration")[
  #body[
    Docker Compose is a tool that allows you to define and manage multi-container Docker applications. It uses a YAML file to configure the application's services, networks, and volumes. With Docker Compose, you can easily start, stop, and manage all the services defined in the configuration file with a single command. This is particularly useful for applications that require multiple interconnected services, such as a web server, database, and cache. In this demonstration, we will show how to use Docker Compose to run the application and its dependencies in a local development environment.
    // TODO: refactor and improve
  ]
]

#slide("Exercise")[
  #body[
   
  ]
]

