
module Run

using ..Commands: TypstCommand, julia_mono

export @run

"""
    (@run parameters...)::Nothing

Construct and `run` a [`TypstCommand`](@ref).

Each parameter is evaluated and converted to a `string`.
This is intended for convenience and interactive use.
The command is ran with `ignorestatus` and will gracefully catch interrupts,
which is useful for `typst watch`.
If the `TYPST_FONT_PATHS` environment variable is not set,
the command is ran with it set to [`julia_mono`](@ref).

# Examples

```julia
julia> command = :help

julia> @run

julia> @run :help

julia> @run command "he" * "lp"
```
"""
macro run(parameters...)
    quote
        try
            run(addenv(
                ignorestatus(TypstCommand(collect(string.(($(esc.(parameters)...),))))),
                "TYPST_FONT_PATHS" => get(ENV, "TYPST_FONT_PATHS", julia_mono)
            ))
        catch exception exception isa InterruptException || rethrow()
        end

        nothing
    end
end

end # Run
