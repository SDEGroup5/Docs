#set document(title: "The Docker cheat sheet", author: "SDE Group 5")
#set page(paper: "a4", margin: (top: 1.2em, bottom: 1.8em),
  footer: context align(center, text(size: 8pt, [Docker command reference · #counter(page).display() / 2])))
#set text(size: 10.5pt, lang: "en")
#set par(leading: 0.35em)
#show table.cell.where(x: 0): set text(weight: "bold")
#let cmd(value) = {
  set text(size: 9pt, font: "DejaVu Sans Mono", weight: "bold")
  raw(value)
}
#let section(name) = table.cell(colspan: 2, fill: luma(94%), align: left)[*#name*]
#let commands(..cells) = table(
  columns: (43%, 57%),
  inset: 4pt,
  align: (x, y) => if y == 0 {center + horizon} else {left + horizon},
  stroke: 0.6pt + black,
  table.header([*Command*], [*Explanation*]),
  ..cells.pos(),
)

#align(center)[
  #image("../img/dockerCheatSheet/mdi--docker.svg", width: 15%)
  #text(size: 20pt, weight: "bold")[The Docker cheat sheet]
]
#v(6pt)



#commands(
  section("Setup and images"),
  [#cmd("docker version")], [Shows client and server versions. A server connection error means the Engine is unavailable.],
  [#cmd("docker compose version")], [Shows the installed Docker Compose plugin version.],
  [#cmd("docker image ls")], [Lists images stored locally, with their tags, IDs and sizes.],
  [#cmd("docker build -t <image>:<tag> <context>")], [Builds and tags an image. The context is the directory of files available to the build; use `-f <Dockerfile>` for a custom Dockerfile path.],
  [#cmd("docker pull <image>:<tag>")], [Downloads an image from a registry. It does not start a container.],
  [#cmd("docker tag <source> <target>")], [Adds another image reference to an existing local image. It does not rebuild or upload it.],
  section("Registry access and publication"),
  [#cmd("docker login ghcr.io -u <username>")], [Authenticates to GHCR. Use an appropriate access token at the password prompt; do not put the token in the command.],
  [#cmd("docker push <image>:<tag>")], [Uploads the tagged image to its registry. For GHCR, use a full name beginning with `ghcr.io/`.],
  section("Container lifecycle and inspection"),
  [#cmd("docker ps")], [Lists running containers. Add `-a` to include stopped containers.],
  [#cmd("docker run -d -p <host>:<container> <image>")], [Creates and starts a container in the background. Publishes the container port on the host. Add `--name <name>` to name it.],
  [#cmd("docker logs -f <container>")], [Shows and follows container output. Ctrl+C stops following the logs; the container keeps running.],
  [#cmd("docker exec -it <container> sh")], [Opens a shell in a running container, if that image includes `sh`.],
  [#cmd("docker stop <container>")], [Stops a container gracefully, retaining it so it can be started again.],
  [#cmd("docker start <container>")], [Starts an existing stopped container. It does not select a newer image.],
  [#cmd("docker rm <container>")], [Removes a stopped container and its writable layer. It does not remove its image.],
  section("Local resources"),
  [#cmd("docker image rm <image>")], [Removes a local image reference, subject to Docker's checks for images still in use.],
  [#cmd("docker volume ls")], [Lists named and anonymous volumes managed by Docker.],
  [#cmd("docker network ls")], [Lists Docker networks.],
)

#pagebreak()
#align(center)[
  #text(size: 20pt, weight: "bold")[The Docker Compose cheat sheet]
  #v(4pt)
  Services, logs and application updates
]
#v(8pt)
#text(size: 9pt)[Run from the project directory. These commands use the default Compose file. For another file, insert `-f <file>` immediately after `docker compose`.]
#v(6pt)

#commands(
  section("Configuration and startup"),
  [#cmd("docker compose config --quiet")], [Validates and resolves the Compose configuration without printing it. Does not test whether the application works.],
  [#cmd("docker compose build <service>")], [Builds a service image from its `build` configuration. Does not start containers.],
  [#cmd("docker compose up -d")], [Creates and starts services in the background; recreates containers when their image or configuration changes.],
  [#cmd("docker compose up --build -d")], [Builds service images before creating or starting the services.],
  [#cmd("docker compose up -d <service>")], [Starts the selected service and its required dependencies.],
  section("Status and troubleshooting"),
  [#cmd("docker compose ps -a")], [Lists the project's running and stopped service containers.],
  [#cmd("docker compose logs -f <service>")], [Shows and follows logs for a service. Ctrl+C stops following without stopping it.],
  [#cmd("docker compose exec <service> sh")], [Opens a shell in the running service container, if a shell is available.],
  section("Updating a service"),
  [#cmd("docker compose pull <service>")], [Downloads the image selected by the service's `image` setting. Does not replace its running container.],
  [#cmd("docker compose up -d <service>")], [Applies the selected image/configuration by creating or recreating the service when needed.],
  [#cmd("docker compose restart <service>")], [Restarts the existing container. Does not apply a newly selected image or changed environment configuration.],
  section("Stopping and removing services"),
  [#cmd("docker compose stop")], [Stops service containers without removing them. Use `docker compose start` to start them again.],
  [#cmd("docker compose down")], [Stops and removes project containers and networks. Keeps named volumes by default.],
  [#cmd("docker compose down -v")], [*Deletes data in the removed volumes.* Also removes declared non-external named volumes and attached anonymous volumes. Use only for an intentional reset.],
)
