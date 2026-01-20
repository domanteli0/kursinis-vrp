#import "../data.typ": read_raw_instance, time_to_match_from_raw, POWERS, format_2
#import "@preview/cetz-plot:0.1.3": plot
#import "@preview/cetz:0.4.2": canvas, draw
#import "gap_threads.typ": thread_style, thread_mark, thread_label, legend_preview, tick_mark_size, draw_mark_shape

// Function to calculate speedups
#let calculate_all_speedups(instances) = {
  let sequential_time = 100.0
  let thread_counts = POWERS.slice(1) // (2, 4, 8, 16)

  let raw_results = instances.map(instance => { // `instance` is the string name
    let raw_data = read_raw_instance(instance) // read raw data for this instance
    let time_to_match = time_to_match_from_raw(raw_data)

    let speedups = time_to_match.map(entry => {
      if entry.time_step == none or entry.time_step == 0 {
        1.0 // No speedup if target not met or if it is met at time 0
      } else {
        sequential_time / entry.time_step
      }
    })

    (
      instance_name: instance, // Use the instance name string here
      speedups: speedups,
    )
  })

  let average_speedups = thread_counts.map(thread => {
    let thread_index = int((calc.log(thread) / calc.log(2)) - 1)
    let total_speedup = raw_results.map(res => res.speedups.at(thread_index)).sum()
    total_speedup / raw_results.len()
  })

  (
    raw: raw_results,
    average: average_speedups,
    threads: thread_counts,
  )
}

// Function to plot average speedup
#let plot_average_speedup(speedup_data) = canvas({
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

  let points = ()
  for i in range(0, speedup_data.threads.len()) {
    points.push((speedup_data.threads.at(i), speedup_data.average.at(i)))
  }

  let y_max = calc.max(..speedup_data.average)
  // let y_ticks = range(1, calc.ceil(y_max) + 2).map(i => float(i))

  plot.plot(
    size: (12, 9),
    x-min: 1.75,
    x-max: 18,
    x-ticks: speedup_data.threads,
    x-tick-step: none,
    x-label: [Gijų skaičius],
    x-mode: "log",
    x-base: 2,
    y-min: 0,
    y-max: y_max * 1.1,
    y-label: [Vidutinis pagreitėjimas],
    y-ticks: (2, 3, 4, 5, 6, 7),
    y-tick-step: none,
    y-grid: "major",
    y-format: format_2,
    legend: none,
    {
      plot.add(points, line: "linear", style: (stroke: black))

      for p in points {
          plot.add((p,), mark: "o", mark-size: tick_mark_size, style: (stroke:none), mark-style: (stroke: black, fill: white))
      }
    },
  )
})
