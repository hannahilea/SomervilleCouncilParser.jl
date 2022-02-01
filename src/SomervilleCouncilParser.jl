module SomervilleCouncilParser

using HTTP
using EzXML
using HttpCommon
using Logging
using Dates
using Legolas
using DataFrames
using ProgressMeter

const SITE_ROOT = "http://somervillecityma.iqm2.com/Citizens"

include("meeting.jl")
export request_meetings, Meeting

include("agenda.jl")
export get_agenda_items, filter_agenda, search_agendas_for_content,
       display_items_by_meeting, Agenda

end # module
