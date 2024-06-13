
module DatesExtension

import Typstry: show_typst
using Dates:
    Date, DateTime, Day, Hour, Minute, Second, Time, Week,
    day, hour, minute, month, second, year
using PrecompileTools: @compile_workload
using Typstry: TypstString, TypstText, code, code_mode, depth, indent, print_parameters, workload

# Internals

date_time(::Date) = year, month, day
date_time(::Time) = hour, minute, second
date_time(::DateTime) = year, month, day, hour, minute, second

duration(::Day) = :days
duration(::Hour) = :hours
duration(::Minute) = :minutes
duration(::Second) = :seconds
duration(::Week) = :weeks

function dates(x::Union{Date, DateTime, Time})
    fs = date_time(x)
    "datetime", map(Symbol, fs), map(f -> f(x), fs)
end
function dates(x::Union{Day, Hour, Minute, Second, Week})
    buffer = IOBuffer()

    print(buffer, x)
    seekstart(buffer)

    "duration", (duration(x),), (TypstText(readuntil(buffer, " ")),)
end

# Strings

"""
    show_typst(io, ::Union{
        Date, DateTime, Day, Hour, Minute, Second, Time, Week
    })

Print in Typst format for Dates.jl.

| Type       | Settings           | Parameters |
|:-----------|:-------------------|:-----------|
| `Date`     | `:mode`, `:indent` |            |
| `DateTime` | `:mode`, `:indent` |            |
| `Day`      | `:mode`, `:indent` |            |
| `Hour`     | `:mode`, `:indent` |            |
| `Minute`   | `:mode`, `:indent` |            |
| `Second`   | `:mode`, `:indent` |            |
| `Time`     | `:mode`, `:indent` |            |
| `Week`     | `:mode`, `:indent` |            |
"""
function show_typst(io, x::Union{
    Date, DateTime, Day, Hour, Minute, Second, Time, Week
})
    f, keys, values = dates(x)
    _values = map(value -> TypstString(value; mode = code), values)

    code_mode(io)
    print_parameters(IOContext(io, map(Pair, keys, _values)...), f, keys, false)
    print(io, indent(io) ^ depth(io), ")")
end

# Internals

const examples = [
    Date(1) => Date,
    DateTime(1) => DateTime,
    Day(1) => Day,
    Hour(1) => Hour,
    Minute(1) => Minute,
    Second(1) => Second,
    Time(0) => Time,
    Week(1) => Week
]

@compile_workload workload(examples)

end # module
