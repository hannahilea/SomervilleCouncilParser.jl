# SomervilleCouncilParser.jl

[![CI](https://github.com/hannahilea/SomervilleCouncilParser.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/hannahilea/SomervilleCouncilParser.jl/actions/workflows/CI.yml)
[![codecov](https://codecov.io/gh/hannahilea/SomervilleCouncilParser.jl/branch/main/graph/badge.svg?token=MKEJ2K1ONT)](https://codecov.io/gh/hannahilea/SomervilleCouncilParser.jl)
[![Docs: stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://hannahilea.github.io/SomervilleCouncilParser.jl/stable)
[![Docs: development](https://img.shields.io/badge/docs-dev-blue.svg)](https://hannahilea.github.io/SomervilleCouncilParser.jl/dev)

Search the meeting artifacts (agendas, minutes) of the City Council of Somerville, MA.

**Contents:**

- [Motivation](#motivation)
- [Getting started](#getting-started)
- [Feature requests, bugs, query assistance](#feature-requests-bugs-and-query-assistance)

## Motivation
While the Somerville, MA, City Council agendas and minutes are [posted publicly](http://somervillecityma.iqm2.com/Citizens/calendar.aspx), it can be difficult to search through them---the [built-in site search](http://somervillecityma.iqm2.com/Citizens/Search.aspx#SearchText=) is good for one-off queries, but not really for larger data investigation tasks. SomervilleCouncilParser.jl allows you to search those artifacts in a way that facilitates downstream munging. 

For example, say you want to know what meetings occurred in the month of September, 2021: 
```julia
julia> using Pkg
julia> Pkg.add(url="https://github.com/hannahilea/SomervilleCouncilParser.jl")
julia> using SomervilleCouncilParser

julia> meetings = request_meetings("9/1/2021", "9/30/2021")
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
