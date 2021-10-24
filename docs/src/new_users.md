# Getting started from the very basics
So you want to give this tool a try, but you're totally lost on how to get started? This section is for you! (If you're still confused after reading this, please [file an issue for what tripped you up](https://github.com/hannahilea/SomervilleCouncilParser.jl/issues/new/choose) so we can clarify further. :) )

## Setting up Julia
First things first: this project is written in a programming language called Julia. To use it, you'll need to install Julia!

1. Download the installer for your particular computer (if in doubt, you likely need "64-bit" or "64-bit (installer)"): [Installers](https://julialang.org/downloads/#current_stable_release)

2. Run the installer! It will prompt you on where to install the program; the basic settings are sufficient, no need to do anything fancy.

3. Optional: Want to run Julia from the command prompt/terminal? (If you don't know what this means, that's fine---you likely don't need this option!) If so, instructions for adding it to your PATH here: [mac](https://julialang.org/downloads/platform/#optional_add_julia_to_path) and [windows](https://julialang.org/downloads/platform/#adding_julia_to_path_on_windows_10)

Find and run the installed Julia program the same way you'd find any other program installed on your computer---possibly by double-clicking on its desktop icon, or by finding it in the Applications list, depending on what type of computer you have. 
    - If you've added it to your PATH, above, you can run in from the command line by typing `julia`.

When Julia launches, it will open a text prompt window called a REPL ("read-eval-print-loop"). Type
```julia
"hello world"
```
into the prompt and then hit `enter`. Congrats, you're using Julia!

## Setting up SomervilleCouncilParser.jl
Next, let's install this project! In the REPL, type (or copy and paste) and then hit enter:
```julia
using Pkg
Pkg.add(url="https://github.com/hannahilea/SomervilleCouncilParser.jl")
using SomervilleCouncilParser
```

You should now be able to run any of the examples from the [examples](../src/examples.md) section, by typing (or copying) them directly into the REPL. For example, to list all meetings that occurred on June 1, 2020, do
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

To leave the Julia program when you're done, type `exit()`, or close the REPL window.

That's it!

## Other notes
- If you type a long query (say, you accidentally search for 10 years' worth of meetings instead of a single year!) and want to cancel the command in progress, do `ctrl+c` to cancel it.

- If you encounter Julia code snippets that use an external project (i.e., code that lives outside of this project), they will look like this:
    ```
    using SomeFunExternalDependency
    ```
    (for a depencency that is named `SomeFunExternalDependency`). 
    
    Before you run this `using ...` command, you'll have to install the package from within Julia. To do this, type
    ```julia
    using Pkg
    Pkg.add("SomeFunExternalDependency")
    ```
    and then you can use it:

    ```julia
    using SomeFunExternalDependency
    ```

    Don't worry about forgetting to install dependencies---if you do, Julia will show you an error with prompt for what to do:
    ```julia
    julia> using SomeFunPackageYouForgotToInstallFirst
    ERROR: ArgumentError: Package SomeFunPackageYouForgotToInstallFirst not found in current path:
    - Run `import Pkg; Pkg.add("SomeFunPackageYouForgotToInstallFirst")` to install the SomeFunPackageYouForgotToInstallFirst package.
    ```
- When running in Terminal.app (default on macOS), use CMD + double click to open any link in a browser.
