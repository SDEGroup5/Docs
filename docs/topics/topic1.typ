#import "../lib/commonSlide.typ": hint, slide

#show par: set text(size: 1.2em)

#slide("Environment setup", 1)[
  First, connect to the laboratory website:

  #align(center)[#link("https://sdegroup5.github.io/")[#text(size: 1.2em)[sdegroup5.github.io]]]

  To get started, let's prepare our local environment. Two ways, pick *one*:

  #align(center)[

    #show grid: set text(size: 1.2em)

    #grid(
      grid.vline(x: 1, start: 0, stroke: black),
      columns: (50%, 50%),
      align: (x, y) => if (y == 0) {
        center + horizon
      } else {
        left + horizon
      },
      inset: 0.3em,
      [*Scripted*], [*Manual*],
      [1. *Create* a *public* repository on your GitHub account],
      [1. *Create* a *public* repository on your GitHub account],
      [
        2. *Download and execute* the setup script that will automatically clone the laboratory repository and copy the content on you repository
      ],
      [
        #text(size: 1em)[2. *Clone the laboratory repository* using the following command:]
        #move(dx: 1.5em, dy: -0.5em)[
          #raw(
            "git clone --recurse-submodules https://github.com/SDEGroup5/github-action.git",
            block: true,
            lang: "bash",
          )
        ]
      ],
      [], [3. *Clone* your repository],
      [], [4. *Copy* the files from our repository to your repository],
      [], [5. *Move* to the `dev` branch],
      [], [6. *Add, commit and push* the changes],
    )

  ]

  #v(-1em)
  #hint(txtSize: 1em)[
    *Note:* be sure to be able to create python environment.
  ]

]

// Slide 2: What we'll do in this lab
#slide("What we'll do in this laboratory", 1)[
  #show list: set text(size: 1.3em)

  #align(center + horizon)[
    *Laboratory Overview:*

    - Learn GitHub Actions basics and syntax
    - Automate testing with a simple Python application
      - *Note:* Python is just an example - the concepts apply to any language!
    - Build and compile executables automatically
    - Create and publish Docker containers
    - Put it all together: CI/CD pipeline from code to deployment

    #v(1em)
    #hint(txtSize: 1.1em)[
      *Focus:* We'll concentrate on *GitHub-hosted runners* (cloud execution) throughout this lab.
    ]
  ]

]

// Slide 3: The Problem
#slide("Why do we need CI/CD?", 1)[

  #show grid.cell.where(x: 0): set text(size: 1.3em)

  #align(center + horizon)[
    #grid(
      columns: (1fr, 1fr),
      align: (x, y) => if (x == 0) {
        left + horizon
      } else {
        center + horizon
      },
      inset: 1.2em,
      [
        #set list(marker: [$arrow$])
        *The Typical Scenario:*
        - "It works on my machine!"
        - Missing manually installed dependencies.
        - Forgetting to run tests before pushing.
        - The main branch ( `main` ) breaks for all colleagues.

        *The Automated Solution:*
        - *Objective Verification:* Neutral and reproducible environment.
        - *Continuous Integration (CI):* Automated builds and tests on every change.
        - *Fast Feedback:* Immediate notification of success or failure before merging.
      ],
      [
        #figure(caption: "CI/CD representation", image("../../img/topic1/mdi--gear.svg", width: 80%))

      ],
    )
  ]
]

// Slide 4: Event-Driven Paradigm
#slide("What are GitHub Actions?", 1)[

  #show grid.cell.where(x: 0): set text(size: 1.1em)

  #align(center + horizon)[
    #grid(
      columns: (1fr, 1fr),
      align: (x, y) => if (x == 0) {
        left + horizon
      } else {
        center + horizon
      },
      inset: 1em,
      [
        It is not just a build tool, but a *general event-driven automation engine*.

        *Why move execution remotely?*
        - For large systems, running everything locally is impractical or impossible.
        - Need neutral, reproducible environments with guaranteed resources.
        - Offload heavy computation (builds, tests) to remote infrastructure.

        *Event-Driven* — Reacts to any action on GitHub:
        - `push` or `pull_request` on specific branches.
        - Tag or release creation.
        - Manual triggers via UI (`workflow_dispatch`).

        *Runners:* Clean, ephemeral environment (Ubuntu, macOS, Windows) hosted in the GitHub cloud.
      ],
      [
        #figure(
          caption: "The GitHub logo",
          image("../../img/topic1/mdi--github.svg", width: 70%),
        )

      ],
    )
  ]
]


