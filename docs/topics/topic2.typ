#import "../lib/commonSlide.typ": slide

#slide("Testing a Python program (1/2)", 2)[
  #align(center)[
    #show grid.cell: set text(size: 1.5em)
    #grid(
      columns: (49%, 2%, 49%),
      align: center,
      column-gutter: 1em,
      [
        *Testing a project*

        #align(left)[
          For this lab, we use:
          - *Pytest*, as our testing framework. It looks for
            all functions named `test_*` or `*_test` and runs
            them as tests.
          - *MagicMock*, to simulate external components such as
            the database connection and to isolate the behavior of an object from the one of other eventually present objects.
        ]

      ],
      line(length: 100%, angle: 90deg),
      [
        *Running test locally*

        #align(left)[
          Ensure you're inside the backend project:
          ```bash
          cd backend/
          ```

          Activate the virtual environment:
          ```sh
          source .venv/bin/activate
          ```

          Install missing requirements:
          ```sh
          pip install -r requirements.txt
          ```

          Run the tests:
          ```sh
          python -m pytest
          ```
        ]
      ],
    )
  ]
]

#slide("Testing a Python program (2/2)", 2)[

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

#slide("Code coverage", 2)[
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

#slide("How to test GitHub Actions offline", 2)[
  #text(size: 1.5em)[
    TODO: decide whether or not we want to keep this (act)
  ]
]

#slide("Exercise", 2)[
  #text(size: 2em, weight: "bold")[This will be on the website!!!!!]

  #text(size: 1.5em)[
    Complete a python script to automatically run the test and the coverage. Eventually, make the class to modify a test in order to see what happen when the tests fail.
  ]
]
