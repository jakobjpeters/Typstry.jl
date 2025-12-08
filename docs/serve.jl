using LiveServer: servedocs

servedocs(;
    include_dirs = ["src"], launch_browser = true, skip_dir = joinpath("docs", "src", "assets"
)
