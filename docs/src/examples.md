# Examples
Examples of how to make some basic queries!

### Installation
SomervilleCouncilParser.jl is a Julia package.  To install it, from your Julia REPL do
```julia
using Pkg
Pkg.add(url="https://github.com/hannahilea/SomervilleCouncilParser.jl")
```
If you aren't sure what a REPL is, and/or you're entirely new to Julia, first read the page on [Getting started from the very basics](@ref)!

### Find meetings from a particular date range
```@example 1
using SomervilleCouncilParser
meetings = request_meetings("10/1/2021", "10/31/2021")
```
Because this function (like many) returns a `DataFrame`, you can use any of the `DataFrame` operations to act on it:
- Filtering for a certain meeting type
    ```@example 1
    full_council_meetings = filter(:name => ==("City Council"), meetings)
    ```
- Sorting by date (most to least recent):
    ```@example 1
    sort(meetings, [:date]; rev=true)
    ```
- Find all dates that held more than one meeting
    ```@example 1
    using Dates
    using DataFrames
    transform!(meetings, :date => ByRow(Date) => :day)
    gdf = filter(g -> nrow(g) > 1, groupby(meetings, :day))
    combine(gdf, nrow => :num_meetings)
    ```

To learn more about working with `DataFrame`s, see [the official DataFrames.jl docs](https://dataframes.juliadata.org/stable/) or [this handy blog post](https://bkamins.github.io/julialang/2020/12/24/minilanguage.html).

### Get the agenda items from a single meeting
If you want to see the list of agenda items from one of those meetings, you can request it by meeting id (as listed in the above `meetings` table)
```@example 1
agenda = get_agenda_items(3427)
```
or from the full meeting link (which can be gotten from either the `meetings` table or when browsing the Council website directly)
```@example 1
agenda = get_agenda_items("http://somervillecityma.iqm2.com/Citizens/Detail_Meeting.aspx?ID=3427")
```
or from a link directly from the table
```@example 1
example_meeting = last(meetings)
agenda = get_agenda_items(example_meeting.link)
```

### Search the agenda items from a single meeting
Look for all agenda items containing either "hawk" or "crosswalk":
```@example 1
agenda = get_agenda_items(3427)
items = filter_agenda(agenda, ["crosswalk", "hawk"])
```
We can see that the results that contain "hawk" actually contain "HAWK", the crosswalk signal, rather than the bird. To search in a case-sensitive manor, instead do
```@example 1
items = filter_agenda(agenda, ["hawk"]; case_invariant=false)
```
...which is empty, because they didn't discuss the birds after all. A shame!
```

Of course, you could also handle agenda content searching yourself, by filtering on the `content` field from the agenda items.

### Searching multiple agendas (and caching results)

If you're planning to search many agendas (e.g., several weeks or months or especially years worth of agendas), it is STRONGLY recommended to cache your results, so that if you search for different terms in the same range, the local cached pages can be searched rather than rerequesting the pages from the website. To do this, create a local directory and pass it in as the `cache_dir` argument. You can then use this same cache directory across multiple searches on multiple days, with multiple REPL sessions.
```@example 1
cache_directory = "~/Downloads/SomervilleCouncilCache"
cache_directory = mktempdir() #hide
mkpath(cache_directory)

x = search_agendas_for_content("9/1/2021", "10/1/2021", ["dpw"]; cache_dir=cache_directory)
```

If you rerun the same search, it should take much less time (as it no longer has to download those agendas):
```@example 1
results = search_agendas_for_content("9/1/2021", "10/1/2021", ["dpw"]; cache_dir=cache_directory)
```
How many meetings and items did this include?
```
print(nrow(results.meetings), " meetings")
print(nrow(results.items), " relevant items")
```

To view the content of these items, you can then do
```@example 1
display_items_by_meeting(results.items)
```