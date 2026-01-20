#import "../data.typ": format_2

#let table_speedup_all_instances(speedup_data) = {
  table(
    columns: 1 + speedup_data.threads.len(),
    align: (left, ..speedup_data.threads.map(_ => right)),
    table.header(
      [Uždavinys],
      ..speedup_data.threads.map(t => str(t) + " gijos")
    ),
    ..speedup_data.raw.map(row => {
      (
        [#row.instance_name],
        ..row.speedups.map(s => format_2(s))
      )
    }).flatten()
  )
}
