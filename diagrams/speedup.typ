#import "../data.typ": read_raw_instance, time_to_match_from_raw, POWERS, format_2
#import "@preview/cetz-plot:0.1.3": plot, chart,
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

  let points = range(0, speedup_data.threads.len())
    .map(i => { (speedup_data.threads.at(i), speedup_data.average.at(i)) })

  let y_max = calc.max(..speedup_data.average)
  let y_ticks = range(1, calc.ceil(y_max) + 2).map(i => float(i))

  plot.plot(
    size: (12, 8),
    x-min: 1.65,
    x-max: 18,
    x-ticks: speedup_data.threads,
    x-tick-step: none,
    x-label: [Gijų skaičius],
    x-mode: "log",
    x-base: 2,
    y-min: 1,
    y-max: 5.2,
    y-label: [Vidutinis pagreitėjimas],
    y-ticks: (0, 1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5, 5.5, 6),
    y-tick-step: none,
    y-grid: "major",
    y-format: format_2,
    legend: "north",
    {
      plot.add(points, line: "linear", style: (stroke: black))
      plot.add(
        ((2, 1.754), (4, 2.816), (8, 4.040), (16, 5.161)),
        style: (stroke: black),
        label: "Teorinis pagreitėjimas",
        line: "linear"
      )

        plot.add(
          points,
          label: "Tikrasis pagreitėjimas",
          mark: "o", mark-size: tick_mark_size, mark-style: (stroke: black, fill: white),
          style: (stroke: (paint: black, dash: (0.5em, 0.2em))),
        )
    },
  )

  let points2 = range(0, speedup_data.threads.len())
    .map(i => { ([#speedup_data.threads.at(i)], speedup_data.average.at(i)) })

  //   draw.set-style(legend: (fill: white), barchart: (bar-width: .8, cluster-gap: 0))
  //   chart.barchart(
  //     size: (12, 9),
  //     bar-style: (fill: white.darken(10%), width: .1, stroke: (paint: black)),
  //     points2,
  //     y-label: [Gijų skaičius],
  //     x-label: [Pagreitėjimas],
  //     legend: none,
  //   )
})

// Function to plot average efficiency
#let plot_average_efficiency(speedup_data) = canvas({
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

  let points = range(0, speedup_data.threads.len())
    .map(i => { (speedup_data.threads.at(i), speedup_data.average.at(i) / speedup_data.threads.at(i)) })

  let y_max = calc.max(..points.map(p => p.at(1))) * 1.1

  plot.plot(
    size: (12, 8),
    x-min: 1.65,
    x-max: 18,
    x-ticks: speedup_data.threads,
    x-tick-step: none,
    x-label: [Gijų skaičius],
    x-mode: "log",
    x-base: 2,
    y-min: 0,
    y-max: 1.5,
    y-label: [Vidutinis efektyvumas],
    y-tick-step: none,
    y-grid: "major",
    y-format: format_2,
    legend: "north",
    {
      plot.add(points, line: "linear", style: (stroke: black))
      
      // Theoretical efficiency (Amdahl's law with f=0.86)
      // S_p = 1 / ((1-f) + f/p)
      // E_p = S_p / p
      let amdahl_f = 0.86
      let amdahl_eff = p => (1.0 / ((1.0 - amdahl_f) + amdahl_f / p)) / p
      let theoretical_points = speedup_data.threads.map(t => (t, amdahl_eff(t)))
      
      plot.add(
        theoretical_points,
        style: (stroke: black),
        label: "Teorinis efektyvumas",
        line: "linear"
      )

      plot.add(
        points,
        label: "Tikrasis efektyvumas",
        mark: "o", mark-size: tick_mark_size, mark-style: (stroke: black, fill: white),
        style: (stroke: (paint: black, dash: (0.5em, 0.2em))),
      )
    },
  )
})
