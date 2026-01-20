#import "../data.typ": format_2, gap_percent

#let table_100_avg_from(data) = {
  let threads = data.threads

  let rows = data.per_instance.map(instance => {
    let stats = threads.map(thread => {
      let thread_data = instance.threads.filter(t => t.thread == thread).at(0, default: none)
      let avg = if thread_data == none { none } else { thread_data.avg_per_percent.at(99) }
      let gap = if avg == none { none } else { gap_percent(avg, instance.bks) }
      (avg: avg, gap: gap)
    })

    (instance_name: instance.name, stats: stats)
  })

  let fmt = (value) => if value == none { "-" } else { format_2(value) }

  table(
    columns: 1 + threads.len() * 2,
    align: (left, ..range(0, threads.len() * 2).map(_ => right)),
    table.header(
      table.cell(rowspan: 2)[Uždavinys],
      ..threads.map(t => table.cell(colspan: 2)[#(
        if t == 1 { [1 gija#footnote[Naudota originali realizacija]] } else { str(t) + " gijos" }
      )]),
      ..threads.map(_ => ([Avg], [Spraga])).flatten(),
    ),
    ..rows.map(row => (
      table.cell(breakable: false)[#row.instance_name],
      ..row.stats.map(stat => (
        table.cell(breakable: true)[#fmt(stat.avg)],
        table.cell(breakable: true)[#(
          if stat.gap == none { "-" } else { format_2(stat.gap) + "%" }
        )],
      )).flatten(),
    )).flatten(),
  )
}
