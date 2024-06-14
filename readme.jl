
const delimiter = "## Introduction"

write("README.md", "\n" * join((
    "<!-- This file is generated by `.github/workflows/readme.yml`; do not edit directly. -->",
    read("HEADER.md", String),
    delimiter * replace(
        last(split(read("docs/source/index.md", String), delimiter)),
        "jldoctest" => "julia-repl"
    )
), "\n"))
