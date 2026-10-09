using Documenter
using MaterialDocs
using MakiePatterns

makedocs(;
    sitename="MakiePatterns.jl",
    authors="Richard Careaga <public@careaga.net>",
    modules=[MakiePatterns],
    format=Material3(;
        theme=:sandstone,
        dark_mode=:toggle,
        edit_link="main",
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
