#let small_x_vrp_instances = (
  "X-n101-k25",
  "X-n106-k14",
  "X-n110-k13",
  "X-n115-k10",
  "X-n120-k6",
  "X-n125-k30",
  "X-n129-k18",
  "X-n134-k13",
  "X-n139-k10",
  "X-n143-k7",
  "X-n148-k46",
  "X-n153-k22",
  "X-n157-k13",
  "X-n162-k11",
  "X-n167-k10",
  "X-n172-k51",
  "X-n176-k26",
  "X-n181-k23",
  "X-n186-k15",
  "X-n190-k8",
  "X-n195-k51",
  "X-n200-k36",
  "X-n204-k19",
  "X-n209-k16",
  "X-n214-k11",
  "X-n219-k73",
  "X-n223-k34",
  "X-n228-k23",
  "X-n233-k16",
  "X-n237-k14",
  "X-n242-k48",
  "X-n247-k50",
  "X-n251-k28",
  "X-n256-k16",
  "X-n261-k13",
)

#let medium_x_vrp_instances = (
  "X-n266-k58",
  "X-n270-k35",
  "X-n275-k28",
  "X-n280-k17",
  "X-n284-k15",
  "X-n289-k60",
  "X-n294-k50",
  "X-n298-k31",
  "X-n303-k21",
  "X-n308-k13",
  "X-n313-k71",
  "X-n317-k53",
  "X-n322-k28",
  "X-n327-k20",
  "X-n331-k15",
  "X-n336-k84",
  "X-n344-k43",
  "X-n351-k40",
  "X-n359-k29",
  "X-n367-k17",
  "X-n376-k94",
  "X-n384-k52",
  "X-n393-k38",
  "X-n401-k29",
  "X-n411-k19",
  "X-n420-k130",
  "X-n429-k61",
  "X-n439-k37",
  "X-n449-k29",
  "X-n459-k26",
  "X-n469-k138",
  "X-n480-k70",
  "X-n491-k59",
  "X-n502-k39",
  "X-n513-k21",
)

#let large_x_vrp_instances = (
  "X-n524-k153",
  "X-n536-k96",
  "X-n548-k50",
  "X-n561-k42",
  "X-n573-k30",
  "X-n586-k159",
  "X-n599-k92",
  "X-n613-k62",
  "X-n627-k43",
  "X-n641-k35",
  "X-n655-k131",
  "X-n670-k130",
  "X-n685-k75",
  "X-n701-k44",
  "X-n716-k35",
  "X-n733-k159",
  "X-n749-k98",
  "X-n766-k71",
  "X-n783-k48",
  "X-n801-k40",
  "X-n819-k171",
  "X-n837-k142",
  "X-n856-k95",
  "X-n876-k59",
  "X-n895-k37",
  "X-n916-k207",
  "X-n936-k151",
  "X-n957-k87",
  "X-n979-k58",
  "X-n1001-k43",
)

#let x_vrp_instances = (
  // small_x_vrp_instances,
  medium_x_vrp_instances,
  large_x_vrp_instances,
).flatten()

#let cmt_instances = (
  "CMT1",
  "CMT2",
  "CMT3",
  "CMT4",
  "CMT5",
  "CMT6",
  "CMT7",
  "CMT8",
  "CMT9",
  "CMT10",
  "CMT11",
  "CMT12",
  "CMT13",
  "CMT14",
)

#let golden_instances = (
  "Golden_1",
  "Golden_2",
  "Golden_3",
  "Golden_4",
  "Golden_5",
  "Golden_6",
  "Golden_7",
  "Golden_8",
  "Golden_9",
  "Golden_10",
  "Golden_11",
  "Golden_12",
  "Golden_13",
  "Golden_14",
  "Golden_15",
  "Golden_16",
  "Golden_17",
  "Golden_18",
  "Golden_19",
  "Golden_20",
)

#let min_value = (values) => {
  if values.len() == 0 { 0 } else {
    values.slice(1).fold(values.at(0), (acc, item) => if item < acc { item } else { acc })
  }
}

#let max_value = (values) => {
  if values.len() == 0 { 0 } else {
    values.slice(1).fold(values.at(0), (acc, item) => if item > acc { item } else { acc })
  }
}

#let median_value = (values) => {
  let filtered = values.filter(value => value != none)
  let count = filtered.len()
  if count == 0 {
    none
  } else {
    let sorted = filtered.sorted()
    let mid = calc.floor(count / 2)
    if calc.rem(count, 2) == 1 {
      sorted.at(mid)
    } else {
      (sorted.at(mid - 1) + sorted.at(mid)) / 2
    }
  }
}

#let ATTEMPTS = range(1, 6)
#let PERCENTS = (1, 2, 5, 10, 15, 20, 30, 50, 75, 100)
#let POWERS = range(0, 5).map(it => calc.pow(2, it))
#let TIMESERIES = range(0, 101)

