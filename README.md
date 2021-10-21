# SomervilleCouncilParser.jl

[![CI](https://github.com/hannahilea/SomervilleCouncilParser.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/hannahilea/SomervilleCouncilParser.jl/actions/workflows/CI.yml)[![codecov](https://codecov.io/gh/hannahilea/SomervilleCouncilParser.jl/branch/main/graph/badge.svg?token=tkZevnibtf)](https://codecov.io/gh/hannahilea/SomervilleCouncilParser.jl)

Search the meeting artifacts (agendas, minutes) of the City Council of Somerville, MA.

**Contents:**

- [Motivation](#motivation)
- [Feature requests, bugs, query assistance](#feature-requests-bugs-and-query-assistance)
- [Examples](#examples)
- [Getting started if you've never used Julia before (and/or aren't a programmer)](#getting-started-new-users)

## Motivation
TODO

## Feature requests, bugs, and query assistance

Do you have an idea for a cool new feature? Have you found a bug? Do you need help formatting a query? Please [file an issue](https://github.com/hannahilea/SomervilleCouncilParser.jl/issues/new/choose) or open a pull request!

## Examples

You'll need to install this package before trying any of the examples. To do that, from your Julia REPL, do
```julia
using Pkg
Pkg.add(url="https://github.com/hannahilea/SomervilleCouncilParser.jl")
using SomervilleCouncilParser
```
(If you aren't sure what that even means, and/or you're entirely new to Julia, see the following section on [getting started with the basics](#getting-started-new-users)!)

### TODO


## Getting started - new users!
So you want to give this project a try, but you're totally lost on how to get started? This section is for you! (If you're still confused after reading this section, please [let me know](https://github.com/hannahilea/SomervilleCouncilParser.jl/issues/new/choose) so we can clarify further. :) )

1. First things first: this project is written in a programming language called Julia. To use it, you'll need to install Julia. First,
    1. Download the installer for your particular computer (if in doubt, you likely need "64-bit" or "64-bit (installer)"): [Installers](https://julialang.org/downloads/#current_stable_release)
    2. Run the installer!

2. Find and run the installed Julia program the same way you'd find any other program installed on your computer---possibly by double-clicking on its desktop icon, or by finding it in the Applications list, depending on what type of computer you have. 

3. When Julia launches, it will open a text prompt window called a REPL (a "read-eval-print-loop"). Type
    ```julia
    "hello world"
    ```
    into the prompt and then hit `enter`. Congrats, you're using Julia!

4. Next, let's install this SomervilleCouncilParser project! In the REPL, type (or copy and paste) and then hit enter:
    ```julia
    using Pkg
    Pkg.add(url="https://github.com/hannahilea/SomervilleCouncilParser.jl")
    using SomervilleCouncilParser
    ```

4. Any of the examples in the above section can now be typed (or copied) directly into the REPL. For example, to list all meetings that occurred on June 1, 2020, do
    ```julia
    meetings = request_meetings("6/1/2020", "6/1/2020")
    ```
    You should see a response that looks something like
    ```julia
    2×3 DataFrame
    Row │ name                               date                 link                              
        │ String                             DateTime…            String                            
    ─────┼───────────────────────────────────────────────────────────────────────────────────────────
    1 │ Public Health and Public Safety …  2020-06-01T18:00:00  http://somervillecityma.iqm2.com…
    2 │ Finance Committee                  2020-06-01T20:00:00  http://somervillecityma.iqm2.com…
    ```

5. If you type a long query (say, you accidentally search for 10 years' worth of meetings instead of a single year!) and want to cancel the command in progress, do `ctrl+c` to cancel it.

6. If you encounter Julia code examples that use an external project (i.e., code that lives outside of this project), they will look like this:
    ```
    using SomeFunExternalDependency
    ```
    (for a depencency that is named `SomeFunExternalDependency`). Before you run this `using ...` command, you'll have to install the package from within Julia. 
    
    To do this, type
    ```julia
    using Pkg
    Pkg.add("SomeFunExternalDependency")
    ```
    and then you can use it:
    
    ```julia
    using SomeFunExternalDependency
    ```

    Don't worry if you forget to install a dependency---Julia will show you an error with prompt for what to do:
    ```julia
    julia> using SomeFunPackageYouForgotToInstallFirst
    ERROR: ArgumentError: Package SomeFunPackageYouForgotToInstallFirst not found in current path:
    - Run `import Pkg; Pkg.add("SomeFunPackageYouForgotToInstallFirst")` to install the SomeFunPackageYouForgotToInstallFirst package.
    ```

6. To leave the Julia program when you're done, type `exit()`, or close the REPL window.