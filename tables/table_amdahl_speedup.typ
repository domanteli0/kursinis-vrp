#import "../data.typ": format_2

#let amdahl_speedup(thread, parallel_fraction) = {
  1 / ((1 - parallel_fraction) + parallel_fraction / thread)
}

#let table_amdahl_speedup(parallel_fraction: 0.86, threads: (1, 2, 4, 8, 16)) = {
  let rows = threads.map(thread => (
    thread: thread,
    speedup: amdahl_speedup(thread, parallel_fraction),
  ))

  table(
    columns: 2,
    align: (left, right),
    table.header(
      [Gijų skaičius],
      [Teorinis greitėjimas $S_p$],
    ),
    ..rows.map(row => (
      table.cell(breakable: false)[#str(row.thread)],
      table.cell(breakable: true)[#format_2(row.speedup)],
    )).flatten(),
  )
}
