const agenda_url_prefix = "http://somervillecityma.iqm2.com/Citizens/Detail_Meeting.aspx?ID="

const agenda_version = 2
const agenda_schema = Legolas.Schema("agenda", agenda_version)
const Agenda = Legolas.@row("agenda@2",
                            id::Union{Int,Nothing,Missing},
                            content::String,
                            type::Symbol,
                            link::Union{String,Nothing})

function agenda_cache_path(cache_dir, id)
    return joinpath(cache_dir, "v$(agenda_version)", "agenda-$(id).arrow")
end

"""
    get_agenda_items(meeting_link; cache_dir=nothing)

Return `DataFrame` of agenda items from meeting `meeting_link`. `meeting_link` can be either
the full link (`"http://somervillecityma.iqm2.com/Citizens/Detail_Meeting.aspx?ID=2570"`) or
the meeting ID (`2570`).

When `cache_dir` is not empty, agendas are read from the cache if they've been previously
downloaded. If they do not exist in the cache, they'll be added to it.
"""
function get_agenda_items(meeting_link; cache_dir=nothing)
    isnothing(cache_dir) && return request_agenda_items(meeting_link)

    # Figure out caching info
    id = replace(meeting_link, agenda_url_prefix => "")
    cache_path = agenda_cache_path(cache_dir, id)
    if isnothing(tryparse(Int, id))
        @warn "Unexpected agenda meeting agenda id; may yield wonky cache path!" meeting_link id cache_path
    end

    # Has it been cached before?
    if !isfile(cache_path)
        items = request_agenda_items(meeting_link)
        mkpath(dirname(cache_path))
        Legolas.write(cache_path, items, agenda_schema)
    end
    return DataFrame(Legolas.read(cache_path))
end

"""
    request_agenda_items(meeting_id; verbose=false)

Return `DataFrame` of agenda items from meeting `meeting_link`. `meeting_link` can be either
the full link (`"http://somervillecityma.iqm2.com/Citizens/Detail_Meeting.aspx?ID=2570"`) or
the meeting ID (`2570`).
"""
function request_agenda_items(meeting_id; verbose=false)
    return request_agenda_items(agenda_url_prefix * string(meeting_id); verbose)
end

function request_agenda_items(meeting_link::AbstractString; verbose=false)
    if !startswith(meeting_link, agenda_url_prefix)
        meeting_link = agenda_url_prefix * meeting_link
        @warn "Inserting missing agenda prefix" meeting_link
    end

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
    #TODO: keep attachments! warn about other stuff?
    filter!(i -> i.name == "strong" || contains(i.content, ":"), items)

    items = map(items) do i
        i.name == "strong" && return Agenda(; id=nothing, i.content, type=:heading, link="TODO")
        #TODO: subullet doc attachment??
        x = split(i.content, " : "; limit=2)
        id = tryparse(Int, x[1])
        content = length(x) == 2 && !isnothing(id) ? x[2] : x[1]
        link = "TODO" #TODO
        type = isnothing(id) ? :item : :attachment #TODO make sure this is the only other case....
        return Agenda(; id, content, type, link)
    end
    return DataFrame(items)
end

"""
    filter_agenda(agenda::DataFrame, search_terms; case_invariant=true)

Return copy of `agenda` filtered such that only rows containing an item from
`search_terms` in the description of the item will be preserved. When `case_invariant`
is true, ignores uppercase vs lowercase letters.
"""
function filter_agenda(agenda::DataFrame, search_terms; case_invariant=true)
    nrow(agenda) == 0 && return agenda
    case_invariant && (search_terms = lowercase.(search_terms))
    @debug search_terms

    check_item = (is_heading, content) -> begin
        is_heading && return false
        case_invariant && (content = lowercase(content))
        return any(occursin(p, content) for p in search_terms)
    end
    return filter([:is_heading, :content] => check_item, agenda)
end

#####
## All together now
#####

"""
    search_agendas_for_content(start_date, stop_date, search_terms;
                               cache_dir=nothing, case_invariant=true)

Return `NamedTuple` containing `meetings` (a `DataFrame` of meetings found within the given `start_date`-`stop_date`
range) and `items` (a `DataFrame` of all items containing at least one of the `search_terms`).
"""
function search_agendas_for_content(start_date, stop_date, search_terms; cache_dir=nothing,
                                    case_invariant=true)
    meetings = request_meetings(start_date, stop_date)
    @info """Found agendas for $(nrow(meetings)) meetings between $(start_date) and $(stop_date)!
             Searching their agendas for $(search_terms)..."""

    relevant_items = DataFrame()
    p = Progress(nrow(meetings) + 1)
    next!(p)
    _get_relevant_items = (link, date, name) -> begin
        try
            next!(p)
            total_items = 0
            items = get_agenda_items(link; cache_dir)
            total_items = nrow(items)
            items = filter_agenda(items, search_terms; case_invariant)
            nrow(items) == 0 && return (0, total_items, nothing)

            insertcols!(items, :meeting => name, :date => date, :meeting_link => link)
            relevant_items = vcat(relevant_items, items)
            return (nrow(items), total_items, nothing)
        catch e
            return (0, total_items, e)
        end

        return true
    end
    transform!(meetings,
               [:link, :date, :name] => ByRow(_get_relevant_items) => [:num_items,
                                                                       :total_items,
                                                                       :failed_parsing])

    # Summarize
    num_rel_m = nrow(relevant_items) == 0 ? 0 : length(unique(relevant_items.meeting_link))
    num_failed = nrow(meetings) - count(isnothing.(meetings.failed_parsing))
    num_irrel = nrow(meetings) - num_failed - num_rel_m
    failed = num_failed == 0 ? "" :
             "\n  -> $(num_failed) meetings that failed parsing (may be relevant)"
    @info """For the $(nrow(meetings)) meetings between $(start_date) and $(stop_date):
            -> $(length(unique(relevant_items.meeting_link))) meeting(s) with a total of $(nrow(relevant_items)) relevant item(s)
            -> $(num_irrel) meeting(s) with no relevant items$failed
          """
    return (; items=relevant_items, meetings)
end

"""
    display_items_by_meeting(items::DataFrame)

Display `items` grouped by meeting, along with the meeting's date, name, and url.
"""
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
