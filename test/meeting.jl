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
    r = Meeting(m) # Just test that this is possible
    @test m.name == "Public Health and Public Safety Committee"
    @test m.date == DateTime("2020-06-01T18:00:00")
    @test isa(m.date, DateTime)
    @test isa(m.id, Int)
    @test m.link == "http://somervillecityma.iqm2.com/Citizens/Detail_Meeting.aspx?ID=3163"

    # Test that current meeting serialization hasn't changed
    # If this test _fails_, need to (a) bump `meeting_version` and (b) resave current
    # version of cached meeting asset:
    test_meeting_path = joinpath(TEST_ASSETS, "v$(SomervilleCouncilParser.meeting_version)", "meeting.arrow")
    # Legolas.write(test_meeting_path, DataFrame(m), SomervilleCouncilParser.meeting_schema)  # Uncomment to save new version
    @test isfile(test_meeting_path)
    previous_mtg = DataFrame(Legolas.read(test_meeting_path))
    @test previous_mtg == DataFrame(m)
end
