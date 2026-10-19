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

  #show grid.cell.where(x: 0): set text(size: 1.2em)

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
        It is not just a build tool, but a *general event-driven automation engine*.

        - *Event-Driven:* Reacts to any action occurring on GitHub:
          - `push` or `pull_request` on specific branches.
          - Tag or release creation.
          - Issue opening/commenting.
          - Manual triggers via UI (`workflow_dispatch`).

        - *Runners:* Clean, ephemeral environment (Ubuntu, macOS, Windows) hosted in the GitHub cloud or local, ready to execute commands on our behalf.
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

  #show grid.cell.where(x: 1): set text(size: 1.2em)

  #align(center + horizon)[
    #grid(
      columns: (1fr, 1fr),
      align: (x, y) => if (x == 0) {
        center + horizon
      } else {
        left + horizon
      },
      inset: 1.2em,
      [
        #figure(
          caption: "Scheme of GitHub actions' workflow",
        )[
          #image("../../img/topic1/image_2.png", width: 70%)
        ]

      ],
      [
        #set list(spacing: 0.65em)

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
]



// Slide 6: General Syntax
#slide("General Syntax Example", 1)[
  #set text(size: 0.8em)
  #align(center + horizon)[
    #raw(
      "name: Typst Compiler Workflow    # Name in GitHub's 'Actions' tab

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
                                 # (Step 1) are both available here",
      block: true,
      lang: "yaml",
    )
  ]
]

// Slide 6b: Execution Strategy (Matrix)
#slide("Execution Strategy: Matrix Builds", 1)[
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
        uses: actions/checkout@v7
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



// Slide 6c: GitHub-hosted vs Self-hosted Runners
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
        #v(1.5em)

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

]



// Slide 6d: Registering a Self-Hosted Runner
#slide("Connecting a Self-Hosted Runner", 1)[
  #hint(txtSize: 1.2em)[
    *Key Concept:* GitHub *cannot guess* that you have a local machine ready! You must explicitly register it to the repository and establish a *bidirectional communication channel*.
  ]


  #v(0.6em)

  #show grid.cell.where(x: 0): set text(size: 1.2em)

  #grid(
    columns: (1.2fr, 1fr),
    inset: 1.5em,
    [
      *How the Handshake & Polling work:*
      1. *Generate Token:* In the repo, go to *Settings → Actions → Runners → New self-hosted runner*.
      2. *Register ( `./config.sh` ):* Authenticate your machine with the repo using the temporary token.
      3. *Listen ( `./run.sh` ):* The local agent opens a bidirectional HTTPS connection (polling GitHub for `[self-hosted]` jobs and sending back live logs/exit codes).
    ],
    [
      #figure(
        caption: "Hosted runner configuration example",
        text(size: 1em)[
          #raw(
            "# 1. Register the machine to the repo
./config.sh 
            --url https://github.com/repo
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

  #v(1em)
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

      #v(0.8em)
      - *Exit Code != 0:* *Critical error*. The runner stops execution immediately and the job turns *red*.
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

  #v(1.5em)
  #hint(txtSize: 1.2em)[
    💡 *Link to the next module:* `pytest` returns a non-zero exit code if even a single test fails, automatically turning your workflow red!
  ]
]


// Slide 8: Pre-built Actions
#slide("Pre-built Actions: Don't reinvent the wheel", 1)[
  Besides `run:` commands, we can use predefined blocks with the `uses:` directive.

  #v(1em)
  #show grid.cell.where(x: 0): set text(size: 1.2em)
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
  - uses: actions/checkout@v7

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



// Slide 9: Theoretical Exercise (Extra)
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
