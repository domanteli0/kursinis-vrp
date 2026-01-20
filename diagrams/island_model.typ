#import "@preview/fletcher:0.5.8" as f: diagram, node, edge
#import f.shapes: diamond
#set text(font: "palemonas")

#let box(
  pos,
  label,
  name: none,
  fill: white,
  width: 26mm,
  height: 14mm,
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

#let label_node(pos, label) = node(
  pos,
  label,
  stroke: none,
  fill: none,
  inset: 0pt,
)

#let island_model = diagram(
  spacing: 8pt,
  cell-size: (10mm, 10mm),
  edge-stroke: 1pt,
  edge-corner-radius: 4pt,
  mark-scale: 70%,
  {
    let hgs_fill = rgb("#f6e7d5")
    let mig_fill = rgb("#dff2d6")
    let init_fill = rgb("#d9e7ff")
    let exchange_fill = rgb("#cdf5c7")
    let stop_fill = rgb("#f6c5c5")
    let output_fill = rgb("#d8d5f3")

    let x1 = 0
    let x2 = 1
    let x3 = 2
    let x4 = 3
    let x_center = 1.5

    node(
      [],
      name: <island1>,
      enclose: (<hgs1>, <stop1>),
      stroke: 1pt + red,
      fill: none,
      corner-radius: 6pt,
      inset: 6pt,
    )
    node(
      [],
      name: <island2>,
      enclose: (<hgs2>, <stop2>),
      stroke: 1pt + red,
      fill: none,
      corner-radius: 6pt,
      inset: 6pt,
    )
    node(
      [],
      name: <island3>,
      enclose: (<hgs3>, <stop3>),
      stroke: 1pt + red,
      fill: none,
      corner-radius: 6pt,
      inset: 6pt,
    )
    node(
      [],
      name: <island4>,
      enclose: (<hgs4>, <stop4>),
      stroke: 1pt + red,
      fill: none,
      corner-radius: 6pt,
      inset: 6pt,
    )

    box(
      (x_center, 0),
      text(size: 14pt)[Inicializuoti salų\ parametrus],
      name: <init>,
      fill: init_fill,
      width: 52mm,
      height: 16mm,
    )

    label_node((x1, 1), [Sala 1])
    label_node((x2, 1), [Sala 2])
    label_node((x3, 1), [Sala n-1])
    label_node((x4, 1), [Sala n])

    box((x1, 2), [HGS], name: <hgs1>, fill: hgs_fill)
    box((x2, 2), [HGS], name: <hgs2>, fill: hgs_fill)
    box((x3, 2), [HGS], name: <hgs3>, fill: hgs_fill)
    box((x4, 2), [HGS], name: <hgs4>, fill: hgs_fill)

    box(
      (x1, 4),
      [Migracijos\ valdiklis],
      name: <mig1>,
      fill: mig_fill,
      width: 32mm,
      height: 18mm,
    )
    edge((<exchange.east>, 93.5%, <exchange.west>), "->")

    box(
      (x2, 4),
      [Migracijos\ valdiklis],
      name: <mig2>,
      fill: mig_fill,
      width: 32mm,
      height: 18mm,
    )
    edge((<exchange.east>, 64.7%, <exchange.west>), "->")

    box(
      (x3, 4),
      [Migracijos\ valdiklis],
      name: <mig3>,
      fill: mig_fill,
      width: 32mm,
      height: 18mm,
    )
    edge((<exchange.east>, 35.3%, <exchange.west>), "->")

    box(
      (x4, 4),
      [Migracijos\ valdiklis],
      name: <mig4>,
      fill: mig_fill,
      width: 32mm,
      height: 18mm,
    )
    edge((<exchange.east>, 6.15%, <exchange.west>), "->")

    node(
      (x1, 8),
      align(center, text(size: 9pt)[Vykdymas\ baigtas?]),
      name: <stop1>,
      shape: diamond,
      fill: stop_fill,
      stroke: 1pt + black,
      width: 18mm,
      height: 18mm,
    )
    node(
      (x2, 8),
      align(center, text(size: 9pt)[Vykdymas\ baigtas?]),
      name: <stop2>,
      shape: diamond,
      fill: stop_fill,
      stroke: 1pt + black,
      width: 18mm,
      height: 18mm,
    )
    node(
      (x3, 8),
      align(center, text(size: 9pt)[Vykdymas\ baigtas?]),
      name: <stop3>,
      shape: diamond,
      fill: stop_fill,
      stroke: 1pt + black,
      width: 18mm,
      height: 18mm,
    )
    node(
      (x4, 8),
      align(center, text(size: 9pt)[Vykdymas\ baigtas?]),
      name: <stop4>,
      shape: diamond,
      fill: stop_fill,
      stroke: 1pt + black,
      width: 18mm,
      height: 18mm,
    )

    node(
      [Surinkti geriausius sprendinius ir\ grąžinti geriausią],
      name: <output>,
      enclose: ((x1 - 1, 10), (x4 + 1, 10)),
      fill: output_fill,
      stroke: 1pt + black,
      corner-radius: 4pt,
      inset: 4pt,
      layer: 1,
    )

    edge(<init>, <hgs1>, "->")
    edge(<init>, <hgs2>, "->")
    edge(<init>, <hgs3>, "->")
    edge(<init>, <hgs4>, "->")

    // edge(<mig1>, <exchange>, "->")
    // edge(<mig2>, <exchange>, "->")
    // edge(<mig3>, <exchange>, "->")
    // edge(<mig4>, <exchange>, "->")

    // edge(<exchange>, <stop1>, "->")
    // edge(<exchange>, <stop2>, "->")
    // edge(<exchange>, <stop3>, "->")
    // edge(<exchange>, <stop4>, "->")

    edge(<stop1>, (rel: (0.5, 0)), "dd", "->", label: [Taip], label-pos: 0.65, label-side: right)
    edge(<stop2>, (rel: (0.5, 0)), "dd", "->", label: [Taip], label-pos: 0.65, label-side: right)
    edge(<stop3>, (rel: (0.5, 0)), "dd", "->", label: [Taip], label-pos: 0.65, label-side: right)
    edge(<stop4>, (rel: (0.75, 0)), "dd", "->", label: [Taip], label-pos: 0.65, label-side: right)

    edge(<stop1>, (rel: (-0.7, 0)),  "uuuuuu", <hgs1>, "-->", label: [Ne], label-pos: -0.3, label-sep: 1em, label-side: right)
    edge(<stop2>, (rel: (-0.47, 0)), "uuuuuu", <hgs2>, "-->", label: [Ne], label-pos: -0.4, label-sep: 1em, label-side: right)
    edge(<stop3>, (rel: (-0.47, 0)),  "uuuuuu", <hgs3>, "-->", label: [Ne], label-pos: -0.5, label-sep: 1em, label-side: right)
    edge(<stop4>, (rel: (-0.45, 0)), "uuuuuu", <hgs4>, "-->", label: [Ne], label-pos: -0.6, label-sep: 1em, label-side: right)

    node(
      [Sprendinių apsikeitimas tarp salų \ pagal migracijos planą],
      name: <exchange>,
      enclose: ((x1 - 0.25, 6), (x4 + 0.25, 6)),
      stroke: (paint: green.darken(20%), thickness: 1pt, dash: (2pt, 2pt)),
      fill: exchange_fill,
      corner-radius: 4pt,
      inset: 4pt,
      layer: 1,
    )

    edge((<exchange.east>, 6.5%, <exchange.west>), "dd", "->")
    edge((<exchange.east>, 35.3%, <exchange.west>), "dd", "->")
    edge((<exchange.east>, 64.7%, <exchange.west>), "dd", "->")
    edge((<exchange.east>, 93.5%, <exchange.west>), "dd", "->")
  }
)

#island_model
