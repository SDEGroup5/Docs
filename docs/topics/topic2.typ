#import "../lib/commonSlide.typ": slide

#slide("Automating Testing with GitHub Actions", 2)[
  #align(center + horizon)[
    #text(size: 3em)[*Part 2*\ *Automating Testing with GitHub Actions*]
  ]
]

#slide("Testing a Python program", 2)[
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
        image("../../img/topic2/testOutput.png", height: 90%),
      ),
    )
  ]
]

#slide([About the program (1/5)], 2)[
  #show text: set text(size: 1.7em)

  #grid(
    columns: (50%, 50%),
    [
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
        *from within the `app` directory* and in the virtual environment

      \
      - Tests are already provided
    ],
    [
      #show text: set text(size: 0.9em)
      #figure(
        caption: "Diagram of the application",
        image("/img/topic2/completeDiagram.png"),
      )
    ],
  )
]

#slide([About the program (2/5)], 2)[
  #show text: set text(size: 1.5em)
  #align(center + horizon)[
    #figure(
      caption: "GET request arriving to the server",
      image("/img/topic2/serverGET.png"),
    )
  ]
]

#slide([About the program (3/5)], 2)[
  #show text: set text(size: 1.5em)
  #align(center + horizon)[
    #figure(
      caption: "GET request routed by the controller",
      image("/img/topic2/controllerGET.png"),
    )
  ]
]

#slide([About the program (4/5)], 2)[
  #show text: set text(size: 1.5em)
  #align(center + horizon)[
    #figure(
      caption: "GET request managed by the service",
      image("/img/topic2/jsonServiceGET.png"),
    )
  ]
]

#slide([About the program (5/5)], 2)[
  #show text: set text(size: 1.5em)
  #align(center + horizon)[
    #figure(
      caption: "GET response",
      image("/img/topic2/completeResponse.png"),
    )
  ]
]

#slide("About the tests (1/12)", 2)[
  #show text: set text(size: 1.5em)
  #grid(
    columns: (77%, 23%),
    [
      ```py
      def test_server_get_successful():
          json_path: str = "./app/json/data.json"
          json_data: str = ""

          try:
              with open(json_path, encoding="utf-8") as file:
                  data = json.load(file)
                  json_data = json.dumps(data)
          except (FileNotFoundError, json.JSONDecodeError):
              pytest.fail("JSON file not found")

          response: tuple[bytes,
                          int] = create_and_contact_server("GET", "/json/getData",
                                                           json_path)

          assert json.loads(response[0].decode("utf-8")) == {"data": json_data}
          assert response[1] == 200
      ```
    ],
    [
      #show text: set text(size: 1.5em)
      + Load the JSON
    ],
  )
  #place(dy: -18em)[
    #rect(stroke: 2pt + red, width: 76%, height: 30%)
  ]
]

#slide("About the tests (2/12)", 2)[
  #show text: set text(size: 1.5em)
  #grid(
    columns: (77%, 23%),
    [
      ```py
      def test_server_get_successful():
          json_path: str = "./app/json/data.json"
          json_data: str = ""

          try:
              with open(json_path, encoding="utf-8") as file:
                  data = json.load(file)
                  json_data = json.dumps(data)
          except (FileNotFoundError, json.JSONDecodeError):
              pytest.fail("JSON file not found")

          response: tuple[bytes,
                          int] = create_and_contact_server("GET", "/json/getData",
                                                           json_path)

          assert json.loads(response[0].decode("utf-8")) == {"data": json_data}
          assert response[1] == 200
      ```
    ],
    [
      #show text: set text(size: 1.5em)
      + Load the JSON #v(1em)
      + Contact the app \ and get the \ response
    ],
  )
  #place(dy: -9em)[
    #rect(stroke: 2pt + red, width: 76%, height: 20%)
  ]
]

#slide("About the tests (3/12)", 2)[
  #show text: set text(size: 1.5em)
  #grid(
    columns: (77%, 23%),
    [
      ```py
      def test_server_get_successful():
          json_path: str = "./app/json/data.json"
          json_data: str = ""

          try:
              with open(json_path, encoding="utf-8") as file:
                  data = json.load(file)
                  json_data = json.dumps(data)
          except (FileNotFoundError, json.JSONDecodeError):
              pytest.fail("JSON file not found")

          response: tuple[bytes,
                          int] = create_and_contact_server("GET", "/json/getData",
                                                           json_path)

          assert json.loads(response[0].decode("utf-8")) == {"data": json_data}
          assert response[1] == 200
      ```
    ],
    [
      #show text: set text(size: 1.5em)
      + Load the JSON #v(1em)
      + Contact the app \ and get the \ response #v(1em)
      + Check the \ response and the status code
    ],
  )
  #place(dy: -3.5em)[
    #rect(stroke: 2pt + red, width: 76%, height: 12%)
  ]
]

