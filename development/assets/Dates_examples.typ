#import "template.typ": f, template

#show: document => template(document)

= Dates.jl

#f((
    "Date(1)", `Date`, ````typc datetime(
      year: 1,
      month: 1,
      day: 1
    ) ````, [#datetime(
      year: 1,
      month: 1,
      day: 1
    )], ````typ #datetime(
      year: 1,
      month: 1,
      day: 1
    ) ````, [#datetime(
      year: 1,
      month: 1,
      day: 1
    )], ````typc #datetime(
      year: 1,
      month: 1,
      day: 1
    ) ````, [$#datetime(
      year: 1,
      month: 1,
      day: 1
    )$],
    "DateTime(1)", `DateTime`, ````typc datetime(
      year: 1,
      month: 1,
      day: 1,
      hour: 0,
      minute: 0,
      second: 0
    ) ````, [#datetime(
      year: 1,
      month: 1,
      day: 1,
      hour: 0,
      minute: 0,
      second: 0
    )], ````typ #datetime(
      year: 1,
      month: 1,
      day: 1,
      hour: 0,
      minute: 0,
      second: 0
    ) ````, [#datetime(
      year: 1,
      month: 1,
      day: 1,
      hour: 0,
      minute: 0,
      second: 0
    )], ````typc #datetime(
      year: 1,
      month: 1,
      day: 1,
      hour: 0,
      minute: 0,
      second: 0
    ) ````, [$#datetime(
      year: 1,
      month: 1,
      day: 1,
      hour: 0,
      minute: 0,
      second: 0
    )$],
    "Day(1)", `Day`, ````typc duration(
      days: 1
    ) ````, [#duration(
      days: 1
    )], ````typ #duration(
      days: 1
    ) ````, [#duration(
      days: 1
    )], ````typc #duration(
      days: 1
    ) ````, [$#duration(
      days: 1
    )$],
    "Hour(1)", `Hour`, ````typc duration(
      hours: 1
    ) ````, [#duration(
      hours: 1
    )], ````typ #duration(
      hours: 1
    ) ````, [#duration(
      hours: 1
    )], ````typc #duration(
      hours: 1
    ) ````, [$#duration(
      hours: 1
    )$],
    "Minute(1)", `Minute`, ````typc duration(
      minutes: 1
    ) ````, [#duration(
      minutes: 1
    )], ````typ #duration(
      minutes: 1
    ) ````, [#duration(
      minutes: 1
    )], ````typc #duration(
      minutes: 1
    ) ````, [$#duration(
      minutes: 1
    )$],
    "Second(1)", `Second`, ````typc duration(
      seconds: 1
    ) ````, [#duration(
      seconds: 1
    )], ````typ #duration(
      seconds: 1
    ) ````, [#duration(
      seconds: 1
    )], ````typc #duration(
      seconds: 1
    ) ````, [$#duration(
      seconds: 1
    )$],
    "Time(0)", `Time`, ````typc datetime(
      hour: 0,
      minute: 0,
      second: 0
    ) ````, [#datetime(
      hour: 0,
      minute: 0,
      second: 0
    )], ````typ #datetime(
      hour: 0,
      minute: 0,
      second: 0
    ) ````, [#datetime(
      hour: 0,
      minute: 0,
      second: 0
    )], ````typc #datetime(
      hour: 0,
      minute: 0,
      second: 0
    ) ````, [$#datetime(
      hour: 0,
      minute: 0,
      second: 0
    )$],
    "Week(1)", `Week`, ````typc duration(
      weeks: 1
    ) ````, [#duration(
      weeks: 1
    )], ````typ #duration(
      weeks: 1
    ) ````, [#duration(
      weeks: 1
    )], ````typc #duration(
      weeks: 1
    ) ````, [$#duration(
      weeks: 1
    )$]
))

