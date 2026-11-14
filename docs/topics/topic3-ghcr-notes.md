# Teaching notes — GitHub Actions → GHCR (9 min 40 sec)

**Location.** The new Typst slides are in `docs/docs/topics/topic3-ghcr.typ`, included at the end of `docs/docs/topics/topic3.typ`. The standalone entrypoint is `docs/docs/ghcr-deck.typ`. The 12 original SVG diagrams and PNG exports are in `docs/img/topic3/ghcr/`.

**Basis.** All YAML action versions, event names, registry, Dockerfile path, tag selection, and image naming come from the attached `.github/workflows/docker-image.yml` and `Dockerfile.app`. The diagrams are original schematics, not live screenshots of GitHub. `SDEGroup5/github-actions` comes from the attached README; students working in forks must substitute their own lowercased owner/repository.

| Slide | Speaking time | Say/do |
|---|---:|---|
| Goal | 0:35 | End state is a pullable image, not a workflow artifact. |
| Find the files | 0:40 | Open `.github/workflows/docker-image.yml` and `Dockerfile.app`. |
| Event | 0:50 | Use `release: published` for proof. Note PRs targeting `master` also run. |
| Permissions | 0:45 | `contents: read` + `packages: write` are the GITHUB_TOKEN grants. |
| Runner | 0:40 | `actions/checkout@v7`, `docker/setup-buildx-action@v4`. |
| Login | 0:45 | `docker/login-action@v4` logs in to `ghcr.io` using `${{ secrets.GITHUB_TOKEN }}`. |
| Version | 0:55 | Release tag → `GITHUB_REF_NAME`; PR → short SHA. Lowercase repo path. |
| Build and push | 0:50 | `docker/build-push-action@v7`, `context: .`, `file: ./Dockerfile.app`, `push: true`. |
| Path fix | 0:45 | Show source file's actual one-line error before asking anyone to publish. |
| Confirm | 0:45 | Actions run and GHCR package must both exist. |
| Pull and run | 0:45 | Use full image address and port 5000. |
| Proof exercise | 1:25 | Students begin steps; build may finish after the talk. |

## Required one-line correction in the provided repository

The `Dockerfile.app` builds from `WORKDIR /app` followed by `COPY . .`. Therefore `json/data.json` is located under `/app/json` in the *build* stage. The provided Dockerfile has a wrong source path and also writes into `/json` rather than the application's runtime working directory.

```diff
-COPY --from=0 /json/data.json /json/data.json
+COPY --from=0 /app/json/data.json /app/json/data.json
```

This patch was **not applied to the project source**. Fixing it is step 1 of the exercise. Publishing before that correction can fail during the Docker build. On `pull_request` events, the current workflow also has `push: true`, so forks may fail because they do not receive a write-capable token. A separately planned improvement would make publishing conditional on releases (e.g., `push: ${{ github.event_name == 'release' }}`). The slides intentionally document the actual attached file rather than quietly rewriting it.

## Very easy proof exercise (give to students)

1. Fork/open a writable copy of the provided repo; correct the Dockerfile line above and commit it to the branch used for the release.
2. On GitHub open **Releases → Draft a new release → Choose a tag → Publish release**. Use a new tag, e.g. `v1.0.0`, or `v1.0.1` if it is taken. Ensure the release points to the corrected commit.
3. Open **Actions → Docker Image** and the run started by the release. Confirm the **Build and push image** step is green.
4. Find the `app` package in the repository/owner's **Packages** area. Verify a version tagged exactly like the release is present.
5. Submit **(a)** the GitHub Actions run URL and **(b)** a screenshot of the GHCR package's tag. No extra CI secret is necessary for the workflow's initial push.

**Optional proof on a local machine** (only after a successful push and correcting the package path for the student's fork):

```sh
IMAGE=ghcr.io/<lowercase-owner>/<lowercase-repo>/app:<release-tag>
docker pull "$IMAGE"
docker run --rm -p 5000:5000 "$IMAGE"
# In a second shell:
curl http://localhost:5000/json/getData
```

Public GHCR packages can be pulled anonymously. A private package requires adequate package access and authentication (typically a PAT classic with `read:packages` for a local terminal). A fresh GHCR package can default to private; check its visibility if students cannot pull anonymously. Build duration can exceed the time allotted to introduce the exercise.

## Sources consulted

- GitHub Docs, [Publishing Docker images](https://docs.github.com/en/actions/tutorials/publish-packages/publish-docker-images)
- GitHub Docs, [Working with the Container registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
- GitHub Docs, [Configuring a package's access control and visibility](https://docs.github.com/en/packages/learn-github-packages/configuring-a-packages-access-control-and-visibility)
- Docker Docs, [Docker Build GitHub Actions](https://docs.docker.com/build/ci/github-actions/)

## Build the editable Typst files

From the `docs/` repository root (not the overall project root):

```sh
typst compile docs/ghcr-deck.typ compiled/ghcr-deck.pdf --root .
typst compile docs/presentation.typ compiled/presentation.pdf --root .
```

The checked-in PDFs provide a visual teaching preview. They were generated using a separate vector-layout exporter and merged with the earlier presentation pages because a Typst CLI was not available in the authoring environment. Recompile with Typst 0.15.1 (the repository CI version) to get PDF output directly from the editable `.typ` sources; page count or layout may differ.
