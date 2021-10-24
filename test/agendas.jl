
@testset "`validate_date`" begin
    @test validate_date("6/1/2017") == "6/1/2017"
    @test validate_date("06/01/2017") == "6/1/2017"
    @test validate_date("6-1-2017") == "6/1/2017" # i guess we'll handle dashes
    @test validate_date(Date(2017, 6, 1)) == "6/1/2017"
    
    @test_throws ArgumentError validate_date("5/32/2017") # invalid date rounds to next month
    @test_throws ArgumentError validate_date("6/1/17") # full year required
    @test_throws ArgumentError validate_date("June 1 2017") # no spelled-out parsing handled
    @test_throws ArgumentError validate_date("1 June 2017") # no spelled-out parsing handled
end

@testset "`request_meetings`" begin
    meetings = request_meetings("6/1/2020", "6/1/2020")
    @test nrow(meetings) == 2
    m = first(meetings)
    @test m.name == "Public Health and Public Safety Committee"
    @test m.date == DateTime("2020-06-01T18:00:00")
    @test isa(m.date, DateTime)
    @test m.link == "http://somervillecityma.iqm2.com/Citizens/Detail_Meeting.aspx?ID=3163"
end

#####
## Agendas
#####

@testset "`request_agenda_items`" begin
    meeting_link = "http://somervillecityma.iqm2.com/Citizens/Detail_Meeting.aspx?ID=3163"
    items = SomervilleCouncilParser.request_agenda_items(meeting_link)
    @test nrow(items) == 4

    @test count(items.is_heading) == 3
    @test names(items) == ["is_heading", "item", "content"]

    # support additional special cases
    meeting_link2 = "http://somervillecityma.iqm2.com/Citizens/Detail_Meeting.aspx?ID=3421"
    items = SomervilleCouncilParser.request_agenda_items(meeting_link2)
    @test nrow(items) == 0
end

@testset "`get_agenda_items`" begin
    meeting_link = "http://somervillecityma.iqm2.com/Citizens/Detail_Meeting.aspx?ID=3163"

    # Test caching
    cache_dir = mktempdir()
    @test length(readdir(cache_dir)) == 0
    items = get_agenda_items(meeting_link; cache_dir=nothing)
    @test length(readdir(cache_dir)) == 0
    items = get_agenda_items(meeting_link; cache_dir)
    @test length(readdir(cache_dir)) == 1
    
    # When cached item exists, load that
    # ...to test, override table saved at cache path
    junk = DataFrame(a=[1, 2, 3], b=[:a, :b, :c])
    p = only(readdir(cache_dir; join=true))
    Arrow.write(p, junk)
    cached_items = get_agenda_items(meeting_link; cache_dir)
    @test cached_items == junk
end

@testset "`agenda_contains`" begin
    meeting_link = "http://somervillecityma.iqm2.com/Citizens/Detail_Meeting.aspx?ID=3163"
    agenda = get_agenda_items(meeting_link)
    @test nrow(filter_agenda(agenda, ["Director", "hawk"])) == 1

    @test isempty(filter_agenda(agenda, ["hawk"]))

    @test isempty(filter_agenda(agenda, ["dIrEcToR"]; case_invariant=false))
    @test nrow(filter_agenda(agenda, ["dIrEcToR"]; case_invariant=true)) == 1
end

@testset "`search_agendas_for_content`" begin
    cache_dir = mktempdir()
    x = search_agendas_for_content("9/1/2021", "10/1/2021", ["dpw"]; cache_dir)
    @test nrow(x.items) == 4
    @test nrow(x.meetings) == 13 
    @test all(isnothing.(x.meetings.failed_parsing))
end
