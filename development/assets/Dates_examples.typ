#import "template.typ": f, template

#show: document => template(document)

= Dates.jl

#f((
    "Date(1)", "Date", "datetime(\n  year: 1,\n  month: 1,\n  day: 1\n)", [#datetime(
      year: 1,
      month: 1,
      day: 1
    )], "#datetime(\n  year: 1,\n  month: 1,\n  day: 1\n)", [#datetime(
      year: 1,
      month: 1,
      day: 1
    )], "#datetime(\n  year: 1,\n  month: 1,\n  day: 1\n)", [$#datetime(
      year: 1,
      month: 1,
      day: 1
    )$],
    "DateTime(1)", "DateTime", "datetime(\n  year: 1,\n  month: 1,\n  day: 1,\n  hour: 0,\n  minute: 0,\n  second: 0\n)", [#datetime(
      year: 1,
      month: 1,
      day: 1,
      hour: 0,
      minute: 0,
      second: 0
    )], "#datetime(\n  year: 1,\n  month: 1,\n  day: 1,\n  hour: 0,\n  minute: 0,\n  second: 0\n)", [#datetime(
      year: 1,
      month: 1,
      day: 1,
      hour: 0,
      minute: 0,
      second: 0
    )], "#datetime(\n  year: 1,\n  month: 1,\n  day: 1,\n  hour: 0,\n  minute: 0,\n  second: 0\n)", [$#datetime(
      year: 1,
      month: 1,
      day: 1,
      hour: 0,
      minute: 0,
      second: 0
    )$],
    "Day(1)", "Day", "duration(\n  days: 1\n)", [#duration(
      days: 1
    )], "#duration(\n  days: 1\n)", [#duration(
      days: 1
    )], "#duration(\n  days: 1\n)", [$#duration(
      days: 1
    )$],
    "Hour(1)", "Hour", "duration(\n  hours: 1\n)", [#duration(
      hours: 1
    )], "#duration(\n  hours: 1\n)", [#duration(
      hours: 1
    )], "#duration(\n  hours: 1\n)", [$#duration(
      hours: 1
    )$],
    "Minute(1)", "Minute", "duration(\n  minutes: 1\n)", [#duration(
      minutes: 1
    )], "#duration(\n  minutes: 1\n)", [#duration(
      minutes: 1
    )], "#duration(\n  minutes: 1\n)", [$#duration(
      minutes: 1
    )$],
    "Second(1)", "Second", "duration(\n  seconds: 1\n)", [#duration(
      seconds: 1
    )], "#duration(\n  seconds: 1\n)", [#duration(
      seconds: 1
    )], "#duration(\n  seconds: 1\n)", [$#duration(
      seconds: 1
    )$],
    "Time(0)", "Time", "datetime(\n  hour: 0,\n  minute: 0,\n  second: 0\n)", [#datetime(
      hour: 0,
      minute: 0,
      second: 0
    )], "#datetime(\n  hour: 0,\n  minute: 0,\n  second: 0\n)", [#datetime(
      hour: 0,
      minute: 0,
      second: 0
    )], "#datetime(\n  hour: 0,\n  minute: 0,\n  second: 0\n)", [$#datetime(
      hour: 0,
      minute: 0,
      second: 0
    )$],
    "Week(1)", "Week", "duration(\n  weeks: 1\n)", [#duration(
      weeks: 1
    )], "#duration(\n  weeks: 1\n)", [#duration(
      weeks: 1
    )], "#duration(\n  weeks: 1\n)", [$#duration(
      weeks: 1
    )$]
))

