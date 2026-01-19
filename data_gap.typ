#import "data.typ": gap_percent, max_value, min_value, read_bks_cost, read_costs, x_vrp_instances

#let gap_floor = 0.02
#let gap_time_marks = (1, 2, 5, 10, 15, 20, 30, 50, 75, 100)

#let gap_at_time(points, time) = {
  let match = points.filter(p => p.at(0) == time)
  if match.len() == 0 { none } else { match.at(0).at(1) }
}

#let gap_threads_series(data) = data.series.filter(s => s.points.len() > 0)

#let gap_speedup_series_from(data, times: none) = {
  let series = gap_threads_series(data)
  let base = series.filter(s => s.thread == 1).at(0, default: none)
  let selected_times = if times != none {
    times
  } else if base == none {
    ()
  } else {
    base.points.map(p => p.at(0))
  }

  series.filter(s => s.thread != 1).map(item => (
    thread: item.thread,
    points: selected_times.map(time => {
      let base_gap = if base == none { none } else { gap_at_time(base.points, time) }
      let thread_gap = gap_at_time(item.points, time)
      if base_gap == none or thread_gap == none or thread_gap <= 0 {
        none
      } else {
        (time, base_gap / thread_gap)
      }
    }).filter(point => point != none),
  ))
}

#let normalize_gap(value) = {
  if value == none { none }
  else {
    let magnitude = calc.abs(value)
    if magnitude < gap_floor { gap_floor } else { magnitude }
  }
}

#let avg_value_valid(values) = {
  let filtered = values.filter(value => value != none)
  if filtered.len() == 0 { none } else { filtered.sum() / filtered.len() }
}

#let build_gap_series(instances: x_vrp_instances) = {
  let threads = range(0, 5).map(it => calc.pow(2, it))
  let seeds = range(1, 6)
  let steps = range(0, 100)

  let per_instance = instances.map(name => (
    name: name,
    bks: read_bks_cost(name),
    threads: threads.map(thread => {
      let seed_costs = seeds.map(seed => {
        let file = "sols/data/" + name + ".t_" + str(thread) + ".seed-" + str(seed) + ".sol.100ths.csv"
        read_costs(file, invalid_above: 1e29)
      })
      let avg_per_percent = steps.map(idx => {
        avg_value_valid(seed_costs.map(costs => costs.at(idx)))
      })
      (thread: thread, avg_per_percent: avg_per_percent)
    }),
  ))

  let series = threads.map(thread => (
    thread: thread,
    points: steps.map(idx => {
      let gaps = per_instance.map(inst => {
        let thread_data = inst.threads.filter(t => t.thread == thread).at(0)
        let cost = thread_data.avg_per_percent.at(idx)
        if cost == none { none } else { gap_percent(cost, inst.bks) }
      }).filter(gap => gap != none)
      let avg_gap = if gaps.len() == 0 { none } else { gaps.sum() / gaps.len() }
      let normalized = normalize_gap(avg_gap)
      if normalized == none { none } else { (idx + 1, normalized) }
    }).filter(point => point != none),
  ))

  let gap_values = series.map(s => s.points.map(p => p.at(1))).flatten()
  let gap_pos = gap_values.filter(value => value > 0)
  let gap_min_data = if gap_pos.len() == 0 { gap_floor } else { min_value(gap_pos) }
  let gap_upper_data = if gap_pos.len() == 0 { 1.5 } else { max_value(gap_pos) * 1.1 }
  let gap_min = if gap_min_data < gap_floor { gap_floor } else { gap_min_data }
  let gap_max_raw = if gap_upper_data < 1.5 { 1.5 } else { gap_upper_data }
  let gap_max = if gap_max_raw <= gap_min { gap_min * 10 } else { gap_max_raw }

  (
    series: series,
    gap_min: gap_min,
    gap_max: gap_max,
    per_instance: per_instance,
    threads: threads,
  )
}

#let gap_data(instances: x_vrp_instances) = build_gap_series(instances: instances)