#slide("About the tests (4/12)", 2)[
  #show text: set text(size: 1.5em)
  #grid(
    columns: (77%, 23%),
    [
      ```py
      @pytest.mark.parametrize(
          "endpoint, path, expected_st, expected_response",
          [("/number", "/json/data.json", 404, {
              "error": "Endpoint not found"
          }),
           ("/json/getData", "/non/existent/dir/data.json", 500, {
               "error": "Internal server error"
           })],
      )

      def test_server_get_failure(endpoint: str, path: str, expected_st: int,
                                  expected_response: dict):
          response: tuple[bytes,
                          int] = create_and_contact_server("GET", endpoint, path)

          assert json.loads(response[0].decode("utf-8")) == expected_response
          assert response[1] == expected_st
      ```
    ],
    [
      #show text: set text(size: 1.5em)
      + Parametrized \ test: execute the \ same test with \ multiple input
    ],
  )
  #place(dy: -23.5em)[
    #rect(stroke: 2pt + red, width: 75%, height: 42%)
  ]
]

#slide("About the tests (5/12)", 2)[
  #show text: set text(size: 1.5em)
  #grid(
    columns: (77%, 23%),
    [
      ```py
      @pytest.mark.parametrize(
          "endpoint, path, expected_st, expected_response",
          [("/number", "/json/data.json", 404, {
              "error": "Endpoint not found"
          }),
           ("/json/getData", "/non/existent/dir/data.json", 500, {
               "error": "Internal server error"
           })],
      )

      def test_server_get_failure(endpoint: str, path: str, expected_st: int,
                                  expected_response: dict):
          response: tuple[bytes,
                          int] = create_and_contact_server("GET", endpoint, path)

          assert json.loads(response[0].decode("utf-8")) == expected_response
          assert response[1] == expected_st
      ```
    ],
    [
      #show text: set text(size: 1.5em)
      + Parametrized \ test: execute the \ same test with \ multiple input #v(1em)
      + Contact the app \ and get the \ response
    ],
  )
  #place(dy: -10em)[
    #rect(stroke: 2pt + red, width: 75%, height: 20%)
  ]
]

#slide("About the tests (6/12)", 2)[
  #show text: set text(size: 1.5em)
  #grid(
    columns: (77%, 23%),
    [
      ```py
      @pytest.mark.parametrize(
          "endpoint, path, expected_st, expected_response",
          [("/number", "/json/data.json", 404, {
              "error": "Endpoint not found"
          }),
           ("/json/getData", "/non/existent/dir/data.json", 500, {
               "error": "Internal server error"
           })],
      )

      def test_server_get_failure(endpoint: str, path: str, expected_st: int,
                                  expected_response: dict):
          response: tuple[bytes,
                          int] = create_and_contact_server("GET", endpoint, path)

          assert json.loads(response[0].decode("utf-8")) == expected_response
          assert response[1] == expected_st
      ```
    ],
    [
      #show text: set text(size: 1.5em)
      + Parametrized \ test: execute the \ same test with \ multiple input #v(1em)
      + Contact the app \ and get the \ response #v(1em)
      + Check the \ response and the status code
    ],
  )
  #place(dy: -3em)[
    #rect(stroke: 2pt + red, width: 75%, height: 10%)
  ]
]

#slide("About the tests (7/12)", 2)[
  #show text: set text(size: 1.5em)
  #grid(
    columns: (70%, 30%),
    [
      ```py
      def create_and_contact_server(method: str, url: str,
                                json_path: str) -> tuple[bytes, int]:

      json_service: JsonService = JsonService(json_path)

      json_controller: IController = JsonController(json_service)

      controller_dict: dict[str, IController] = {"json": json_controller}
      server_partial: partial[Server] = partial(
          Server, endpoint_controllers=controller_dict)

      server = HTTPServer(("0.0.0.0", 5000), server_partial)

      server_thread: threading.Thread = threading.Thread(
          target=server.serve_forever)

      server_thread.start()

      header: dict = {
          "Content-Type": "application/json",
      }
      ```
    ],
    [
      #show text: set text(size: 1.5em)
      + Create the app components
    ],
  )
  #place(dy: -24em)[
    #rect(stroke: 2pt + red, width: 67%, height: 40%)
  ]
]

