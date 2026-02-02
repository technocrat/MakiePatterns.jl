using Documenter
using MakiePatterns

makedocs(;
    sitename="MakiePatterns.jl",
    authors="Richard Careaga <public@careaga.net>",
    modules=[MakiePatterns],
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://technocrat.github.io/MakiePatterns.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "API Reference" => "api.md",
        "Examples" => "examples.md",
    ],
    repo="https://github.com/technocrat/MakiePatterns.jl",
    checkdocs=:exports,  # Only check exported functions
)

deploydocs(;
    repo="github.com/technocrat/MakiePatterns.jl",
    devbranch="main",
)
