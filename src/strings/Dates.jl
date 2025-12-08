
module Dates

import ..Strings: show_typst

using Dates:
    Date, DateTime, Day, Hour, Minute, Period, Second, Time, Week,
    day, hour, minute, month, second, year
using ..Strings: Strings, TypstString, TypstText, code
using Typstry: Typstry, TypstContext

function dates(date_time::DateTime)
    fs = (year, month, day, hour, minute, second)
    :datetime, map(Symbol, fs), map(f -> f(date_time), fs)
end
dates(date::Date) = :datetime, (:year, :month, :day), (year(date), month(date), day(date))
function dates(x::Period)
    io_buffer = IOBuffer()

    print(io_buffer, x)
    seekstart(io_buffer)

    :duration, (duration(x),), (Typstry.TypstText(readuntil(io_buffer, ' ')),)
end
dates(time::Time) = :datetime, (:hour, :minute, :second), (hour(time), minute(time), second(time))

duration(::Day) = :days
duration(::Hour) = :hours
duration(::Minute) = :minutes
duration(::Second) = :seconds
duration(::Week) = :weeks

function show_typst(io::IO, tc::TypstContext, x::Union{Date, DateTime, Period, Time})
    f, keys, values = dates(x)
    _values = map(value -> TypstString(value; mode = code), values)
    show_typst(io, tc, Strings.TypstFunction(tc, TypstString(TypstText(f)); zip(keys, values)...))
end

end # Dates
