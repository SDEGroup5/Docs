#import "./lib/common.typ": course, labNumber, labName
#import "./lib/commonSlide.typ": cover, slide

#cover([Laboratory #labNumber: #labName])


// Code styling
#show raw: code => box(
  fill: luma(90%),
  outset: 0.3em,
  radius: 0.4pt,
)[#code]

#slide("Testing a Python program")[
  #align(center)[
    #grid(
      columns: (49%, 2%, 49%),
      align: center,
      column-gutter: 1em,
      [
        #text(size: 1.7em)[
          *Testing a project*

          #align(left)[
          For this lab, we use:
          - *Pytest*, as our testing framework. It looks for
            all functions named `test_*` or `*_test` and runs
            them as tests.
          - *MagicMock*, to simulate external components such as
            the database connection
          ]
        ]
      ],
      line(length: 100%, angle: 90deg),
      [
        #text(size: 1.7em)[
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
            # TODO: is this right?
            python pytest
            ```
          ]
        ]
      ]
    )
  ]
]

#slide("Code coverage")[
  #grid(
    columns: (60%, 40%),
    [
      #text(size: 1.7em)[
        - The code coverage is the amount of the program's code that
          is invoked by a given test suite.

        - Pytest is able to compute code coverage

        - We can use this metric in GitHub Actions to decide if
          a test suite is good enough for our repository's
          standards
      ]
    ],
    [
      #align(center + horizon)[
        #text(size: 1.7em)[(Room for an image so this is not just a wall of text)]
      ]
    ]
  )
]

#slide("An offline test")[
  #text(size: 1.5em)[
    TODO: decide whether or not we want to keep this
  ]
]

#slide("Running a test with Github Actions")[
  #text(size: 1.7em)[
    - The `run:` in a GitHub Action can also be used to run a script

    - Check inside the `.github/scripts/` directory of the repository

    - The script runs the tests, computes the code coverage and returns
      an exit code depending on the results. This exit code is what
      is used by our Action


      \
      (Space for a question to the class)
  ]
]

#slide("Exercise")[
  #text(size: 1.5em)[
    Fix a test that is currently not working and/or add a code
    coverage control
  ]
]
