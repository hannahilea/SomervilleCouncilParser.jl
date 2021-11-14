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
    length(d_split) == 3 ||
        throw(ArgumentError("Invalid date: `$date`. Must take form mm-dd-yyyy or mm/dd/yyyy"))
    y = d_split[3]
    length(y) < 4 && throw(ArgumentError("Full 4-digit year required (`$y` invalid)"))
    y = parse(Int, y)
    m = parse(Int, d_split[1])
    d = parse(Int, d_split[2])
    return validate_date(Date(y, m, d))
end

validate_date(date::Date) = string(month(date), "/", day(date), "/", year(date))

agenda_dateformat = dateformat"E, U d, YYYY  H:MM p"

const meeting_version = 1
const meeting_schema = Legolas.Schema("meeting", meeting_version)
const Meeting = Legolas.@row("meeting@1", name::AbstractString, date::DateTime, id::Int,
                             link::AbstractString)

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
    return DataFrame(map(meeting_nodes) do m
                         deets = split(elements(m)[1]["title"], "\r")
                         name = replace(deets[3], "Board:\t" => "")
                         link = joinpath("http://somervillecityma.iqm2.com",
                                         elements(m)[1]["href"][2:end])
                         date = DateTime(deets[1], agenda_dateformat)
                         id = parse(Int, split(link, "ID=")[2])
                         return Meeting(; name, date, id, link)
                     end)
end
