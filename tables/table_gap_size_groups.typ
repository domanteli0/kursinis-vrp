#import "../data.typ": format_2, gap_percent

#let group_id_from_name(name) = {
  let parts = name.split("-")
  if parts.len() < 3 {
    none
  } else {
    let n_str = parts.at(1).split("n").at(1, default: none)
    if n_str == none {
      none
    } else {
      let n_val = float(n_str)
      if n_val <= 300 { "n<=300" }
      else if n_val <= 600 { "300<n<=600" }
      else { "n>600" }
    }
  }
}

#let avg_value(values) = {
  let filtered = values.filter(value => value != none)
  if filtered.len() == 0 { none } else { filtered.sum() / filtered.len() }
}

#let gap_size_groups_from(data) = {
  let groups = (
    (id: "n<=300", label: "n <= 300"),
    (id: "300<n<=600", label: "300 < n <= 600"),
    (id: "n>600", label: "n > 600"),
  )

  let threads = data.threads

  let group_stats = groups.map(group => {
    let instances = data.per_instance.filter(inst => group_id_from_name(inst.name) == group.id)
    let stats = threads.map(thread => {
      let gaps = instances.map(inst => {
        let thread_data = inst.threads.filter(t => t.thread == thread).at(0, default: none)
        if thread_data == none {
          none
        } else {
          let avg = thread_data.avg_per_percent.at(99, default: none)
          if avg == none { none } else { gap_percent(avg, inst.bks) }
        }
      })
      (thread: thread, avg_gap: avg_value(gaps))
    })
    (id: group.id, label: group.label, count: instances.len(), stats: stats)
  })

  (threads: threads, groups: group_stats)
}

#let table_gap_size_groups_from(data) = {
  let result = gap_size_groups_from(data)
  let threads = result.threads
  let groups = result.groups

  let fmt = (value) => if value == none { "-" } else { format_2(value) + "%" }

  table(
    columns: 2 + threads.len(),
    align: (left, right, ..range(0, threads.len()).map(_ => right)),
    table.header(
      table.cell(rowspan: 2)[Grupė (n)],
      table.cell(rowspan: 2)[Kiekis],
      ..threads.map(t => table.cell()[#(
        if t == 1 { [1 gija#footnote[Naudota originali realizacija]] } else { str(t) + " gijos" }
      )]),
      ..threads.map(_ => [Vid. spraga (%)]),
    ),
    ..groups.map(group => (
      table.cell(breakable: false)[#group.label],
      table.cell(breakable: false)[#str(group.count)],
      ..group.stats.map(stat => table.cell(breakable: true)[#fmt(stat.avg_gap)]),
    )).flatten(),
  )
}
