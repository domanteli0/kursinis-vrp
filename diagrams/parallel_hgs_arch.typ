#import "@preview/cetz:0.4.2": canvas, draw
#import draw: rect, line, content
#set text(font: "palemonas")

#let parallel_hgs_diagram = canvas({
  let gx = 26mm
  let gy = 14mm
  let coord(x, y) = (x * gx, -y * gy)

  let box(center, size, label, name: none, fill: white, stroke: 1pt + black, radius: 4pt) = {
    let (w, h) = size
    let (x, y) = center
    rect(
      (x - w / 2, y - h / 2),
      (x + w / 2, y + h / 2),
      name: name,
      fill: fill,
      stroke: stroke,
      radius: radius,
    )
    content((x, y), label, anchor: "center")
  }

  let label_only(center, label) = content(center, label)

  let arrow(a, b, both: false) = line(
    a,
    b,
    mark: if both { (start: "stealth", end: "stealth", scale: 0.8) } else { (end: "stealth", scale: 0.8) },
  )

  let gpu_dark = rgb("#3f7f2c")
  let gpu_fill = rgb("#5aa53b")
  let kernel_fill = rgb("#61a643")
  let thread_fill = rgb("#d6cce3")
  let node_fill = rgb("#2b8fcb")
  let main_fill = rgb("#a0192c")

  // Top GPU kernels
  box(coord(0, 1), (26mm, 12mm), text(fill: white)[Branduolys\ 1], name: "k1", fill: kernel_fill, stroke: 1pt + gpu_dark, radius: 3pt)
  label_only(coord(0.75, 1), [...])
  box(coord(1.5, 1), (26mm, 12mm), text(fill: white)[Branduolys\ 9], name: "k2", fill: kernel_fill, stroke: 1pt + gpu_dark, radius: 3pt)
  box(coord(3, 1), (26mm, 12mm), text(fill: white)[Branduolys\ 1], name: "k3", fill: kernel_fill, stroke: 1pt + gpu_dark, radius: 3pt)
  label_only(coord(3.75, 1), [...])
  box(coord(4.6, 1), (26mm, 12mm), text(fill: white)[Branduolys\ 9], name: "k4", fill: kernel_fill, stroke: 1pt + gpu_dark, radius: 3pt)

  box(coord(2.3, 0.25), (16mm, 7mm), text(fill: white)[GPU], name: "gpu_top_label", fill: gpu_fill, stroke: 1pt + gpu_dark, radius: 3pt)
  let (gpu_top_left_x, gpu_top_top_y) = coord(-0.4, 0.35)
  let (gpu_top_right_x, gpu_top_bottom_y) = coord(5.0, 1.65)
  rect((gpu_top_left_x, gpu_top_bottom_y), (gpu_top_right_x, gpu_top_top_y), stroke: 1pt + black, fill: none, radius: 6pt, name: "gpu_top")

  // Threads
  box(coord(0, 3), (20mm, 12mm), [Gija\ 1], name: "t1", fill: thread_fill)
  box(coord(1.5, 3), (20mm, 12mm), [Gija\ 2], name: "t2", fill: thread_fill)
  box(coord(3, 3), (20mm, 12mm), [Gija\ 3], name: "t3", fill: thread_fill)

  // Nodes
  box(coord(0, 5), (22mm, 13mm), text(fill: white)[Mazgas\ 1], name: "n1", fill: node_fill)
  box(coord(3, 5), (22mm, 13mm), text(fill: white)[Mazgas\ 2], name: "n2", fill: node_fill)

  // Main and additional nodes
  box(coord(0, 7), (26mm, 16mm), text(fill: white)[Pagrindinis\ mazgas], name: "main", fill: main_fill)
  box(coord(2, 7), (22mm, 13mm), text(fill: white)[Mazgas\ 3], name: "n3", fill: node_fill)
  box(coord(0, 9), (22mm, 13mm), text(fill: white)[Mazgas\ X], name: "nx", fill: node_fill)

  // Additional thread and GPU blocks
  box(coord(3.5, 7), (20mm, 12mm), [Gija\ 4], name: "t4a", fill: thread_fill)
  box(coord(2.5, 9), (20mm, 12mm), [Gija\ 4], name: "t4b", fill: thread_fill)

  box(coord(5.5, 7), (26mm, 12mm), text(fill: white)[Branduolys\ 1], name: "mk1", fill: kernel_fill, stroke: 1pt + gpu_dark, radius: 3pt)
  label_only(coord(6.5, 7), [...])
  box(coord(7.5, 7), (26mm, 12mm), text(fill: white)[Branduolys\ 9], name: "mk2", fill: kernel_fill, stroke: 1pt + gpu_dark, radius: 3pt)
  box(coord(6.5, 6.3), (16mm, 7mm), text(fill: white)[GPU], name: "gpu_mid_label", fill: gpu_fill, stroke: 1pt + gpu_dark, radius: 3pt)
  let (gpu_mid_left_x, gpu_mid_top_y) = coord(4.9, 6.45)
  let (gpu_mid_right_x, gpu_mid_bottom_y) = coord(8.2, 7.6)
  rect((gpu_mid_left_x, gpu_mid_bottom_y), (gpu_mid_right_x, gpu_mid_top_y), stroke: 1pt + black, fill: none, radius: 6pt, name: "gpu_mid")

  box(coord(5, 9), (26mm, 12mm), text(fill: white)[Branduolys\ 1], name: "bk1", fill: kernel_fill, stroke: 1pt + gpu_dark, radius: 3pt)
  label_only(coord(6, 9), [...])
  box(coord(7, 9), (26mm, 12mm), text(fill: white)[Branduolys\ 9], name: "bk2", fill: kernel_fill, stroke: 1pt + gpu_dark, radius: 3pt)
  box(coord(6, 8.25), (16mm, 7mm), text(fill: white)[GPU], name: "gpu_bot_label", fill: gpu_fill, stroke: 1pt + gpu_dark, radius: 3pt)
  let (gpu_bot_left_x, gpu_bot_top_y) = coord(4.6, 8.4)
  let (gpu_bot_right_x, gpu_bot_bottom_y) = coord(7.9, 9.55)
  rect((gpu_bot_left_x, gpu_bot_bottom_y), (gpu_bot_right_x, gpu_bot_top_y), stroke: 1pt + black, fill: none, radius: 6pt, name: "gpu_bottom")

  // Connections
  arrow("t1", "k1", both: true)
  arrow("t2", "k2", both: true)
  arrow("t3", "k3", both: true)

  arrow("t1", "n1", both: true)
  arrow("n1", "t2")
  arrow("t3", "n2", both: true)
  let (t3_x, t3_y) = coord(3, 3)
  let (n2_x, n2_y) = coord(3, 5)
  content(((t3_x + n2_x) / 2 + 10mm, (t3_y + n2_y) / 2), text(size: 8pt)[MPI_Isend/MPI_Irecv])

  arrow("n1", "main", both: true)
  arrow("n1", "n2")
  arrow("n2", "main")

  arrow("main", "n3", both: true)
  arrow("n3", "t4a", both: true)
  arrow("t4a", "mk1", both: true)

  arrow("main", "nx", both: true)
  arrow("nx", "t4b", both: true)
  arrow("t4b", "bk1", both: true)
})

#parallel_hgs_diagram
