#import "@preview/cetz:0.4.2": canvas, draw
#import "@preview/cetz-plot:0.1.3": plot
#import "../data.typ": format_2, max_value

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

#let time_mark_positions = (1, 2, 5, 10, 15, 20, 30, 50, 75, 100)

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

#let gap_at_time(points, time) = {
  let match = points.filter(p => p.at(0) == time)
  if match.len() == 0 { none } else { match.at(0).at(1) }
}

#let gap_threads_plot_from(data) = canvas({
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

  let result = data
  let y_ticks = (0.02, 0.05, 0.1, 0.25, 0.5, 1, 2, 5, 10, 20)
  let non_empty_series = result.series.filter(s => s.points.len() > 0)

  plot.plot(
    size: (11, 8),
    x-min: 0.9,
    x-max: 105,
    x-ticks: time_mark_positions,
    x-tick-step: none,
    x-minor-tick-step: none,
    x-label: [Vykdymo laikas (%)],
    x-mode: "log",
    y-min: 0.125,
    y-max: 2.74,
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
      for item in non_empty_series {
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

      for thread in non_empty_series.map(s => s.thread) {
        plot.add-legend(thread_label(thread), preview: legend_preview(thread))
      }
    },
  )
})

#let gap_speedup_plot_from(data) = canvas({
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

  let result = data

  let base = result.series.filter(s => s.thread == 1 and s.points.len() > 0).at(0, default: none)
  let times = if base == none { () } else { base.points.map(p => p.at(0)) }

  let series = result.series.filter(s => s.thread != 1 and s.points.len() > 0).map(item => (
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

  let ratio_values = series.map(s => s.points.map(p => p.at(1))).flatten().filter(value => value != none)
  let y_min = 1
  let y_max_data = if ratio_values.len() == 0 { 2 } else { max_value(ratio_values) * 1.1 }
  let y_max = if y_max_data <= y_min { y_min + 1 } else { y_max_data }

  let y_ticks = (1, 1.25, 1.5, 1.75, 2, 2.25, 2.5)

  plot.plot(
    size: (12, 7),
    x-min: 0.9,
    x-max: 105,
    x-ticks: time_mark_positions,
    x-tick-step: none,
    x-minor-tick-step: none,
    x-label: [Vykdymo laikas (%)],
    x-mode: "log",
    y-min: y_min - 0.1,
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
