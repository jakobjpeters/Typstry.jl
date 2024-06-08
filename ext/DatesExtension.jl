
module DatesExtension

import Typstry: show_typst
using Dates: Date, Time, DateTime
using Typstry: _show_typst, code_mode, enclose, join_with

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

# Strings

show_typst(io, x::Date) = show_date_time(io, x, year, month, day)
show_typst(io, x::Time) = show_date_time(io, x, hour, minute, second)
show_typst(io, x::DateTime) = show_date_time(io, x, year, month, day, hour, minute, second)

end # module