#slide("About the tests (8/12)", 2)[
  #show text: set text(size: 1.5em)
  #grid(
    columns: (70%, 30%),
    [
      ```py
      def create_and_contact_server(method: str, url: str,
                                json_path: str) -> tuple[bytes, int]:

      json_service: JsonService = JsonService(json_path)

      json_controller: IController = JsonController(json_service)

      controller_dict: dict[str, IController] = {"json": json_controller}
      server_partial: partial[Server] = partial(
          Server, endpoint_controllers=controller_dict)

      server = HTTPServer(("0.0.0.0", 5000), server_partial)

      server_thread: threading.Thread = threading.Thread(
          target=server.serve_forever)

      server_thread.start()

      header: dict = {
          "Content-Type": "application/json",
      }
      ```
    ],
    [
      #show text: set text(size: 1.5em)
      + Create the app \ components #v(1em)
      + Start the app
    ],
  )
  #place(dy: -14em)[
    #rect(stroke: 2pt + red, width: 67%, height: 30%)
  ]
]

#slide("About the tests (9/12)", 2)[
  #show text: set text(size: 1.5em)
  #grid(
    columns: (60%, 40%),
    [
      ```py
      header: dict = {
          "Content-Type": "application/json",
      }

      con: HTTPConnection = HTTPConnection("127.0.0.1", 5000)
      con.request(method=method, url=url, headers=header)

      response: HTTPResponse = con.getresponse()

      response_bytes: bytes = response.read()
      response_code: int = response.status

      con.close()

      server.shutdown()
      server.server_close()
      server_thread.join()

      return response_bytes, response_code
      ```
    ],
    [
      #show text: set text(size: 1.5em)
      + Create the app components #v(1em)
      + Start the app #v(1em)
      + Prepare the packet, open the connection and make the request
    ],
  )
  #place(dy: -25em)[
    #rect(stroke: 2pt + red, width: 55%, height: 25%)
  ]
]

#slide("About the tests (10/12)", 2)[
  #show text: set text(size: 1.5em)
  #grid(
    columns: (60%, 40%),
    [
      ```py
      header: dict = {
          "Content-Type": "application/json",
      }

      con: HTTPConnection = HTTPConnection("127.0.0.1", 5000)
      con.request(method=method, url=url, headers=header)

      response: HTTPResponse = con.getresponse()

      response_bytes: bytes = response.read()
      response_code: int = response.status

      con.close()

      server.shutdown()
      server.server_close()
      server_thread.join()

      return response_bytes, response_code
      ```
    ],
    [
      #show text: set text(size: 1.5em)
      + Create the app \ components #v(1em)
      + Start the app #v(1em)
      + Prepare the packet, open the connection and make the request #v(1em)
      + Save the response data
    ],
  )
  #place(dy: -16em)[
    #rect(stroke: 2pt + red, width: 55%, height: 20%)
  ]
]

#slide("About the tests (11/12)", 2)[
  #show text: set text(size: 1.5em)
  #grid(
    columns: (60%, 40%),
    [
      ```py
      header: dict = {
          "Content-Type": "application/json",
      }

      con: HTTPConnection = HTTPConnection("127.0.0.1", 5000)
      con.request(method=method, url=url, headers=header)

      response: HTTPResponse = con.getresponse()

      response_bytes: bytes = response.read()
      response_code: int = response.status

      con.close()

      server.shutdown()
      server.server_close()
      server_thread.join()

      return response_bytes, response_code
      ```
    ],
    [
      #show text: set text(size: 1.5em)
      + Create the app \ components #v(1em)
      + Start the app #v(1em)
      + Prepare the packet, open the connection and make the request #v(1em)
      + Save the response data #v(1em)
      + Terminate the app
    ],
  )
  #place(dy: -9.5em)[
    #rect(stroke: 2pt + red, width: 55%, height: 25%)
  ]
]

#slide("About the tests (12/12)", 2)[
  #show text: set text(size: 1.5em)
  #grid(
    columns: (60%, 40%),
    [
      ```py
      header: dict = {
          "Content-Type": "application/json",
      }

      con: HTTPConnection = HTTPConnection("127.0.0.1", 5000)
      con.request(method=method, url=url, headers=header)

      response: HTTPResponse = con.getresponse()

      response_bytes: bytes = response.read()
      response_code: int = response.status

      con.close()

      server.shutdown()
      server.server_close()
      server_thread.join()

      return response_bytes, response_code
      ```
    ],
    [
      #show text: set text(size: 1.5em)
      + Create the app \ components #v(1em)
      + Start the app #v(1em)
      + Prepare the packet, open the connection and make the request #v(1em)
      + Save the response data #v(1em)
      + Terminate the app #v(1em)
      + Return the data
    ],
  )
  #place(dy: -1.5em)[
    #rect(stroke: 2pt + red, width: 55%, height: 5%)
  ]
]

