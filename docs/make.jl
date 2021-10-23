using Documenter, SomervilleCouncilParser

DocMeta.setdocmeta!(SomervilleCouncilParser, :DocTestSetup, :(using SomervilleCouncilParser);
                    recursive=true)

makedocs(; format=Documenter.HTML(; prettyurls=true),
         modules=[SomervilleCouncilParser], sitename="SomervilleCouncilParser.jl",
         pages=["Home" => "index.md", "Examples" => "examples.md",
                "API reference" => "api.md"], strict=true)

deploydocs(; repo="github.com/hannahilea/SomervilleCouncilParser.jl.git",
           push_preview=true, devbranch="main")