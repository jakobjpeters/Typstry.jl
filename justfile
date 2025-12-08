
# build documentation
document:
    julia --project=docs docs/make.jl

# generate logo
# logo:
#     julia docs/logo.jl

# serve documentation
serve:
    julia --project=docs --eval "\
        using LiveServer: servedocs; \
        servedocs(; \
            include_dirs = [\"src\"], \
            launch_browser = true, \
            skip_dir = joinpath(\"docs\", \"src\", \"assets\") \
        ) \
    "

# run tests
test:
    julia --project=test test/runtests.jl
