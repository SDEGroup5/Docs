#import "../lib/commonSlide.typ": slide

#slide("Automating Testing with GitHub Actions", 2)[
  #align(center + horizon)[
    #text(size: 3em)[*Part 2*\ *Automating Testing with GitHub Actions*]
  ]
]

#slide("Testing a Python program (1/3)", 2)[
  #align(center)[
    #show grid.cell: set text(size: 1.5em)
    #grid(
      columns: (50%, 50%),
      align: center,
      column-gutter: 1em,
      [
        *Testing a project*

        #align(left)[
          For this lab, we will use:
          - A simple application to simulate our service.
          - *Pytest*, as our testing framework. It looks for
            all functions named `test_*` or `*_test` and runs
            them as tests.

          - A *dedicated script* for running tests and
            computing certain metrics (more on this later).
        ]

      ],
      figure(
        caption: [A screenshot of the output of pytest],
        image("../../img/topic2/test_output.png", height: 90%)
      )
      ,
    )
  ]
]

#slide([About the program], 2)[
    #show text: set text(size: 1.7em)
    - Simple python program meant to simulate a generic service
    
    \
    - A single GET endpoint at\
      `/json/getData`\
      served on port 5000

    \
    - The endpoint returns some sample data read from a JSON file

    \
    - Run with\
      ```sh pyhton -m src.main```\
      from within the `app` directory and in the virtual environment

    \
    - Tests are already provided
]

#slide("Testing a Python program (2/3)", 2)[
  #align(center)[
    #show text: set text(size: 1.7em)
        *Running test locally*

        
        #align(left)[
          Activate the virtual environment:
          ```sh
          source app/.venv/bin/activate
          ```

          \
          Install missing requirements:
          ```sh
          pip install -r app/requirements.txt
          ```

          \
          Run the tests:
          ```sh
          python -m pytest app/test/test.py
          ```

          \
          Now, what happens if you run the tests while feeding
          the program an _invalid_ JSON file or break something in
          the code?
      ]
  ]
]

#slide("Testing a Python program (3/3)", 2)[
  #align(center + horizon)[
    #grid(
      columns: (50%, 50%),
      align: (x, y) => if (x == 0) {
        left + horizon
      } else {
        center + horizon
      },
      [
        #text(size: 1.7em)[
          - The *code coverage* is the amount of the program's statements that
            is invoked by a given test suite.

          - *Pytest* is able to compute code coverage thanks to the `pytest-cov` module

          - We can use this metric in GitHub Actions to decide if
            a test suite is good enough for our repository's
            standards
        ]
      ],
      [
        #show figure.caption: set text(size: 1.4em)
        #figure(
          caption: "A website use to upload coverage information",
          image("../../img/topic2/coveralls.png", width: 100%),
        )

      ],
    )
  ]

]

#slide("Running Tests with GitHub Actions", 2)[

  #show grid: set text(size: 1.7em)
  #grid(
    columns: (40%, 60%),
    inset: 1.2em,
    [
      - The `run:` in a GitHub Action can also be used to run a script

      - Check inside the `.github/scripts/` directory of the repository

      - The script runs the tests, computes the code coverage and returns
        an exit code depending on the results. This exit code is what
        is used by our Action
    ],
    [
      #show figure.caption: set text(size: 0.8em)
      #figure(
        caption: "Python testing in a GitHub action example",
        text(size: 0.85em)[
          #raw(
            "jobs:
  test:
    runs-on: ubuntu-latest

    # Same level as 'runs-on' and 'steps'!
    strategy:
      matrix:
        python-version: ['3.12']

    steps:
      - name: Checkout code
        uses: actions/checkout@v7
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: ${{ matrix.python-version }}
      - name: Run tests
        run: python3 .github/scripts/execute_tests.py",
            block: true,
            lang: "yaml",
          )],
      )
    ],
  )

]

#slide("Exercise", 2)[
  //#text(size: 2em, weight: "bold")[This will be on the website!!!!!]

  #text(size: 1.7em)[
    - Complete the `.github/scripts/execute_tests.py` script to
      automatically run the test and the coverage. Then run
      the script with both a valid and invalid JSON file like
      in the previous exercise to ensure it works.\
      ```sh python .github/scripts/execute_tests.py```

    Instructions and TODOs are found in the file itself as comments.
  ]

  \

  #underline()[
    #text(size: 1.7em)[
      This script will be used in the rest of the exercises
      for this lab, if there's any problems raise your hand.
    ]
  ]


]


#slide("Exercise", 2)[
  TODO: slide about the exercise on running the tests via github actions
]
