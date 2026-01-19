#import "../data.typ": format_2
#import "../data_gap.typ": gap_at_time, gap_speedup_series_from, gap_threads_series, gap_time_marks

#let table_gap_threads_from(data) = {
  let series = gap_threads_series(data)
  let threads = series.map(s => s.thread)

  let rows = range(0, 101).map(time => (
    time: time,
    values: series.map(s => gap_at_time(s.points, time)),
  ))

  let fmt = (value) => if value == none { "-" } else { format_2(value) + "%" }

  table(
    columns: 1 + threads.len(),
    align: (left, ..range(0, threads.len()).map(_ => right)),
    table.header(
      table.cell(rowspan: 2)[Vykdymo laikas (%)],
      ..threads.map(t => table.cell()[#(
        if t == 1 { [1 gija#footnote[Naudota originali realizacija]] } else { str(t) + " gijos" }
      )]),
      ..threads.map(_ => [Tarpas (%)]),
    ),
    ..rows.map(row => (
      table.cell(breakable: false)[#str(row.time)],
      ..row.values.map(value => table.cell(breakable: true)[#fmt(value)]),
    )).flatten(),
  )
}

#let table_gap_speedup_from(data) = {
  let series = gap_speedup_series_from(data)
  let threads = series.map(s => s.thread)

  let rows = range(0, 101).map(time => (
    time: time,
    values: threads.map(thread => {
      let item = series.filter(s => s.thread == thread).at(0, default: none)
      if item == none { none } else { gap_at_time(item.points, time) }
    }),
  ))

  let fmt = (value) => if value == none { "-" } else { format_2(value) }

  table(
    columns: 1 + threads.len(),
    align: (left, ..range(0, threads.len()).map(_ => right)),
    table.header(
      table.cell(rowspan: 2)[Vykdymo laikas (%)],
      ..threads.map(t => table.cell()[#(str(t) + " gijos")]),
      ..threads.map(_ => [Santykis]),
    ),
    ..rows.map(row => (
      table.cell(breakable: false)[#str(row.time)],
      ..row.values.map(value => table.cell(breakable: true)[#fmt(value)]),
    )).flatten(),
  )
}
