#####
## Requesting meetings
#####
"""
    validate_date(date::AbstractString)
    validate_date(date::Date)

Returns `month/day/year` string in format accepted by city 
calendar. Valid input formats are `"<M>/<D>/<YYYY>"` (`6/1/2017`, `06/01/2017`) 
or `Date(yyyy,mm,dd)` (`Date(2017,6,1)`).
"""
function validate_date(date::AbstractString)
    d_split = replace(date, "-" => "/")
    d_split = split(d_split, "/")
    length(d_split) == 3 || throw(ArgumentError("Invalid date: `$date`. Must take form mm-dd-yyyy or mm/dd/yyyy"))
    y = d_split[3]
    length(y) < 4 && throw(ArgumentError("Full 4-digit year required (`$y` invalid)"))
    y = parse(Int, y)
    m = parse(Int, d_split[1])
    d = parse(Int, d_split[2])
    return validate_date(Date(y, m, d))
end

validate_date(date::Date) = string(month(date), "/", day(date), "/", year(date))

"""
    request_meetings(start_date, stop_date)

Return list of meetings that occurred (or will occur) between `start_date` and `stop_date`.
"""
function request_meetings(start_date, stop_date)
    start = validate_date(start_date)
    stop = validate_date(stop_date)
    url = "http://somervillecityma.iqm2.com/Citizens/calendar.aspx?View=List&From=$start&To=$stop"
    @debug "Requesting $url" start stop
    r = HTTP.get(url)
    html = with_logger(NullLogger()) do
        return root(parsehtml(String(r.body)))
    end
    meeting_nodes = findall("//div[@class='RowLink']", html)
    return map(meeting_nodes) do m
        deets = split(elements(m)[1]["title"], "\r")
        name = replace(deets[3], "Board:\t" => "")
        link = joinpath("http://somervillecityma.iqm2.com", elements(m)[1]["href"][2:end])
        return (; name, date=deets[1], link)
    end
end

#####
## Parsing agendas
#####

agenda_url_prefix = "http://somervillecityma.iqm2.com/Citizens/Detail_Meeting.aspx?ID="
cache_version = "v1"

function get_agenda_items(meeting_link; cache_dir=nothing)
    isnothing(cache_dir) && return request_agenda_items(meeting_link)

    # Figure out caching info
    id = replace(meeting_link, agenda_url_prefix => "")
    cache_path = joinpath(cache_dir, "$(cache_version)_agenda_$(id).arrow")
    if isnothing(tryparse(Int, id)) 
        @warn "Unexpected agenda meeting agenda id; may yield wonky cache path!" meeting_link id cache_path
    end

    # Has it been cached before?
    if !isfile(cache_path) 
        items = request_agenda_items(meeting_link)
        Arrow.write(cache_path, items)
    end
    return DataFrame(Arrow.Table(cache_path))
end

function request_agenda_items(meeting_link)
    r = HTTP.get(meeting_link)
    html = with_logger(NullLogger()) do
        return root(parsehtml(String(r.body)))
    end

    rows = findall("//td[@class='Title']", html)
    items = map(rows) do r
        length(elements(r)) == 0 && return nothing
        return only(elements(r))
    end
    filter!(!isnothing, items)

    # Headings have `name` "strong"; main items are numbered ("number : description"). 
    # Remove items that are not headings or top-level items.
    filter!(i -> i.name == "strong" || contains(i.content, ":"), items)

    df = DataFrame(map(i -> (; name=i.name, content=i.content), items))
    if nrow(df) == 0
        @warn "Meeting has no items..." meeting_link
        return df
    end
    
    _item_number = (n, c) -> n == "strong" ? nothing : split(c, " :")[1]
    transform!(df, [:name, :content] => ByRow(_item_number) => :item)
    transform!(df, [:name] => ByRow(==("strong")) => :is_heading)
    select!(df, [:is_heading, :item, :content])
    return df
end

function filter_agenda(agenda::DataFrame, search_terms; case_invariant=true)
    nrow(agenda) == 0 && return agenda
    case_invariant && (search_terms = lowercase.(search_terms))
    @debug search_terms

    check_item = (is_heading, content) -> begin
        is_heading && return false
        case_invariant && (content = lowercase(content))
        return any(occursin(p, lowercase(content)) for p in search_terms)
    end
    return filter([:is_heading, :content] => check_item, agenda)
end

#####
## All together now
#####

function search_agendas_for_content(start_date, stop_date, search_terms; 
                                    cache_dir=nothing, case_invariant=true)
    meetings = request_meetings(start_date, stop_date)
    @info """Found agendas for $(length(meetings)) meetings between $(start_date) and $(stop_date)! 
             Searching their agendas for $(search_terms)..."""

    relevant_items = DataFrame()
    non_relevant_meetings = AbstractString[]
    parsing_failed_meetings = DataFrame()
    @showprogress for m in meetings
        try
            items = get_agenda_items(m.link; cache_dir)
            items = filter_agenda(items, search_terms; case_invariant)
            if nrow(items) == 0
                @debug "No relevant agenda items for $(m.name) [$(m.date)]"
                push!(non_relevant_meetings, m.link)
                continue
            end
            @debug """Relevant agenda items for $(m.name)!" 
                    -> $(m.date)
                    -> $(m.link)
                    $(items.content)
                   """
            insertcols!(items, :meeting => m.name, 
                               :date => m.date, 
                               :meeting_link => m.link)
            relevant_items = vcat(relevant_items, items)
        catch e
            @warn "Failed on meeting!" m.link m.name m.date e
            parsing_failed_meetings = vcat(parsing_failed_meetings, m)
        end
    end
    # Summarize
    num_rel_m = length(unique(relevant_items.meeting_link))
    failed = nrow(parsing_failed_meetings) == 0 ? "" : "-> $(nrow(parsing_failed_meetings)) meetings that failed parsing (may be relevant)"
    @info """For the $(length(meetings)) meetings between $(start_date) and $(stop_date):
            -> $(num_rel_m) meetings with a total of $(nrow(relevant_items)) relevant items
            -> $(length(non_relevant_meetings)) meetings with no relevant items
            $failed
          """
    return (; items=relevant_items, all_meetings=meetings, failed=parsing_failed_meetings)
end

function display_items_by_meeting(items::DataFrame)
    gdf = groupby(items, :meeting_link)
    for g in gdf
        meeting = only(unique(g.meeting))
        date = only(unique(g.date))
        link = only(unique(g.meeting_link))
        println(" * $date - $meeting: $link")
        for item in g.content
            println("   -> ", item)
        end
        print("\n")
    end
    return nothing
end
