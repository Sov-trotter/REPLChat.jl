using REPLChat
using Documenter

DocMeta.setdocmeta!(REPLChat, :DocTestSetup, :(using REPLChat); recursive=true)

makedocs(;
    modules=[REPLChat],
    authors="Arsh Sharma",
    repo="https://github.com/Sov-trotter/REPLChat.jl/blob/{commit}{path}#{line}",
    sitename="REPLChat.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://Sov-trotter.github.io/REPLChat.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/Sov-trotter/REPLChat.jl",
    devbranch="main",
)