// Slide 5: Workflow Anatomy
#slide("Anatomy of a Workflow", 1)[

  #show grid.cell.where(x: 1): set text(size: 1.15em)

  #grid(
    columns: (1fr, 1fr),
    align: (x, y) => if (x == 0) {
      center + horizon
    } else {
      left + top
    },
    inset: 1em,
    [
      #figure(
        caption: "Scheme of GitHub actions' workflow",
      )[
        #image("../../img/topic1/image_2.png", width: 70%)
      ]

    ],
    [
      #set list(spacing: 0.5em)
      #v(1em)

      *The fundamental hierarchy of GitHub Actions:*

      - Events: Triggers that start the automation (push, pull_request).
      - Workflows: Top-level automated processes defined in .yml files.
      - Jobs: Units executed on a dedicated, isolated runner.
      - Run in parallel by default, or sequentially via needs: (e.g., deploy after test).
      - New Job = Fresh environment: Files or packages do not persist between jobs!
      - Actions (Steps): Individual tasks or reusable blocks executed on the same runner (sharing files and state).
    ],
  )
]



// Slide 6: General Syntax Example - Overview
#slide("General Syntax Example: Automatic Document Compilation", 1)[
  #show grid.cell.where(x: 0): set text(size: 1.15em)
  #grid(
    columns: (1.2fr, 1fr),
    align: (x, y) => if (x == 0) {
      left + horizon
    } else {
      center + horizon
    },
    inset: 1.2em,
    [
      *Goal:* Automatically compile Typst documents whenever code is pushed to the `main` branch.

      *Key Components:*
      - *Event (`on:`):* Trigger that starts the workflow
      - *Job (`jobs:`):* Unit of work running on a dedicated runner
      - *Steps:* Sequential tasks executed on the same runner

      #v(0.5em)
      #hint(txtSize: 1em)[
        💡 *Remember:* Each job gets a fresh, isolated environment. Steps within a job share files and state!
      ]
    ],
    [
      #figure(
        caption: "Workflow execution flow",
      )[
        #image("../../img/topic1/image_2.png", width: 85%)
      ]
    ],
  )
]

// Slide 6a: General Syntax - Detailed Code
#slide("General Syntax: Step-by-Step Breakdown", 1)[
  #set text(size: 0.9em)
  #raw(
    "name: Typst Compiler Workflow    # Name displayed in GitHub's 'Actions' tab

on:                              # 1. EVENT: What triggers this workflow?
  push:                          # Reacts when commits are pushed...
    branches: [ \"main\" ]         # ...ONLY if pushed to the 'main' branch

jobs:                            # 2. JOBS: Units of work (run in parallel by default)
  compile:                       # Unique Job ID (you can name it freely)
    runs-on: ubuntu-latest       # Spins up a fresh Ubuntu virtual machine
                                 # (the isolated Runner in GitHub's cloud)
    steps:                       # 3. STEPS: Sequential tasks on the SAME runner
      
      - name: Checkout code      # Step 1: Get the repository files
        uses: actions/checkout@v4
                                 # 'uses:' imports a pre-built Action
                                 # This clones your repo into the empty runner!
                                 # Format: 'owner/repo@version'
                                 # - 'actions/' = official GitHub organization
                                 # - '@v4' = pinned major version (stable API)

      - name: Compile document   # Step 2: Run the compilation
        run: ./typst compile ./docs/main.typ
                                 # 'run:' executes shell commands
                                 # Both './typst' and repo files from Step 1
                                 # are available in the same working directory",
    block: true,
    lang: "yaml",
  )
]



