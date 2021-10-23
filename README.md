# SomervilleCouncilParser.jl

[![CI](https://github.com/hannahilea/SomervilleCouncilParser.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/hannahilea/SomervilleCouncilParser.jl/actions/workflows/CI.yml)[![codecov](https://codecov.io/gh/hannahilea/SomervilleCouncilParser.jl/branch/main/graph/badge.svg?token=MKEJ2K1ONT)](https://codecov.io/gh/hannahilea/SomervilleCouncilParser.jl)

Search the meeting artifacts (agendas, minutes) of the City Council of Somerville, MA.

**Contents:**

- [Motivation](#motivation)
- [Getting started](#getting-started)
- [Feature requests, bugs, query assistance](#feature-requests-bugs-and-query-assistance)

## Motivation
While the Somerville, MA, City Council agendas and minutes are posted publicly, it can be difficult to search through them---the built in search function is good for one-off searches, but not really built for larger data investigation tasks. This tool allows you to search those artifacts in a way that enables downstream munging. 

For example, you want to know which meetings occurred between May 1 and May 15, 2021: 
```julia
using Pkg
Pkg.add(url="https://github.com/hannahilea/SomervilleCouncilParser.jl")
using SomervilleCouncilParser

TODO
```

Of those meetings, you want to know which meetings included budget discussions: 
```julia
TODO
```

Now you know which meeting minutes to read:
```julia
TODO
```

But wait, how many times did the finance committee even meet in the last year?
```julia
TODO
```

...how many times did _any_ of the comittees meet in 2020?
```julia
TODO
```

...and how did that compare to 2019?
```julia
TODO
```

Or maybe you want to know whether any upcoming meetings will be discussing trees? (This example was generated on 22 Oct 2021; you will see different results based on when you search for yourself!)
```julia
TODO
```

## Getting started
For installation instructions and additional examples, read the documentation: 
    - [Installation](#TODO)
    - [Examples](#TODO)

## Feature requests, bugs, and query assistance
Do you have an idea for a new feature? Have you found a bug? Do you need help formatting (or even running) a query? Please [file an issue](https://github.com/hannahilea/SomervilleCouncilParser.jl/issues/new/choose) or open a pull request!
