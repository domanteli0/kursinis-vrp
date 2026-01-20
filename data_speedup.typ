#import "data.typ": gap_percent, read_bks_cost, read_costs, read_times, x_vrp_instances

#let avg_value_valid(values) = {
  let filtered = values.filter(value => value != none)
  if filtered.len() == 0 { none } else { filtered.sum() / filtered.len() }
}

#let max_2(a, b) = if a > b { a } else { b }

#let quantile_value(values, q) = {
  let filtered = values.filter(value => value != none)
  if filtered.len() == 0 { none } else {
    let sorted = filtered.sorted()
    let idx = calc.floor((sorted.len() - 1) * q)
    sorted.at(idx)
  }
}

#let time_to_target_data(instances: x_vrp_instances) = {
  let threads = range(0, 5).map(it => calc.pow(2, it))
  let seeds = range(1, 6)
  let steps = range(0, 100)

  let per_instance = instances.map(name => {
    let bks = read_bks_cost(name)
    let per_thread = threads.map(thread => {
      let seed_costs = seeds.map(seed => {
        let file = "sols/data/" + name + ".t_" + str(thread) + ".seed-" + str(seed) + ".sol.100ths.csv"
        read_costs(file, invalid_above: 1e29)
      })
      let seed_times = seeds.map(seed => {
        let file = "sols/data/" + name + ".t_" + str(thread) + ".seed-" + str(seed) + ".sol.100ths.csv"
        read_times(file)
      })
      let avg_costs = steps.map(idx => avg_value_valid(seed_costs.map(costs => costs.at(idx))))
      let avg_times = steps.map(idx => avg_value_valid(seed_times.map(times => times.at(idx))))
      (thread: thread, avg_costs: avg_costs, avg_times: avg_times)
    })

    let base = per_thread.filter(item => item.thread == 1).at(0)
    let base_cost = base.avg_costs.at(99)
    let target_gap = max_2(0, gap_percent(base_cost, bks))
    let t1 = base.avg_times.at(99)

    let times = per_thread.map(item => {
      if item.thread == 1 {
        (thread: item.thread, time: t1)
      } else {
        let indices = steps.filter(idx => {
          let cost = item.avg_costs.at(idx)
          if cost == none { false } else { gap_percent(cost, bks) <= target_gap }
        })
        let idx = if indices.len() == 0 { 99 } else { indices.at(0) }
        (thread: item.thread, time: item.avg_times.at(idx))
      }
    })

    (t1: t1, target_gap: target_gap, times: times)
  })

  let series = threads.map(thread => {
    let speedups = per_instance.map(inst => {
      let item = inst.times.filter(t => t.thread == thread).at(0)
      if item.time == none or inst.t1 == none { none } else { inst.t1 / item.time }
    })
    let avg_speedup = avg_value_valid(speedups)
    let avg_efficiency = if avg_speedup == none { none } else { avg_speedup / thread }
    (
      thread: thread,
      speedup: avg_speedup,
      efficiency: avg_efficiency,
    )
  })

  (
    threads: threads,
    series: series,
  )
}

#let time_to_target_fixed(instances: x_vrp_instances, thresholds: (0.5, 1.0, 1.5)) = {
  let threads = range(0, 5).map(it => calc.pow(2, it))
  let seeds = range(1, 6)
  let steps = range(0, 100)

  let per_instance = instances.map(name => {
    let bks = read_bks_cost(name)
    let per_thread = threads.map(thread => {
      let seed_costs = seeds.map(seed => {
        let file = "sols/data/" + name + ".t_" + str(thread) + ".seed-" + str(seed) + ".sol.100ths.csv"
        read_costs(file, invalid_above: 1e29)
      })
      let seed_times = seeds.map(seed => {
        let file = "sols/data/" + name + ".t_" + str(thread) + ".seed-" + str(seed) + ".sol.100ths.csv"
        read_times(file)
      })
      let avg_costs = steps.map(idx => avg_value_valid(seed_costs.map(costs => costs.at(idx))))
      let avg_times = steps.map(idx => avg_value_valid(seed_times.map(times => times.at(idx))))
      (thread: thread, avg_costs: avg_costs, avg_times: avg_times)
    })
    (bks: bks, per_thread: per_thread)
  })

  let series = thresholds.map(g => {
    let per_inst = per_instance.map(inst => {
      let base = inst.per_thread.filter(item => item.thread == 1).at(0)
      let base_indices = steps.filter(idx => {
        let cost = base.avg_costs.at(idx)
        if cost == none { false } else { gap_percent(cost, inst.bks) <= g }
      })
      let base_idx = if base_indices.len() == 0 { 99 } else { base_indices.at(0) }
      let t1 = base.avg_times.at(base_idx)

      let times = inst.per_thread.map(item => {
        let indices = steps.filter(idx => {
          let cost = item.avg_costs.at(idx)
          if cost == none { false } else { gap_percent(cost, inst.bks) <= g }
        })
        let idx = if indices.len() == 0 { 99 } else { indices.at(0) }
        (thread: item.thread, time: item.avg_times.at(idx))
      })

      (t1: t1, times: times)
    })

    let values = threads.map(thread => {
      let speedups = per_inst.map(inst => {
        let item = inst.times.filter(t => t.thread == thread).at(0)
        if item.time == none or inst.t1 == none { none } else { inst.t1 / item.time }
      })
      let efficiencies = speedups.map(sp => if sp == none { none } else { sp / thread })
      let avg_speedup = avg_value_valid(speedups)
      let avg_efficiency = if avg_speedup == none { none } else { avg_speedup / thread }
      (
        thread: thread,
        speedup: avg_speedup,
        efficiency: avg_efficiency,
        speedup_p25: quantile_value(speedups, 0.25),
        speedup_p50: quantile_value(speedups, 0.50),
        speedup_p75: quantile_value(speedups, 0.75),
        efficiency_p25: quantile_value(efficiencies, 0.25),
        efficiency_p50: quantile_value(efficiencies, 0.50),
        efficiency_p75: quantile_value(efficiencies, 0.75),
      )
    })

    (g: g, values: values)
  })

  (
    thresholds: thresholds,
    threads: threads,
    series: series,
  )
}
