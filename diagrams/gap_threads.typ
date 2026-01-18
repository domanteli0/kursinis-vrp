#import "@preview/cetz:0.4.2": canvas, draw
#import "@preview/cetz-plot:0.1.3": plot
#import "../data.typ": format_2, gap_percent, max_value, median_value, min_value, min_value_valid, read_bks_cost, read_costs, x_vrp_instances

#let thread_label(thread) = {
  if thread == 1 { "1 gija" }
  else if thread == 16 { "16 gijų" }
  else { str(thread) + " gijos" }
}

#let thread_style(thread) = {
  if thread == 1 {
    (stroke: (paint: black, thickness: 1pt))
  } else if thread == 2 {
    (stroke: (paint: black, thickness: 1pt, dash: (6pt, 2pt)))
  } else if thread == 4 {
    (stroke: (paint: black, thickness: 1pt, dash: (3pt, 2pt)))
  } else if thread == 8 {
    (stroke: (paint: black, thickness: 1pt, dash: (1.5pt, 1.5pt)))
  } else if thread == 16 {
    (stroke: (paint: black, thickness: 1pt, dash: (6pt, 2pt, 1pt, 2pt)))
  } else {
    (stroke: (paint: black, thickness: 1pt))
  }
}

#let time_mark_positions = (10, 30, 50, 70, 90)

#let thread_mark(thread) = {
  if thread == 1 { "o" }
  else if thread == 2 { "square" }
  else if thread == 4 { "triangle" }
  else if thread == 8 { "x" }
  else if thread == 16 { "+" }
  else { "*" }
}

#let tick_mark_size = 0.2
#let legend_mark_size = 0.5

#let draw_mark_shape(pt, size, mark, style: (:)) = {
  let sx = size
  let sy = size

  let bl = (pt.at(0) - sx / 2, pt.at(1) - sy / 2)
  let br = (pt.at(0) + sx / 2, pt.at(1) - sy / 2)
  let tl = (pt.at(0) - sx / 2, pt.at(1) + sy / 2)
  let tr = (pt.at(0) + sx / 2, pt.at(1) + sy / 2)
  let ll = (pt.at(0) - sx / 2, pt.at(1))
  let rr = (pt.at(0) + sx / 2, pt.at(1))
  let tt = (pt.at(0), pt.at(1) + sy / 2)
  let bb = (pt.at(0), pt.at(1) - sy / 2)

  if mark == "o" {
    draw.circle(pt, radius: (sx / 2, sy / 2), ..style)
  } else if mark == "square" {
    draw.rect(bl, tr, ..style)
  } else if mark == "triangle" {
    draw.line(bl, br, tt, close: true, ..style)
  } else if mark == "x" {
    draw.line(bl, tr, ..style)
    draw.line(tl, br, ..style)
  } else if mark == "+" {
    draw.line(ll, rr, ..style)
    draw.line(tt, bb, ..style)
  } else if mark == "*" {
    draw.line(bl, tr, ..style)
    draw.line(tl, br, ..style)
    draw.line(ll, rr, ..style)
    draw.line(tt, bb, ..style)
  } else {
    draw.circle(pt, radius: (sx / 2, sy / 2), ..style)
  }
}

#let legend_preview(thread) = () => {
  import draw: *

  let mark = thread_mark(thread)
  line((0, 0.5), (1, 0.5), ..thread_style(thread))
  draw_mark_shape((0.5, 0.5), legend_mark_size, mark, style: (stroke: black, fill: white))
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
      let best_per_percent = steps.map(idx => {
        min_value_valid(seed_costs.map(costs => costs.at(idx)))
      })
      (thread: thread, best_per_percent: best_per_percent)
    }),
  ))

  let series = threads.map(thread => (
    thread: thread,
    points: steps.map(idx => {
      let gaps = per_instance.map(inst => {
        let thread_data = inst.threads.filter(t => t.thread == thread).at(0)
        let cost = thread_data.best_per_percent.at(idx)
        if cost == none { none } else { gap_percent(cost, inst.bks) }
      }).filter(gap => gap != none)
      let avg_gap = if gaps.len() == 0 { none } else { gaps.sum() / gaps.len() }
      if avg_gap == none or avg_gap <= 0 { none } else { (idx + 1, avg_gap) }
    }).filter(point => point != none),
  ))

  let gap_values = series.map(s => s.points.map(p => p.at(1))).flatten()
  let gap_pos = gap_values.filter(value => value > 0)
  let gap_min_data = if gap_pos.len() == 0 { 0.02 } else { min_value(gap_pos) }
  let gap_upper_data = if gap_pos.len() == 0 { 1.5 } else { max_value(gap_pos) * 1.1 }
  let gap_min = if gap_min_data > 0.02 { 0.02 } else { gap_min_data }
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

#let time_for_gap(best_per_percent, bks, target) = {
  let gaps = best_per_percent.map(cost => if cost == none { none } else { gap_percent(cost, bks) })
  let idx = gaps.position(gap => gap != none and gap <= target)
  if idx == none { none } else { idx + 1 }
}

#let gap_at_time(points, time) = {
  let match = points.filter(p => p.at(0) == time)
  if match.len() == 0 { none } else { match.at(0).at(1) }
}

