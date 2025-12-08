
# build documentation
document:
    julia --project=docs docs/make.jl

# generate logo
# logo:
#     julia docs/logo.jl

# serve documentation
serve:
    julia --project=docs docs/serve.jl

# run tests
test:
    julia --project=test test/runtests.jl
