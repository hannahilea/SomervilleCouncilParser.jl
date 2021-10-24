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

### Example: Searching agenda items
For example, say you want to know what meetings occurred in the month of September, 2021: 
```julia
julia> using Pkg
julia> Pkg.add(url="https://github.com/hannahilea/SomervilleCouncilParser.jl")
julia> using SomervilleCouncilParser

julia> meetings = request_meetings("9/1/2021", "9/30/2021")
13×3 DataFrame
 Row │ name                               date                 link                              
     │ String                             DateTime…            String                            
─────┼───────────────────────────────────────────────────────────────────────────────────────────
   1 │ Land Use Committee                 2021-09-01T18:00:00  http://somervillecityma.iqm2.com…
   2 │ City Council                       2021-09-09T19:00:00  http://somervillecityma.iqm2.com…
  ⋮  │                 ⋮                           ⋮                           ⋮
  13 │ Legislative Matters Committee      2021-09-30T18:00:00  http://somervillecityma.iqm2.com…
                                                                                  10 rows omitted

julia> length(meetings.name) # How many meetings were there?
julia> unique(meetings.name) # Which committees met?
10-element Vector{String}:
 "Land Use Committee"
 "City Council"
 "School Committee"
 "Traffic and Parking Committee"
 "Finance Committee"
 "Licenses and Permits Committee"
 "Public Utilities and Public Works Committee"
 "Confirmation of Appointments and Personnel Matters Committee"
 "Housing and Community Development Committee"
 "Legislative Matters Committee"
```

If you want to know which meeting agendas mentioned Somerville's own [Fluff Fest](https://www.flufffestival.com/): 
```julia
julia> results = search_agendas_for_content("9/1/2021", "9/30/2021", ["fluff"]);
┌ Info: Found agendas for 13 meetings between 9/1/2021 and 9/30/2021! 
└ Searching their agendas for ["fluff"]...
Progress: 100%|██████████████████████████████████████████████████| Time: 0:00:04
┌ Info: For the 13 meetings between 9/1/2021 and 9/30/2021:
│   -> 1 meeting(s) with a total of 1 relevant item(s)
└   -> 12 meeting(s) with no relevant items
```

Now you know which meeting minutes to read!
```julia
julia> display_items_by_meeting(results.items)
 * 2021-09-09T19:00:00 - City Council: http://somervillecityma.iqm2.com/Citizens/Detail_Meeting.aspx?ID=3404
   -> 212344 : Public Event License, Union Square Main Streets What the Fluff?, Union Sq Plaza, Sept 22, 23, 24, 25, 26, 8AM-11PM.
```
(If you follow the link to the agenda, and click on item 212344, you can see that the Council voted unanimously to approve the festival. Phew!)

For more examples, see the [documentation](https://hannahilea.github.io/SomervilleCouncilParser.jl/stable/examples.html).

## Getting started
For installation instructions and additional examples, read [the documentation]([documentation](https://hannahilea.github.io/SomervilleCouncilParser.jl/stable): 
    - [Beginner's guide to getting started](https://hannahilea.github.io/SomervilleCouncilParser.jl/stable/new_users.html)
    - [Examples](https://hannahilea.github.io/SomervilleCouncilParser.jl/stable/examples.html)
    - [API documentation](https://hannahilea.github.io/SomervilleCouncilParser.jl/stable/api.html)

## Feature requests, bugs, and query assistance
Do you have an idea for a new feature? Have you found a bug? Do you need help formatting (or even running) a query? Please [file an issue](https://github.com/hannahilea/SomervilleCouncilParser.jl/issues/new/choose) or open a pull request!
