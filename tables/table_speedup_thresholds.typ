#import "../data.typ": format_2

#let table_speedup_thresholds(data) = {
  let thresholds = data.thresholds
  let threads = data.threads

  let fmt = (value) => if value == none { "-" } else { format_2(value) }

  table(
    columns: 1 + thresholds.len() * 2,
    align: (left, ..range(0, thresholds.len() * 2).map(_ => right)),
    table.header(
      table.cell(rowspan: 2)[Gijos],
      ..thresholds.map(g => table.cell(colspan: 2)[#("g* = " + format_2(g) + "%")]),
      ..thresholds.map(_ => ([$S_p$], [$E_p$])).flatten(),
    ),
    ..threads.map(thread => (
      table.cell(breakable: false)[#str(thread)],
      ..thresholds.map(g => {
        let series = data.series.filter(item => item.g == g).at(0, default: none)
        let point = if series == none { none } else { series.values.filter(v => v.thread == thread).at(0, default: none) }
        let s = if point == none { none } else { point.speedup }
        let e = if point == none { none } else { point.efficiency }
        (
          table.cell(breakable: true)[#fmt(s)],
          table.cell(breakable: true)[#fmt(e)],
        )
      }).flatten(),
    )).flatten(),
  )
}