#let read_raw_instance(instance_name) = {
  let combinations = POWERS.map(pow => (pow: pow, attempts: ATTEMPTS))

  let files = combinations
    .map(comb => comb.attempts.map(attempt => (pow: comb.pow, attempt: attempt)))
    .flatten()
    .map(comb =>
      (
        pow: comb.pow,
        attempt: comb.attempt,
        file: "sols/data/" + instance_name + ".t_" + str(comb.pow)
          + ".seed-" + str(comb.attempt) + ".sol.100ths.csv"
      )
    )

  let read_percent = (file, percent) => {
    if percent == 0 {
      return (cost: calc.inf, time: 0.0)
    }

    let rows = csv(file, delimiter: ";").slice(1)

    assert(rows.len() == 100, message: str(file) + " does not have 100 rows")

    let columns = rows.at(percent - 1, default: ())

    (
      cost: float(columns.at(2)),
      time: float(columns.at(3)),
    )
  }

  let avg_for_time = (pow, time) => {
    let pow_files = files.filter(file => file.pow == pow)
    let samples = pow_files.map(file => read_percent(file.file, time))
    let count = samples.len()

    (
      instance_name: instance_name,
      threads: pow,
      time_avg: samples.map(sample => sample.time).sum() / count,
      time_min: calc.min(samples.map(sample => sample.time)),
      time_max: calc.max(samples.map(sample => sample.time)),
      cost_avg: samples.map(sample => sample.cost).sum() / count,
      cost_min: min_value(samples.map(sample => sample.cost)),
      cost_max: max_value(samples.map(sample => sample.cost)),
    )
  }

  POWERS.map(pow => {
    TIMESERIES.map(time => avg_for_time(pow, time))
  })
}

#let read_instance(instance_name) = {
  let combinations = POWERS.map(pow => (pow, ATTEMPTS))

  let files = combinations
    .map(comb => comb.at(1).map(attempt => (pow: comb.at(0), attempt: attempt)))
    .flatten()
    .map(comb =>
      (
        pow: comb.pow,
        attempt: comb.attempt,
        file: "sols/data/" + instance_name + ".t_" + str(comb.pow)
          + ".seed-" + str(comb.attempt) + ".sol.100ths.csv"
      )
    )

  let read_percent = (file, percent) => {
    let rows = csv(file, delimiter: ";").slice(1)

    assert(rows.len() == 100, message: str(file) + " does not have 100 rows")

    let columns = rows.at(percent - 1, default: ())

    (
      cost: float(columns.at(2)),
      time: float(columns.at(3)),
    )
  }

  let avg_for_percent = (pow, percent) => {
    let pow_files = files.filter(file => file.pow == pow)
    let samples = pow_files.map(file => read_percent(file.file, percent))
    let count = samples.len()

    (
      threads: pow,
      time_avg: samples.map(sample => sample.time).sum() / count,
      time_min: calc.min()(samples.map(sample => sample.time)),
      time_max: calc.max(samples.map(sample => sample.time)),
      cost_avg: samples.map(sample => sample.cost).sum() / count,
      cost_min: min_value(samples.map(sample => sample.cost)),
      cost_max: max_value(samples.map(sample => sample.cost)),
    )
  }

  let results = POWERS.map(pow => {
    let stats = PERCENTS.map(percent => avg_for_percent(pow, percent))

    (
      instance_name: instance_name,
      threads: pow,
      _1_time_avg: stats.at(0).time_avg,
      _1_time_min: stats.at(0).time_min,
      _1_time_max: stats.at(0).time_max,
      _1_cost_avg: stats.at(0).cost_avg,
      _1_cost_min: stats.at(0).cost_min,
      _1_cost_max: stats.at(0).cost_max,
      _2_time_avg: stats.at(1).time_avg,
      _2_time_min: stats.at(1).time_min,
      _2_time_max: stats.at(1).time_max,
      _2_cost_avg: stats.at(1).cost_avg,
      _2_cost_min: stats.at(1).cost_min,
      _2_cost_max: stats.at(1).cost_max,
      _5_time_avg: stats.at(2).time_avg,
      _5_time_min: stats.at(2).time_min,
      _5_time_max: stats.at(2).time_max,
      _5_cost_avg: stats.at(2).cost_avg,
      _5_cost_min: stats.at(2).cost_min,
      _5_cost_max: stats.at(2).cost_max,
      _10_time_avg: stats.at(3).time_avg,
      _10_time_min: stats.at(3).time_min,
      _10_time_max: stats.at(3).time_max,
      _10_cost_avg: stats.at(3).cost_avg,
      _10_cost_min: stats.at(3).cost_min,
      _10_cost_max: stats.at(3).cost_max,
      _15_time_avg: stats.at(4).time_avg,
      _15_time_min: stats.at(4).time_min,
      _15_time_max: stats.at(4).time_max,
      _15_cost_avg: stats.at(4).cost_avg,
      _15_cost_min: stats.at(4).cost_min,
      _15_cost_max: stats.at(4).cost_max,
      _20_time_avg: stats.at(5).time_avg,
      _20_time_min: stats.at(5).time_min,
      _20_time_max: stats.at(5).time_max,
      _20_cost_avg: stats.at(5).cost_avg,
      _20_cost_min: stats.at(5).cost_min,
      _20_cost_max: stats.at(5).cost_max,
      _30_time_avg: stats.at(6).time_avg,
      _30_time_min: stats.at(6).time_min,
      _30_time_max: stats.at(6).time_max,
      _30_cost_avg: stats.at(6).cost_avg,
      _30_cost_min: stats.at(6).cost_min,
      _30_cost_max: stats.at(6).cost_max,
      _50_time_avg: stats.at(7).time_avg,
      _50_time_min: stats.at(7).time_min,
      _50_time_max: stats.at(7).time_max,
      _50_cost_avg: stats.at(7).cost_avg,
      _50_cost_min: stats.at(7).cost_min,
      _50_cost_max: stats.at(7).cost_max,
      _75_time_avg: stats.at(8).time_avg,
      _75_time_min: stats.at(8).time_min,
      _75_time_max: stats.at(8).time_max,
      _75_cost_avg: stats.at(8).cost_avg,
      _75_cost_min: stats.at(8).cost_min,
      _75_cost_max: stats.at(8).cost_max,
      _100_time_avg: stats.at(9).time_avg,
      _100_time_min: stats.at(9).time_min,
      _100_time_max: stats.at(9).time_max,
      _100_cost_avg: stats.at(9).cost_avg,
      _100_cost_min: stats.at(9).cost_min,
      _100_cost_max: stats.at(9).cost_max,
    )
  })

  results
}

