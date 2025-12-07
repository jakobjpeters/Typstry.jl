
# build documentation
document:
    julia --project=docs docs/make.jl

# generate logo
# logo:
#     julia docs/logo.jl

# run tests
test:
    julia --project=test test/runtests.jl
