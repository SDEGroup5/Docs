#import "@preview/typslides:1.3.0": *

#show: typslides.with(
  ratio: "16-9",
)

// Slide 1: Title
#slide()[
  #v(2em)
  #align(center)[
    #text(size: 2.2em, weight: "bold")[GitHub Actions] \
    #v(1.5em)
    #text(size: 1.1em)[Lorenzo Radice, Filippo Palmieri, Lorenzo Caraffini, Matteo Schievano, David Stanicel] \
   
  ]
]

// Slide 2: Setup Guide 101
#slide(title: "Setup Guide 101: Workspace Environment")[
  To get started, let's prepare our local environment:

  1. *Clone the workshop repository:*
  #raw("git clone https://github.com/SDEGroup5/github-action.git \ncd workshop-ci-cd", block: true, lang: "bash")

  2. *Create the workflows directory:*
  #raw("mkdir -p .github/workflows", block: true, lang: "bash")

  #block(
    fill: rgb("1e88e5").transparentize(80%),
    inset: 12pt,
    radius: 6pt,
    stroke: 1pt + rgb("90caf9")
  )[
    *Golden Rule:* GitHub recognizes workflows *only* if they are located exactly inside the `.github/workflows/` path and have a `.yml` or `.yaml` extension.
  ]
]




// Slide 3: The Problem
#slide(title: "Why do we need CI/CD?")[
  #grid(
    columns: (1fr, 1fr),
    gutter: 1.5em,
    [
      *The Typical Scenario:*
      - "It works on my machine!"
      - Missing manually installed dependencies.
      - Forgetting to run tests before pushing.
      - The main branch (`main`) breaks for all colleagues.
    ],
    [
      *The Automated Solution:*
      - *Objective Verification:* Neutral and reproducible environment.
      - *Continuous Integration (CI):* Automated builds and tests on every change.
      - *Fast Feedback:* Immediate notification of success or failure before merging.
    ]
  )
]

// Slide 4: Event-Driven Paradigm
#slide(title: "What is GitHub Actions?")[
  It is not just a build tool, but a *general event-driven automation engine*.

  - *Event-Driven:* Reacts to any action occurring on GitHub:
    - `push` or `pull_request` on specific branches.
    - Tag or release creation.
    - Issue opening/commenting.
    - Manual triggers via UI (`workflow_dispatch`).

  - *Runners:* Clean, ephemeral environment (Ubuntu, macOS, Windows) hosted in the GitHub cloud or local, ready to execute commands on our behalf.
]


// Slide 5: Workflow Anatomy
#slide(title: "Anatomy of a Workflow")[
#grid(
columns: (0.9fr, 1.6fr),
gutter: 1.5em,
align: (center + horizon, left + horizon),
[
#image("/img/image_2.png", height: 78%)

],
[
#set text(size: 0.88em)
#set list(spacing: 0.65em)

The fundamental hierarchy of GitHub Actions:

- Events: Triggers that start the automation (push, pull_request).
- Workflows: Top-level automated processes defined in .yml files.
- Jobs: Units executed on a dedicated, isolated runner.
- Run in parallel by default, or sequentially via needs: (e.g., deploy after test).
-  New Job = Fresh environment: Files or packages do not persist between jobs!
- Actions (Steps): Individual tasks or reusable blocks executed on the same runner (sharing files and state).
]
)
]



// Slide 6: General Syntax
#slide(title: "General Syntax (.github/workflows/compile.yml)")[
  #set text(size: 0.95em)
  #raw("name: Typst Compiler Workflow    # Name in GitHub's 'Actions' tab

on:                              # 1. EVENT: Triggers the workflow
  push:                          # Reacts when commits are pushed...
    branches: [ \"main\" ]         # ...ONLY if pushed to 'main'

jobs:                            # 2. JOBS: Tasks (parallel default)
  compile:                       # Unique Job ID (named freely)
    runs-on: ubuntu-latest       # Spins up a fresh Ubuntu container
                                 # (the isolated Runner)
    
    steps:                       # 3. STEPS: Sequential tasks on the
                                 # EXACT SAME runner
      - name: Checkout code      # '-' = list item; 'name:' = label
        uses: actions/checkout@v4
                                 # 'uses:' runs a pre-built Action.
                                 # Clones repo into the empty container!
                                 # ('actions/' = official GitHub org,
                                 #  '@v4' = pinned version)

      

      - name: Compile document   # Shares the same directory!
        run: ./typst compile ./docs/main.typ
                                 # './typst' (Step 2) and repo files
                                 # (Step 1) are both available here", block: true, lang: "yaml")
]



// Slide 6b: Execution Strategy (Matrix)
#slide(title: "Execution Strategy: Matrix Builds")[
  To test across multiple versions or OS environments in parallel, we use the `strategy:` directive at the *exact same indentation level* as `runs-on:` and `steps:`.

  #v(0.5em)
  #grid(
    columns: (1fr, 1.3fr),
    gutter: 1.5em,
    [
      - *Parallel Variations:* Automatically spawns an isolated job for every combination in the `matrix`.
      - *Dynamic Variables:* Accessed via `${{ matrix.<key> }}`.
      - *`fail-fast: false`:* Optional setting to prevent one failing job from cancelling all other running variations.
    ],
    [
      #set text(size: 0.85em)
      #raw("jobs:
  test:
    runs-on: ubuntu-latest

    # Same level as 'runs-on' and 'steps'!
    strategy:
      matrix:
        python-version: ['3.10', '3.11', '3.12']

    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v4
        with:
          python-version: ${{ matrix.python-version }}
      - run: pytest", block: true, lang: "yaml")
    ]
  )
]



