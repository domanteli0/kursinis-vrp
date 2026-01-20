#import "@preview/fletcher:0.5.8" as f: diagram, node, edge
#set text(font: "palemonas")

#let box(
  pos,
  label,
  name: none,
  fill: white,
  width: 22mm,
  height: 12mm,
  radius: 4pt,
  stroke: 1pt + black,
  ..args,
) = node(
  pos,
  align(center, label),
  name: name,
  fill: fill,
  stroke: stroke,
  width: width,
  height: height,
  corner-radius: radius,
  ..args,
)

#let text_node(pos, label) = node(
  pos,
  label,
  stroke: none,
  fill: none,
  inset: 0pt,
)

#let parallel_hgs = diagram(
  spacing: 8pt,
  cell-size: (10mm, 10mm),
  edge-stroke: 1pt,
  edge-corner-radius: 4pt,
  mark-scale: 70%,
  {
    let gpu_dark = rgb("#3f7f2c")
    let gpu_fill = rgb("#5aa53b")
    let kernel_fill = rgb("#61a643")
    let thread_fill = rgb("#d6cce3")
    let node_fill = rgb("#2b8fcb")
    let main_fill = rgb("#a0192c")

    box((0, 1), text(fill: white)[Branduolys\ 1], name: <k1>, fill: kernel_fill, stroke: 1pt + gpu_dark, width: 26mm, height: 12mm, radius: 3pt)
    text_node((0.75, 1), [...])
    box((1.5, 1), text(fill: white)[Branduolys\ 9], name: <k2>, fill: kernel_fill, stroke: 1pt + gpu_dark, width: 26mm, height: 12mm, radius: 3pt)
    box((3, 1), text(fill: white)[Branduolys\ 1], name: <k3>, fill: kernel_fill, stroke: 1pt + gpu_dark, width: 26mm, height: 12mm, radius: 3pt)
    text_node((3.75, 1), [...])
    box((4.6, 1), text(fill: white)[Branduolys\ 9], name: <k4>, fill: kernel_fill, stroke: 1pt + gpu_dark, width: 26mm, height: 12mm, radius: 3pt)

    box((2.3, 0.25), text(fill: white)[GPU], name: <gpu_top_label>, fill: gpu_fill, stroke: 1pt + gpu_dark, width: 16mm, height: 7mm, radius: 3pt)
    node(
      [],
      name: <gpu_top>,
      enclose: (<k1>, <k4>),
      stroke: 1pt + black,
      fill: none,
      corner-radius: 6pt,
      inset: 6pt,
    )

    box((0, 3), [Gija\ 1], name: <t1>, fill: thread_fill, width: 20mm, height: 12mm)
    box((1.5, 3), [Gija\ 2], name: <t2>, fill: thread_fill, width: 20mm, height: 12mm)
    box((3, 3), [Gija\ 3], name: <t3>, fill: thread_fill, width: 20mm, height: 12mm)

    box((0, 5), text(fill: white)[Mazgas\ 1], name: <n1>, fill: node_fill, width: 22mm, height: 13mm)
    box((3, 5), text(fill: white)[Mazgas\ 2], name: <n2>, fill: node_fill, width: 22mm, height: 13mm)

    box((0, 7), text(fill: white)[Pagrindinis\ mazgas], name: <main>, fill: main_fill, width: 26mm, height: 16mm)
    box((2, 7), text(fill: white)[Mazgas\ 3], name: <n3>, fill: node_fill, width: 22mm, height: 13mm)

    box((0, 9), text(fill: white)[Mazgas\ X], name: <nx>, fill: node_fill, width: 22mm, height: 13mm)

    box((3.5, 7), [Gija\ 4], name: <t4a>, fill: thread_fill, width: 20mm, height: 12mm)
    box((2.5, 9), [Gija\ 4], name: <t4b>, fill: thread_fill, width: 20mm, height: 12mm)

    box((5.5, 7), text(fill: white)[Branduolys\ 1], name: <mk1>, fill: kernel_fill, stroke: 1pt + gpu_dark, width: 26mm, height: 12mm, radius: 3pt)
    text_node((6.5, 7), [...])
    box((7.5, 7), text(fill: white)[Branduolys\ 9], name: <mk2>, fill: kernel_fill, stroke: 1pt + gpu_dark, width: 26mm, height: 12mm, radius: 3pt)
    box((6.5, 6.3), text(fill: white)[GPU], name: <gpu_mid_label>, fill: gpu_fill, stroke: 1pt + gpu_dark, width: 16mm, height: 7mm, radius: 3pt)
    node(
      [],
      name: <gpu_mid>,
      enclose: (<mk1>, <mk2>),
      stroke: 1pt + black,
      fill: none,
      corner-radius: 6pt,
      inset: 6pt,
    )

    box((5, 9), text(fill: white)[Branduolys\ 1], name: <bk1>, fill: kernel_fill, stroke: 1pt + gpu_dark, width: 26mm, height: 12mm, radius: 3pt)
    text_node((6, 9), [...])
    box((7, 9), text(fill: white)[Branduolys\ 9], name: <bk2>, fill: kernel_fill, stroke: 1pt + gpu_dark, width: 26mm, height: 12mm, radius: 3pt)
    box((6, 8.25), text(fill: white)[GPU], name: <gpu_bot_label>, fill: gpu_fill, stroke: 1pt + gpu_dark, width: 16mm, height: 7mm, radius: 3pt)
    node(
      [],
      name: <gpu_bottom>,
      enclose: (<bk1>, <bk2>),
      stroke: 1pt + black,
      fill: none,
      corner-radius: 6pt,
      inset: 6pt,
    )

    edge(<t1>, <k1>, "<->")
    edge(<t2>, <k2>, "<->")
    edge(<t3>, <k3>, "<->")

    edge(<t1>, <n1>, "<->")
    edge(<n1>, <t2>, "->")
    edge(<t3>, <n2>, "<->", label: [MPI_Isend/MPI_Irecv], label-side: right)

    edge(<n1>, <main>, "<->")
    edge(<n1>, <n2>, "->")
    edge(<n2>, <main>, "->")

    edge(<main>, <n3>, "<->")
    edge(<n3>, <t4a>, "<->")
    edge(<t4a>, <mk1>, "<->")

    edge(<main>, <nx>, "<->")
    edge(<nx>, <t4b>, "<->")
    edge(<t4b>, <bk1>, "<->")
  }
)

#parallel_hgs
