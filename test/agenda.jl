@testset "`request_agenda_items`" begin
    meeting_link = "http://somervillecityma.iqm2.com/Citizens/Detail_Meeting.aspx?ID=3163"
    items = SomervilleCouncilParser.request_agenda_items(meeting_link)
    @test nrow(items) == 4

    @test count(items.is_heading) == 3
    @test names(items) == ["item", "content", "is_heading"]

    @test request_agenda_items(meeting_link) == request_agenda_items(3163)
    @test request_agenda_items("3163") == request_agenda_items(3163)

    # support additional special cases
    meeting_link2 = "http://somervillecityma.iqm2.com/Citizens/Detail_Meeting.aspx?ID=3421"
    items = SomervilleCouncilParser.request_agenda_items(meeting_link2)
    @test nrow(items) == 0
end

@testset "`get_agenda_items`" begin
    meeting_link = "http://somervillecityma.iqm2.com/Citizens/Detail_Meeting.aspx?ID=3163"

    @test get_agenda_items(meeting_link) == get_agenda_items(3163)
    @test get_agenda_items("3163") == get_agenda_items(3163)

    # Test caching
    cache_dir = mktempdir()
    @test length(readdir(cache_dir)) == 0
    items = get_agenda_items(meeting_link; cache_dir=nothing)
    @test length(readdir(cache_dir)) == 0
    items = get_agenda_items(meeting_link; cache_dir)
    @test length(readdir(cache_dir)) == 1

    # Test that current caching hasn't changed
    # If this test _fails_, need to (a) bump `agenda_version` and (b) resave current
    # version of cached asset:
    # get_agenda_items(meeting_link; cache_dir=TEST_ASSETS) # Uncomment to save new version
    test_agenda_path = SomervilleCouncilParser.agenda_cache_path(TEST_ASSETS, 3163)
    @test isfile(test_agenda_path)
    previous_items = DataFrame(Legolas.read(test_agenda_path))
    @test previous_items == items

    # When cached item exists, load it!
    # ...to test, override table saved at cache path and make sure _that's_ what loads
    junk = DataFrame([Agenda(; item=3, content="foo")])
    p = only(readdir(joinpath(cache_dir, "v$(agenda_version)"); join=true))
    Legolas.write(p, junk, Legolas.Schema("agenda@1"))
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
    @test isnothing(display_items_by_meeting(x.items))
end