// Slide 6b: GitHub-hosted vs Self-hosted Runners
#slide("Runners: GitHub-Hosted vs. Self-Hosted", 1)[
  The `runs-on:` keyword defines *where* your job executes:

  #v(0.5em)

  #show grid: set text(size: 1.1em)

  #align(top + center)[
    #grid(
      grid.vline(x: 1, start: 0, stroke: black),
      columns: (50%, 50%),
      align: left + horizon,
      inset: 1em,
      [
        *GitHub-Hosted ( `ubuntu-latest` )*

        - *Cloud environments:* Managed by GitHub.
        - *Ephemeral & Clean:* Brand-new environment for every job, destroyed immediately after.
        - *Zero Maintenance:* Ready out of the box with standard pre-installed tools.
        - *Our focus:* We'll use GitHub-hosted runners throughout this lab.
        #v(1em)

        #raw("runs-on: ubuntu-latest", block: true, lang: "yaml")
      ],
      [
        *Self-Hosted ( `self-hosted` )*

        - *Your Hardware:* Runs on your own PC, local server, or private container.
        - *Persistent State:* Files, caches, and custom packages remain on disk between runs.
        - *Custom Access:* Can reach local LAN resources, private DBs, or dedicated GPUs.
        #v(0.3em)
        #raw("runs-on: self-hosted", block: true, lang: "yaml")
      ],
    )
  ]

  #v(1em)
  #hint(txtSize: 1.1em)[
    💡 *Note:* Self-hosted runners exist and are useful for advanced scenarios, but *we will focus exclusively on GitHub-hosted runners* in this laboratory.
  ]

]



// Slide 6c: Registering a Self-Hosted Runner (Reference Only)
#slide("Self-Hosted Runner Setup (Reference)", 1)[
  
  #hint(txtSize: 1em)[
    *Important:* This slide is for reference only. *We will NOT use self-hosted runners in this lab* — we focus on GitHub-hosted runners instead.
  ]

  #v(0.6em)

  #show grid.cell.where(x: 0): set text(size: 1.05em)

  #grid(
    columns: (1.2fr, 1fr),
    inset: 1em,
    [
      *How the Handshake & Polling work (for self-hosted):*
      
      1. *Generate Token:* In the repo, go to *Settings → Actions → Runners → New self-hosted runner*.
      
      2. *Register ( `./config.sh` ):* Authenticate your machine with the repo using the temporary token.
      
      3. *Listen ( `./run.sh` ):* The local agent opens a bidirectional HTTPS connection, polling GitHub for `[self-hosted]` jobs and sending back live logs/exit codes.

      #v(0.5em)
      #text(size: 0.9em, style: "italic")[This is shown for completeness — we concentrate on cloud-based GitHub-hosted runners.]
    ],
    [
      #figure(
        caption: "Self-hosted runner configuration",
        text(size: 0.95em)[
          #raw(
            "# 1. Register the machine to the repo
./config.sh \
  --url https://github.com/repo \
  --token <REGISTRATION_TOKEN>

# 2. Start the agent (must stay active!)
./run.sh",
            block: true,
            lang: "bash",
          )],
      )
    ],
  )
]



// Slide 7: How does an Action fail?
#slide("How does an Action fail?", 1)[
  GitHub Actions evaluates the status of each step using *Unix Exit Codes*:

  #v(0.5em)
  #show grid.cell.where(x: 0): set text(size: 1.2em)
  #grid(
    columns: (1.2fr, 1fr),
    align: (x, y) => if (x == 0) {
      left + horizon
    } else {
      center + horizon
    },
    inset: 1.2em,
    [
      - *Exit Code = 0:* *Success*. The step passes and the workflow moves to the next one.

      #v(0.5em)
      - *Exit Code != 0:* *Critical error*. The runner stops execution immediately and the job turns *red*.

      #v(0.5em)
      *Real-world examples of non-zero exit codes:*
      - Compilation failed (syntax errors, missing dependencies)
      - A test fails (assertion error, unexpected behavior)
      - Linter finds code style violations
      - Missing required files or invalid configuration
    ],
    [
      #figure(
        caption: "Exit codes example",
        raw(
          "steps:
  - name: This step passes
    run: echo \"All good\" # exit 0 -> Green

  - name: This step fails
    run: exit 1           # exit 1 -> Red

  - name: This will never run
    run: echo \"Skipped\"",
          block: true,
          lang: "yaml",
        ),
      )
    ],
  )

  #hint(txtSize: 1.1em)[
    💡 *Link to the next module:* `pytest` returns a non-zero exit code if even a single test fails, automatically turning your workflow red!
  ]
]


