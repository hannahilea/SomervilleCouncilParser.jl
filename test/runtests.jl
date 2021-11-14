using Test
using SomervilleCouncilParser
using SomervilleCouncilParser: validate_date, request_agenda_items, agenda_version
using DataFrames, Dates
using Legolas

const TEST_ASSETS = joinpath(pkgdir(SomervilleCouncilParser), "test", "assets")

include("agendas.jl")

# If any of the following examples needs adjusting, be sure to update the
# README.md examples! Should probably be handled automatically by,
# e.g., doctests---but until then, this'll have to suffice.
@testset "Project README.md" begin
    meetings = request_meetings("9/1/2021", "9/30/2021")
    @test nrow(meetings) == 13
    @test length(names(meetings)) == 4
    @test length(unique(meetings.name)) == 10

    results = search_agendas_for_content("9/1/2021", "9/30/2021", ["fluff"])
    @test nrow(results.meetings) == 13
    @test length(names(results.meetings)) == 7
    @test nrow(results.items) == 1
    @test isnothing(display_items_by_meeting(results.items))
end
