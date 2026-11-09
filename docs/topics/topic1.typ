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
    *Note:* be sure to be able to create python environment. Additionally, the library `psycopg2`, used for postgres, requires `libpq-dev` to be installed. To avoid the issue, modify the backend `requirements.txt` files to use `psycopg2-binary==2.9.13` instead of `psycopg2==2.9.13` .
  ]

]

// Slide 2: What we'll do in this lab
#slide("What we'll do in this laboratory", 1)[
  #text(size: 1.6em, weight: "bold")[Laboratory Overview:]

  #v(0.8em)

  #set list(spacing: 0.7em)
  #show list: set text(size: 2.2em)

  - Learn GitHub Actions basics and syntax
  - Automate testing with a simple Python application
  - Build and compile executables automatically
  - Create and publish Docker containers
  - Put it all together: CI/CD pipeline from code to deployment

  #v(1em)

  #align(center)[
    #hint(txtSize: 1.2em)[
      *Note:* We'll use Python as our example language, but the same concepts apply to any language!
    ]
  ]

  #v(0.5em)


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
        #figure(caption: "CI/CD representation", image("../../img/topic1/mdi--gear.svg", width: 60%))

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
        - Manual triggers via UI ( `workflow_dispatch` ).

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


// Slide 5a: Workflow Anatomy - High Level
#slide("Anatomy of a Workflow: The Big Picture", 1)[

  #grid(
    columns: (1fr, 1.1fr),
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
        #image("../../img/topic1/image_2.png", width: 80%)
      ]
    ],
    [
      #set list(spacing: 0.6em)
      #show list: set text(size: 1.1em)
      #v(0.5em)

      *Three layers, from trigger to execution:*

      - *Event:* Something happens on GitHub (a push, a pull request, a tag...) and *triggers* the automation.

      - *Workflow:* A YAML file in `.github/workflows/` that describes *what to do* when an event fires. A repo can have multiple workflows for different purposes (CI, release, deploy...).

      - *Job:* A workflow contains one or more jobs. Each job runs on its own *isolated, fresh machine* (the runner). Jobs run *in parallel by default*.

      #v(0.5em)
      #hint(txtSize: 1em)[
        Jobs can be made sequential using `needs`: e.g. run `deploy` only after `test` passes.
      ]
    ],
  )
]



// Slide 5b: Workflow Anatomy - Jobs and Steps
#slide("Anatomy of a Workflow: Jobs and Steps", 1)[

  #grid(
    columns: (1fr, 1fr),
    align: left + top,
    inset: 1.2em,
    [
      #set list(spacing: 0.55em)
      #show list: set text(size: 1.1em)

      *Inside a Job: Steps*

      A job contains a sequence of *Steps*, executed one after another on the *same runner*:

      - Each step is either a shell command ( `run:` ) or a pre-built Action ( `uses:` ).
      - Steps *share the filesystem*: files created in step 1 are available in step 2.
      - If one step fails (exit code ≠ 0), the job stops immediately.

      #v(0.8em)

      *Key isolation rule:*

      - *Between jobs:* completely isolated. A fresh machine, no shared files.
      - *Within a job:* shared environment. All steps see the same working directory.
    ],
    [
      #set list(spacing: 0.55em)
      #show list: set text(size: 1.1em)

      *A concrete example:*

      #v(0.4em)

      #raw(
        "jobs:
  compile:
    runs-on: ubuntu-latest  # fresh machine

    steps:
      - uses: actions/checkout@v4
        # Step 1: repo files now available

      - run: ./typst compile doc.typ
        # Step 2: can use files from step 1!",
        block: true,
        lang: "yaml",
      )

      #v(0.6em)
      #hint(txtSize: 1em)[
        The runner starts *completely empty*: without `checkout`, your files don't exist on it!
      ]
    ],
  )
]

// Slide 8a: General Syntax - Trigger and Job
#slide("General Syntax (1/2): Trigger and Job Structure", 1)[
  #set text(size: 1.5em)
  #align(center + horizon)[
    #raw(
      "name: Typst Compiler Workflow    # Name displayed in GitHub's 'Actions' tab
                                 # Shown in the repository's Actions tab