#let gap_threads_plot(instances: x_vrp_instances) = canvas({
  import draw: *

  set-style(
    axes: (
      stroke: .5pt,
      tick: (stroke: .5pt),
      grid: (stroke: (paint: gray.lighten(70%), thickness: .4pt)),
    ),
    legend: (
      stroke: none,
      orientation: ltr,
      item: (spacing: .3, preview: (width: .6, height: .6, margin: .15)),
      scale: 80%,
    ),
  )

  let y_ticks = (0.1, 0.25, 0.5, 1, 2)
  let result = build_gap_series(instances: instances)

  plot.plot(
    size: (12, 7),
    x-min: 1,
    x-max: 100,
    x-tick-step: 10,
    x-label: [Vykdymo laikas (%)],
    y-min: 0.1,
    y-max: 2.5,
    y-mode: "log",
    y-base: 10,
    y-label: [Gap (%)],
    y-ticks: y_ticks,
    y-tick-step: none,
    y-minor-tick-step: none,
    y-format: format_2,
    y-grid: "major",
    legend: "north",
    {
      for item in result.series {
        plot.add(item.points, line: "spline", label: none, style: thread_style(item.thread))

        let mark = thread_mark(item.thread)
        for x in time_mark_positions {
          let match = item.points.filter(p => p.at(0) == x)
          if match.len() > 0 {
            plot.add(
              (match.at(0),),
              mark: mark,
              mark-size: tick_mark_size,
              label: none,
              style: (stroke: none),
              mark-style: (stroke: black, fill: white),
            )
          }
        }
      }

      for thread in result.threads {
        plot.add-legend(thread_label(thread), preview: legend_preview(thread))
      }
    },
  )
})

#let gap_time_plot(instances: x_vrp_instances) = canvas({
  import draw: *

  set-style(
    axes: (stroke: .5pt, tick: (stroke: .5pt)),
    legend: (
      stroke: none,
      orientation: ltr,
      item: (spacing: .3, preview: (width: .6, height: .6, margin: .15)),
      scale: 80%,
    ),
  )

  let x_ticks = (0.02, 0.05, 0.1, 0.25, 0.5, 1, 1.5)
  let result = build_gap_series(instances: instances)

  let series = result.series.map(item => (
    thread: item.thread,
    points: item.points.map(point => (point.at(1), point.at(0))),
  ))

  plot.plot(
    size: (12, 7),
    x-min: result.gap_max,
    x-max: result.gap_min,
    x-mode: "log",
    x-base: 10,
    x-label: [Gap (%)],
    x-ticks: x_ticks,
    x-tick-step: none,
    x-minor-tick-step: none,
    x-format: format_2,
    y-min: 1,
    y-max: 100,
    y-tick-step: 10,
    y-label: [Vykdymo laikas (%)],
    legend: "north",
    {
      for item in series {
        plot.add(item.points, line: "spline", label: none, style: thread_style(item.thread))
      }

      for thread in result.threads {
        plot.add-legend(thread_label(thread), preview: legend_preview(thread))
      }
    },
  )
})

#let gap_speedup_plot(instances: x_vrp_instances) = canvas({
  import draw: *

  set-style(
    axes: (stroke: .5pt, tick: (stroke: .5pt)),
    legend: (
      stroke: none,
      orientation: ltr,
      item: (spacing: .3, preview: (width: .6, height: .6, margin: .15)),
      scale: 80%,
    ),
  )

  let result = build_gap_series(instances: instances)

  let base = result.series.filter(s => s.thread == 1).at(0, default: none)
  let times = if base == none { () } else { base.points.map(p => p.at(0)) }

  let series = result.series.filter(s => s.thread != 1).map(item => (
    thread: item.thread,
    points: times.map(time => {
      let base_gap = gap_at_time(base.points, time)
      let thread_gap = gap_at_time(item.points, time)
      if base_gap == none or thread_gap == none or thread_gap <= 0 {
        none
      } else {
        (time, base_gap / thread_gap)
      }
    }).filter(point => point != none),
  ))

  let ratio_values = series.map(s => s.points.map(p => p.at(1))).flatten()
  let y_min = 1
  let y_max_data = if ratio_values.len() == 0 { 2 } else { max_value(ratio_values) * 1.1 }
  let y_max = if y_max_data <= y_min { y_min + 1 } else { y_max_data }

  let y_ticks = (1, 1.25, 1.5, 1.75, 2, 2.25, 2.5)

  plot.plot(
    size: (12, 7),
    x-min: 1,
    x-max: 100,
    x-tick-step: 10,
    x-label: [Vykdymo laikas (%)],
    y-min: y_min,
    y-max: y_max,
    y-label: [Gap santykis (1 gija / N gijų)],
    y-ticks: y_ticks,
    y-tick-step: none,
    y-minor-tick-step: none,
    y-format: format_2,
    y-grid: "major",
    legend: "north",
    {
      for item in series {
        plot.add(item.points, line: "spline", label: none, style: thread_style(item.thread))

        let mark = thread_mark(item.thread)
        for x in time_mark_positions {
          let match = item.points.filter(p => p.at(0) == x)
          if match.len() > 0 {
            plot.add(
              (match.at(0),),
              mark: mark,
              mark-size: tick_mark_size,
              label: none,
              style: (stroke: none),
              mark-style: (stroke: black, fill: white),
            )
          }
        }
      }

      for thread in result.threads.filter(thread => thread != 1) {
        plot.add-legend(thread_label(thread), preview: legend_preview(thread))
      }
    },
  )
})