#let read_costs = (file, invalid_above: none) => {
  let rows = csv(file, delimiter: ";").slice(1)

  assert(rows.len() == 100, message: str(file) + " does not have 100 rows")

  let costs = rows.map(row => float(row.at(2)))
  if invalid_above == none {
    costs
  } else {
    costs.map(cost => if cost >= invalid_above { none } else { cost })
  }
}

#let read_times = (file, invalid_above: none) => {
  let rows = csv(file, delimiter: ";").slice(1)

  assert(rows.len() == 100, message: str(file) + " does not have 100 rows")

  let times = rows.map(row => float(row.at(3)))
  if invalid_above == none {
    times
  } else {
    times.map(time => if time >= invalid_above { none } else { time })
  }
}

#let min_value_valid = (values) => {
  let filtered = values.filter(value => value != none)
  if filtered.len() == 0 { none } else { min_value(filtered) }
}

#let format_2 = (value) => {
  let rounded = calc.round(value * 100) / 100
  str(rounded)
}

#let gap_percent = (value, best) => {
  if best == 0 { 0 } else { (value - best) / best * 100 }
}

#let read_bks_cost = (instance_name) => {
  let path = "sols/bks/" + instance_name + ".sol"
  let content = read(path)
  let lines = content.split("\n").filter(line => line.trim() != "")
  if lines.len() == 0 {
    0
  } else {
    let last = lines.at(lines.len() - 1)
    let parts = last.trim().split(" ")
    if parts.len() < 2 { 0 } else { float(parts.at(1)) }
  }
}

#let table_100_avg = (instances) => {
  if instances.len() == 0 { none }

  let threads = instances.at(0).map(row => row.threads)

  let rows = instances.map(instance => {
    let instance_name = instance.at(0).instance_name
    let stats = instance.map(row => (
      avg: row._100_cost_avg,
    ))

    (instance_name: instance_name, stats: stats)
  })

  table(
    columns: 1 + threads.len() * 2,
    align: (left, ..range(0, threads.len() * 2).map(_ => right)),
    table.header(
      table.cell(rowspan: 2)[Instance],
      ..threads.map(t => table.cell(colspan: 2)[#(if t == 1 { [1 gija#footnote[Naudota originali realizacija]] } else { str(t) + " gijos" })]),
      ..threads.map(_ => ([Avg], [Spraga])).flatten(),
    ),
    ..rows.map(row => {
      let bks = read_bks_cost(row.instance_name)
      (
        table.cell(breakable: false)[#row.instance_name],
        ..row.stats.map(stat => (
          table.cell(breakable: true)[#format_2(stat.avg)],
          table.cell(breakable: true)[#(format_2(gap_percent(stat.avg, bks)) + "%")],
        )).flatten(),
      )
    }).flatten(),
  )
}

// TODO: FIND AT CLOSEST TIME MOMENT
// FIND AT CLOSEST TIME MOMENT

#let time_to_match_from_raw(raw_data) = {
  let t1_series = raw_data.at(0)
  let target_cost = t1_series.at(100).cost_avg

  let series_to_results(series) = {
    let result_index = none
    for i in range(0, series.len()) {
      let entry = series.at(i)
      if entry.cost_avg <= target_cost {
        result_index = i
        break
      }
    }
    if result_index == none {
      (time_step: none, cost: none)
    } else {
      (time_step: result_index, cost: series.at(result_index).cost_avg)
    }
  }

  raw_data.slice(1).map(series => series_to_results(series))
}