on:                              # 1. EVENT: What triggers this workflow?
  push:                          # Reacts when commits are pushed...
    branches: [ \"main\" ]         # ...ONLY if pushed to 'main'
                                 # (other branches are ignored)

jobs:                            # 2. JOBS: Units of work
                                 # Multiple jobs run in PARALLEL by default
  compile:                       # Unique Job ID: you choose the name freely
    runs-on: ubuntu-latest       # Spins up a FRESH Ubuntu virtual machine
                                 # in GitHub's cloud for every run
                                 # Other options: windows-latest, macos-latest",
      block: true,
      lang: "yaml",
    )
  ]
]

// Slide 8b: General Syntax - Steps
#slide("General Syntax (2/2): Steps Inside a Job", 1)[
  #set text(size: 1.5em)
  #align(center + horizon)[
    #raw(
      "    steps:                       # 3. STEPS: Sequential tasks on the SAME runner

      - name: Checkout code      # Step 1: label shown in GitHub UI
        uses: actions/checkout@v4
                                 # 'uses:' imports a pre-built Action
                                 # Without this, the runner is EMPTY —
                                 # your repo files do not exist yet!
                                 # Format: 'owner/repo@version'
                                 #   'actions/' = official GitHub org
                                 #   '@v4'      = pinned major version

      - name: Compile document   # Step 2: runs after Step 1 completes
        run: ./typst compile ./docs/main.typ
                                 # 'run:' executes any shell command
                                 # './typst' and all repo files from Step 1
                                 # are available in the same working directory",
      block: true,
      lang: "yaml",
    )
  ]
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
        #v(1em)
        #raw("runs-on: self-hosted", block: true, lang: "yaml")
      ],
    )
  ]

  #v(1em)
  #hint(txtSize: 1.1em)[
    *Note:* Self-hosted runners exist and are useful for advanced scenarios, but *we will focus exclusively on GitHub-hosted runners* in this laboratory.
  ]

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
      #show raw: set text(size: 1.4em)
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

  #hint(txtSize: 1.075em)[
    *Link to the next module:* `pytest` returns a non-zero exit code if even a single test fails, automatically turning your workflow red!
  ]
]


// Slide 8: Pre-built Actions - Part 1
#slide("Pre-built Actions", 1)[

  #v(1em)
  #show grid.cell.where(x: 0): set text(size: 1.5em)
  #grid(
    columns: (1.2fr, 1fr),
    align: (x, y) => if (x == 0) {
      left + horizon
    } else {
      center + horizon
    },
    inset: 1em,
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
      #show raw: set text(size: 1.4em)
      #figure(
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
#slide("Action Versioning", 1)[

  #v(0.8em)
  #show grid.cell.where(x: 0): set text(size: 1.1em)
  #grid(
    columns: (1.2fr, 1fr),
    align: (x, y) => if (x == 0) {
      left + horizon
    } else {
      center + horizon
    },
    inset: 1.5em,
    [
      *Format:* `owner/repository@version`

      - *`owner/repository`:* the GitHub org and repo where the Action lives.
        - `actions/` = official GitHub organization
        - Any public repo can publish an Action

      - *`@v4`:* pins to a major version  automatically gets the latest `v4.x` patch while keeping a stable API.

      - *Alternative:* `@v4.1.2` pins to an exact release (more predictable, but no auto bug fixes).
    ],
    [
      #show raw: set text(size: 1.4em)
      #figure(
        raw(
          "# Major version (recommended)
uses: actions/checkout@v4
uses: actions/setup-python@v4

# Exact version (fully pinned)
uses: actions/checkout@v4.1.2

# Commit SHA (most secure)
uses: actions/checkout@abc1234",
          block: true,
          lang: "yaml",
        ),
      )
    ],
  )


]



// Slide 10: Theoretical Exercise (Extra)
#slide("Theoretical Exercises", 1)[

  #align(center + horizon)[
    #text(size: 2.5em, weight: "bold")[On the website!]

    #v(2em)

    #text(size: 2.3em)[
      Go to: #link("https://sdegroup5.github.io/")[#text(fill: rgb("1565c0"))[*sdegroup5.github.io*]]
    ]

    #v(1em)


  ]

]


/*
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
*/
