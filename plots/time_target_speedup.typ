#import "@preview/cetz:0.4.2": canvas, draw
#import "@preview/cetz-plot:0.1.3": plot
#import "../data.typ": format_2, max_value
#import "../data_gap.typ": thread_time_marks

#let thread_mark(thread) = {
  if thread == 1 { "o" }
  else if thread == 2 { "square" }
  else if thread == 4 { "triangle" }
  else if thread == 8 { "x" }
  else if thread == 16 { "+" }
  else { "*" }
}

#let tick_mark_size = 0.3

#let speedup_plot_from(data) = canvas({
  import draw: *

  set-style(
    axes: (stroke: .5pt, tick: (stroke: .5pt)),
  )

  let series = data.series
  let values = series.map(s => s.speedup).filter(v => v != none)
  let y_max_data = if values.len() == 0 { 2 } else { max_value(values) * 1.15 }
  let y_max = if y_max_data < 1.2 { 1.2 } else { y_max_data }

  plot.plot(
    size: (11, 6),
    x-min: 0.5,
    x-max: 16.5,
    x-ticks: thread_time_marks,
    x-label: [Gijų skaičius],
    y-min: 0.8,
    y-max: y_max,
    y-label: [Greitėjimas $S_p$],
    y-format: format_2,
    y-grid: "major",
    {
      let points = series.map(s => (s.thread, s.speedup)).filter(p => p.at(1) != none)
      plot.add(points, line: "spline", label: none, style: (stroke: black))
      for p in points {
        plot.add((p,), mark: thread_mark(p.at(0)), mark-size: tick_mark_size, label: none, style: (stroke: none), mark-style: (stroke: black, fill: white))
      }
    },
  )
})

#let efficiency_plot_from(data) = canvas({
  import draw: *

  set-style(
    axes: (stroke: .5pt, tick: (stroke: .5pt)),
  )

  let series = data.series
  let values = series.map(s => s.efficiency).filter(v => v != none)
  let y_max_data = if values.len() == 0 { 1 } else { max_value(values) * 1.15 }
  let y_max = if y_max_data < 1.0 { 1.0 } else { y_max_data }

  plot.plot(
    size: (11, 6),
    x-min: 0.5,
    x-max: 16.5,
    x-ticks: thread_time_marks,
    x-label: [Gijų skaičius],
    y-min: 0,
    y-max: y_max,
    y-label: [Efektyvumas $E_p$],
    y-format: format_2,
    y-grid: "major",
    {
      let points = series.map(s => (s.thread, s.efficiency)).filter(p => p.at(1) != none)
      plot.add(points, line: "spline", label: none, style: (stroke: black))
      for p in points {
        plot.add((p,), mark: thread_mark(p.at(0)), mark-size: tick_mark_size, label: none, style: (stroke: none), mark-style: (stroke: black, fill: white))
      }
    },
  )
})