// Slide 8: Pre-built Actions - Part 1
#slide("Pre-built Actions: Don't reinvent the wheel", 1)[
  Besides `run:` commands, we can use predefined blocks with the `uses:` directive.

  #v(1em)
  #show grid.cell.where(x: 0): set text(size: 1.3em)
  #grid(
    columns: (1.2fr, 1fr),
    align: (x, y) => if (x == 0) {
      left + horizon
    } else {
      center + horizon
    },
    inset: 1.5em,
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
      #figure(
        caption: "Reusable action example",
        raw(
          "steps:
  - uses: actions/checkout@v4

  - uses: actions/setup-python@v4
    with:
      python-version: '3.12'",
          block: true,
          lang: "yaml",
        ),
      )

    ],
  )
]



// Slide 9: Understanding Action Versioning
#slide("Understanding Action Versioning", 1)[

  #show list: set text(size: 1.25em)

  *How to read Action versions:*

  - *Format:* `owner/repository@version`
  
  - *`@v4`* = Major version (recommended for stability)
    - Automatically uses the latest v4.x release
    - Stable API within major version 4
  
  - *Repository location:* Imports from the official GitHub Actions repository
  
  - *Example:* `actions/checkout@v4` 
    - Pulls from `github.com/actions/checkout`
    - Uses the latest version 4.x

  #v(0.8em)
  #hint(txtSize: 1.1em)[
    💡 Using major versions (`@v4`) instead of exact versions (`@v4.1.2`) ensures you automatically get bug fixes and improvements while maintaining API compatibility.
  ]
]



// Slide 10: Theoretical Exercise (Extra)
#slide("Quick Theoretical Exercise (Extra)", 1)[

  #text(size: 1.2em, weight: "bold")[This will be on the website!!!!!]

  What happens when running this workflow? Are there any issues?

  #align(center + horizon)[
    #raw(
      "name: Exercise
on: [push]

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    steps:
      - name: Check files
        run: ls -la

      - name: Read config
        run: cat config.json

      - uses: actions/checkout@v4",
      block: true,
      lang: "yaml",
    )
  ]


  #text(fill: rgb("d32f2f"), weight: "bold")[Answer:] It fails on `cat config.json` with `exit code 1`. The runner is an empty machine and `checkout` was placed *after*, meaning the working directory still lacks the repository files.]



// Slide 11: Execution Strategy (Matrix) - Optional Advanced Topic
#slide("Matrix Builds", 1)[
  

  #v(-0.5em)
  To run the same job across multiple versions or OS environments in parallel, we use the `strategy:` directive at the *exact same indentation level* as `runs-on:` and `steps:`

  #v(-1em)
  #show grid: set text(size: 1.15em)
  #grid(
    columns: (1fr, 1.3fr),
    [
      #v(2em)
      - *Parallel Variations:* Automatically spawns an isolated job for every combination in the `matrix`.
      - *Dynamic Variables:* Accessed via `${{ matrix.<key> }}`.
      - *`fail-fast: false`:* Optional setting to prevent one failing job from cancelling all other running variations.
    ],
    [
      #figure(
        caption: "Matrix build example",

        text(size: 0.85em)[
          #raw(
            "jobs:
  test:
    runs-on: ubuntu-latest

    # Same level as 'runs-on' and 'steps'!
    strategy:
      matrix:
        python-version: ['3.10', '3.11', '3.12']

    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: ${{ matrix.python-version }}
      - name: Run tests
        run: python3 -m pytest",
            block: true,
            lang: "yaml",
          )
        ],
      )
    ],
  )
]