// Slide 6c: GitHub-hosted vs Self-hosted Runners
#slide(title: "Runners: GitHub-Hosted vs. Self-Hosted")[
  The `runs-on:` keyword defines *where* your job executes:

  #v(0.5em)
  #grid(
    columns: (1fr, 1fr),
    gutter: 1.5em,
    [
      *GitHub-Hosted (`ubuntu-latest`)*
      - *Cloud environments:* Managed by GitHub.
      - *Ephemeral & Clean:* Brand-new environment for every job, destroyed immediately after.
      - *Zero Maintenance:* Ready out of the box with standard pre-installed tools.
      #v(0.3em)
      #raw("runs-on: ubuntu-latest", block: true, lang: "yaml")
    ],
    [
      *Self-Hosted (`self-hosted`)*
      - *Your Hardware:* Runs on your own PC, local server, or private container.
      - *Persistent State:* Files, caches, and custom packages remain on disk between runs.
      - *Custom Access:* Can reach local LAN resources, private DBs, or dedicated GPUs.
      #v(0.3em)
      #raw("runs-on: self-hosted", block: true, lang: "yaml")
    ]
  )
]



// Slide 6d: Registering a Self-Hosted Runner
#slide(title: "Connecting a Self-Hosted Runner")[
  #block(
    fill: rgb("1e88e5").transparentize(80%),
    inset: 10pt,
    radius: 6pt,
    stroke: 1pt + rgb("90caf9"),
    width: 100%
  )[
    *Key Concept:* GitHub *cannot guess* that you have a local machine ready! You must explicitly register it to the repository and establish a *bidirectional communication channel*.
  ]

  #v(0.6em)
  #grid(
    columns: (1.2fr, 1fr),
    gutter: 1.5em,
    [
      *How the Handshake & Polling work:*
      1. *Generate Token:* In the repo, go to *Settings → Actions → Runners → New self-hosted runner*.
      2. *Register (`./config.sh`):* Authenticate your machine with the repo using the temporary token.
      3. *Listen (`./run.sh`):* The local agent opens a bidirectional HTTPS connection (polling GitHub for `[self-hosted]` jobs and sending back live logs/exit codes).
    ],
    [
      #set text(size: 0.85em)
      #raw("# 1. Register the machine to the repo
./config.sh --url https://github.com/org/repo \\
            --token <REGISTRATION_TOKEN>

# 2. Start the agent (must stay active!)
./run.sh
# √ Connected to GitHub
# Listening for Jobs...", block: true, lang: "bash")
    ]
  )
]
 


// Slide 7: How does an Action fail?
#slide(title: "How does an Action fail?")[
  GitHub Actions evaluates the status of each step using *Unix Exit Codes*:

  #v(1em)
  #grid(
    columns: (1.2fr, 1fr),
    gutter: 1.5em,
    [
      - *Exit Code = 0:* Success! The step passes and the workflow moves to the next one.
      
      #v(0.8em)
      - *Exit Code != 0:* Critical error. The runner stops execution immediately and the job turns *red*.
    ],
    [
      #raw("steps:
  - name: This step passes
    run: echo \"All good\"    # exit 0 -> Green

  - name: This step fails
    run: exit 1             # exit 1 -> Red!

  - name: This will never run
    run: echo \"Skipped\"", block: true, lang: "yaml")
    ]
  )

  #v(1.5em)
  #block(
    fill: rgb("e3f2fd"),
    inset: 10pt,
    radius: 4pt,
    width: 100%
  )[
    💡 *Link to the next module:* `pytest` returns a non-zero exit code if even a single test fails, automatically turning your workflow red!
  ]
]


// Slide 8: Pre-built Actions
#slide(title: "Pre-built Actions: Don't reinvent the wheel")[
  Besides `run:` commands, we can use predefined blocks with the `uses:` directive.

  #v(1em)
  #grid(
    columns: (1.2fr, 1fr),
    gutter: 1.5em,
    [
      *The two indispensable Actions:*
      
      1. *`actions/checkout@v4`:*
         - The runner starts completely empty.
         - Without it, the runner *does not have your files*!
      
      2. *`actions/setup-python@v4`:*
         - Configures a specific Python version.
         - Manages pip package caching to speed up runs.
    ],
    [
      #raw("steps:
  - uses: actions/checkout@v4

  - uses: actions/setup-python@v4
    with:
      python-version: '3.12'", block: true, lang: "yaml")
    ]
  )
]



// Slide 9: Theoretical Exercise (Extra)
#slide(title: "Quick Theoretical Exercise (Extra)")[
  What happens when running this workflow? Are there any issues?

  #raw("name: Exercise
on: [push]

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    steps:
      - name: Check files
        run: ls -la

      - name: Read config
        run: cat config.json

      - uses: actions/checkout@v4", block: true, lang: "yaml")

 
  #text(fill: rgb("d32f2f"), weight: "bold")[Answer:] It fails on `cat config.json` with `exit code 1`! The runner is an empty machine and `checkout` was placed *after*, meaning the working directory still lacks the repository files.
]
