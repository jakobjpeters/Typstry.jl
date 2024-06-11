
module DatesExtension

import Typstry: show_typst
using Dates: Date, Time, DateTime, day, hour, minute, month, second, year
using PrecompileTools: PrecompileTools, @compile_workload
using Typstry: TypstString, code, code_mode, depth, indent, print_parameters, workload

# Internals

function show_date_time(io, x, fs...)
    parameters = map(Symbol, fs)

    code_mode(io)
    print_parameters(IOContext(io, map(Pair, parameters,
        map(f -> TypstString(f(x); mode = code), fs)
    )...), "datetime", parameters, false)
    print(io, indent(io) ^ depth(io), ")")
end

show_dates(io, x::Date) = show_date_time(io, x, year, month, day)
show_dates(io, x::Time) = show_date_time(io, x, hour, minute, second)
show_dates(io, x::DateTime) = show_date_time(io, x, year, month, day, hour, minute, second)

# Strings

"""
    show_typst(io, ::Union{Date, Time, DateTime})

Print in Typst format for Dates.jl.

| Type       | Settings           | Parameters |
|:-----------|:-------------------|:-----------|
| `Date`     | `:mode`, `:indent` |            |
| `Time`     | `:mode`, `:indent` |            |
| `DateTime` | `:mode`, `:indent` |            |
"""
show_typst(io, x::Union{Date, Time, DateTime}) = show_dates(io, x)

# Internals

const examples = [
    Date(1) => Date,
    DateTime(1) => DateTime,
    Time(0) => Time
]

@compile_workload workload(examples)

end # module
