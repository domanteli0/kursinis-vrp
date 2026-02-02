#import "@preview/cetz:0.4.2": canvas, draw
#import "@preview/cetz-plot:0.1.3": plot
#import "../data.typ": format_2, max_value
#import "../data_gap.typ": thread_time_marks

#let threshold_style(index) = {
  if index == 0 {
    (stroke: (paint: black, thickness: 1pt))
  } else if index == 1 {
    (stroke: (paint: black, thickness: 1pt, dash: (4pt, 2pt)))
  } else if index == 2 {
    (stroke: (paint: black, thickness: 1pt, dash: (2pt, 2pt)))
  } else {
    (stroke: (paint: black, thickness: 1pt))
  }
}

#let threshold_label(g) = "g* = " + format_2(g) + "%"

#let speedup_threshold_plot_from(data) = canvas({
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

  let series = data.series
  let values = series.map(s => s.values.map(v => v.speedup)).flatten().filter(v => v != none)
  let y_max_data = if values.len() == 0 { 2 } else { max_value(values) * 1.15 }
  let y_max = if y_max_data < 1.2 { 1.2 } else { y_max_data }

  plot.plot(
    size: (11, 6),
    x-min: 0,
    x-max: 17,
    x-ticks: thread_time_marks,
    x-label: [Gijų skaičius],
    y-min: 0.8,
    y-max: y_max,
    y-label: [Greitėjimas $S_p$],
    y-format: format_2,
    y-grid: "major",
    legend: "north",
    {
      for item in series.enumerate() {
        let idx = item.at(0)
        let entry = item.at(1)
        let points = entry.values.map(v => (v.thread, v.speedup)).filter(p => p.at(1) != none)
        plot.add(points, line: "spline", label: none, style: threshold_style(idx))
        plot.add-legend(threshold_label(entry.g), preview: () => {
          import draw: *
          line((0, 0.5), (1, 0.5), ..threshold_style(idx))
        })
      }
    },
  )
})
