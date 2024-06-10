
module DatesExtension

import Typstry: show_typst
using Dates: Date, Time, DateTime, day, hour, minute, month, second, year
using PrecompileTools: PrecompileTools, @compile_workload
using Typstry: _show_typst, code_mode, enclose, join_with, workload

# Internals

function show_date_time(io, x, fs...)
    code_mode(io)
    enclose((io, x; fs) -> begin
        join_with((io, f; x) -> begin
            print(io, f, ": ")
            _show_typst(io, f(x))
        end, io, fs, ", "; x)
    end, io, x, "datetime(", ")"; fs)
end

show_dates(io, x::Date) = show_date_time(io, x, year, month, day)
show_dates(io, x::Time) = show_date_time(io, x, hour, minute, second)
show_dates(io, x::DateTime) = show_date_time(io, x, year, month, day, hour, minute, second)

# Strings

"""
    show_typst(io, ::Union{Date, Time, DateTime})

Print in Typst format for Dates.jl.

| Type       | Settings | Parameters |
|:-----------|:---------|:-----------|
| `Date`     | `:mode`  |            |
| `Time`     | `:mode`  |            |
| `DateTime` | `:mode`  |            |
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