#slide("Testing a Python program (1/2)", 2)[
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
      python3 -m pytest app/test/test.py
      ```

      \
      Now, what happens if you run the tests while feeding
      the program an _invalid_ #h(0.3em) JSON file or break something in
      the code?
    ]
  ]
]

#slide("Testing a Python program (2/2)", 2)[
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
          caption: "A website used to upload coverage information",
          image("../../img/topic2/coveralls.png", width: 100%),
        )

      ],
    )
  ]

]

#slide("Running Tests with GitHub Actions (1/4)", 2)[

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
            "steps:
    - name: Checkout repository
      uses: actions/checkout@v7

    - name: Set up Python 3.14
      uses: actions/setup-python@v7
      with:
        python-version: \"3.14\"

    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        if [ -f app/requirements.txt ]; then pip install -r app/requirements.txt; fi

    - name: Test with testing script
      run: python3 .github/scripts/execute_tests.py
",
            block: true,
            lang: "yaml",
          )],
      )
    ],
  )
]

#slide("Running Tests with GitHub Actions (2/4)", 2)[

  #show grid: set text(size: 1.7em)
  #grid(
    columns: (60%, 40%),
    [
      #show figure.caption: set text(size: 0.8em)
      #figure(
        caption: "Python testing in a GitHub action example",
        text(size: 0.85em)[
          #raw(
            "steps:
    - name: Checkout repository
      uses: actions/checkout@v7

    - name: Set up Python 3.14
      uses: actions/setup-python@v7
      with:
        python-version: \"3.14\"

    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        if [ -f app/requirements.txt ]; then pip install -r app/requirements.txt; fi

    - name: Test with testing script
      run: python3 .github/scripts/execute_tests.py
",
            block: true,
            lang: "yaml",
          )],
      )
    ],
    [
      + Checkout and python installation using external actions
    ],
  )
  #place(dy: -27.5em, dx: 1em)[
    #rect(stroke: 2pt + red, width: 57%, height: 35%)
  ]
]

#slide("Running Tests with GitHub Actions (3/4)", 2)[

  #show grid: set text(size: 1.7em)
  #grid(
    columns: (60%, 40%),
    [
      #show figure.caption: set text(size: 0.8em)
      #figure(
        caption: "Python testing in a GitHub action example",
        text(size: 0.85em)[
          #raw(
            "steps:
    - name: Checkout repository
      uses: actions/checkout@v7

    - name: Set up Python 3.14
      uses: actions/setup-python@v7
      with:
        python-version: \"3.14\"

    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        if [ -f app/requirements.txt ]; then pip install -r app/requirements.txt; fi

    - name: Test with testing script
      run: python3 .github/scripts/execute_tests.py
",
            block: true,
            lang: "yaml",
          )],
      )
    ],
    [
      + Checkout and python installation using external actions
      + Installing pytest
    ],
  )
  #place(dy: -15em, dx: 1em)[
    #rect(stroke: 2pt + red, width: 57%, height: 30%)
  ]
]

#slide("Running Tests with GitHub Actions (4/4)", 2)[

  #show grid: set text(size: 1.7em)
  #grid(
    columns: (60%, 40%),
    [
      #show figure.caption: set text(size: 0.8em)
      #figure(
        caption: "Python testing in a GitHub action example",
        text(size: 0.85em)[
          #raw(
            "steps:
    - name: Checkout repository
      uses: actions/checkout@v7

    - name: Set up Python 3.14
      uses: actions/setup-python@v7
      with:
        python-version: \"3.14\"

    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        if [ -f app/requirements.txt ]; then pip install -r app/requirements.txt; fi

    - name: Test with testing script
      run: python3 .github/scripts/execute_tests.py
",
            block: true,
            lang: "yaml",
          )],
      )
    ],
    [
      + Checkout and python installation using external actions
      + Installing pytest
      + Running the test script
    ],
  )

  #place(dy: -5em, dx: 1em)[
    #rect(stroke: 2pt + red, width: 57%, height: 11%)
  ]
]

#slide("Exercise", 2)[
  #grid(
    columns: (70%, 30%),
    align: (x, y) => if (x == 0) {
      left + horizon
    } else {
      center + horizon
    },
    [
      #text(size: 1.7em)[
        - *Move* to the `part-2` branch by running:
          ```sh git checkout part-2```

        - *Complete* the `.github/scripts/execute_tests.py` script to
          automatically run the test and the coverage.

        - *Test* the script locally with both a valid and invalid JSON file like
          in the previous exercise to ensure it works. Use:
          ```sh python3 .github/scripts/execute_tests.py```

        - *Commit* and *push* the changes to see the tests running in your GitHub repository. Use:
          ```sh
          git add .
          git push --set-upstream origin part-2
          ```

        *Instructions and TODOs are found in the file itself as comments, while you can find these instructions and some tips on #link("sdegroup5.github.io")*
      ]
    ],
    [
      #image("/img/topic2/python.png", width: 60%)

      #underline()[
        #text(size: 1.7em)[
          This script will be used in the rest of the exercises
          for this lab, if there's any problems raise your hand.
        ]
      ]
    ],
  )
]


#slide("Solutions: exercise", 2)[
  TODO: slide about solutions of the exercise
]
