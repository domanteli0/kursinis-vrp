#import "../data.typ": format_2

#let table_speedup_quantiles(data) = {
  let thresholds = data.thresholds
  let threads = data.threads

  let fmt = (value) => if value == none { "-" } else { format_2(value) }
  let fmt_range = (p50, p25, p75) => {
    if p50 == none { "-" } else { fmt(p50) + " (" + fmt(p25) + "-" + fmt(p75) + ")" }
  }

  table(
    columns: 1 + thresholds.len() * 2,
    align: (left, ..range(0, thresholds.len() * 2).map(_ => right)),
    table.header(
      table.cell(rowspan: 2)[Gijos],
      ..thresholds.map(g => table.cell(colspan: 2)[#("g* = " + format_2(g) + "%")]),
      ..thresholds.map(_ => ([$S_p$ P50 (P25-P75)], [$E_p$ P50 (P25-P75)])).flatten(),
    ),
    ..threads.map(thread => (
      table.cell(breakable: false)[#str(thread)],
      ..thresholds.map(g => {
        let series = data.series.filter(item => item.g == g).at(0, default: none)
        let point = if series == none { none } else { series.values.filter(v => v.thread == thread).at(0, default: none) }
        let sp = if point == none { (none, none, none) } else { (point.speedup_p50, point.speedup_p25, point.speedup_p75) }
        let ep = if point == none { (none, none, none) } else { (point.efficiency_p50, point.efficiency_p25, point.efficiency_p75) }
        (
          table.cell(breakable: true)[#fmt_range(sp.at(0), sp.at(1), sp.at(2))],
          table.cell(breakable: true)[#fmt_range(ep.at(0), ep.at(1), ep.at(2))],
        )
      }).flatten(),
    )).flatten(),
  )
}
