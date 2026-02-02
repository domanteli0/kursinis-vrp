#import "@preview/cetz:0.4.2": canvas, draw
#import draw: rect, line, content, polygon
#set text(font: "palemonas")

#let island_model = canvas({
  let gx = 30mm
  let gy = 12mm

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

  let arrow(a, b, dashed: false) = {
    let stroke_style = if dashed { (thickness: 1pt, dash: (2pt, 2pt)) } else { (thickness: 1pt) }
    line(a, b, stroke: stroke_style, mark: (end: "stealth", scale: 0.8))
  }

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

  let init = coord(x_center, 0)
  box(
    init,
    (60mm, 18mm),
    text(size: 14pt)[Inicializuoti salų\ parametrus],
    name: "init",
    fill: init_fill,
  )

  let label_y = 1
  content(coord(x1, label_y), [Sala 1])
  content(coord(x2, label_y), [Sala 2])
  content(coord(x3, label_y), [Sala n-1])
  content(coord(x4, label_y), [Sala n])

  let hgs_y = 2
  box(coord(x1, hgs_y), (26mm, 14mm), [HGS], name: "hgs1", fill: hgs_fill)
  box(coord(x2, hgs_y), (26mm, 14mm), [HGS], name: "hgs2", fill: hgs_fill)
  box(coord(x3, hgs_y), (26mm, 14mm), [HGS], name: "hgs3", fill: hgs_fill)
  box(coord(x4, hgs_y), (26mm, 14mm), [HGS], name: "hgs4", fill: hgs_fill)

  let mig_y = 4
  box(coord(x1, mig_y), (32mm, 18mm), [Migracijos\ valdiklis], name: "mig1", fill: mig_fill)
  box(coord(x2, mig_y), (32mm, 18mm), [Migracijos\ valdiklis], name: "mig2", fill: mig_fill)
  box(coord(x3, mig_y), (32mm, 18mm), [Migracijos\ valdiklis], name: "mig3", fill: mig_fill)
  box(coord(x4, mig_y), (32mm, 18mm), [Migracijos\ valdiklis], name: "mig4", fill: mig_fill)

  let exch_y = 6
  let exch_center = coord(x_center, exch_y)
  let exch_size = (120mm, 18mm)
  box(
    exch_center,
    exch_size,
    [Sprendinių apsikeitimas tarp salų \ pagal migracijos planą],
    name: "exchange",
    fill: exchange_fill,
    stroke: (paint: green.darken(20%), thickness: 1pt, dash: (2pt, 2pt)),
  )

  let stop_y = 8
  let stop_radius = 9mm
  polygon(coord(x1, stop_y), 4, angle: 45deg, radius: stop_radius, name: "stop1", fill: stop_fill, stroke: 1pt + black)
  polygon(coord(x2, stop_y), 4, angle: 45deg, radius: stop_radius, name: "stop2", fill: stop_fill, stroke: 1pt + black)
  polygon(coord(x3, stop_y), 4, angle: 45deg, radius: stop_radius, name: "stop3", fill: stop_fill, stroke: 1pt + black)
  polygon(coord(x4, stop_y), 4, angle: 45deg, radius: stop_radius, name: "stop4", fill: stop_fill, stroke: 1pt + black)

  content(coord(x1, stop_y), text(size: 9pt)[Vykdymas\ baigtas?])
  content(coord(x2, stop_y), text(size: 9pt)[Vykdymas\ baigtas?])
  content(coord(x3, stop_y), text(size: 9pt)[Vykdymas\ baigtas?])
  content(coord(x4, stop_y), text(size: 9pt)[Vykdymas\ baigtas?])

  let output_center = coord(x_center, 10)
  box(
    output_center,
    (140mm, 18mm),
    [Surinkti geriausius sprendinius ir\ grąžinti geriausią],
    name: "output",
    fill: output_fill,
  )

  // Enclosures for each island
  let pad = 6mm
  let hgs_box_h = 14mm
  let stop_box_h = stop_radius * 2
  for x in (x1, x2, x3, x4) {
    let (cx, hgs_y_pos) = coord(x, hgs_y)
    let (_, stop_y_pos) = coord(x, stop_y)
    let top = hgs_y_pos + hgs_box_h / 2 + pad
    let bottom = stop_y_pos - stop_box_h / 2 - pad
    let left = cx - 20mm
    let right = cx + 20mm
    rect((left, bottom), (right, top), stroke: 1pt + red, fill: none, radius: 6pt)
  }

  // Flow arrows
  arrow("init", "hgs1")
  arrow("init", "hgs2")
  arrow("init", "hgs3")
  arrow("init", "hgs4")

  arrow("hgs1", "mig1")
  arrow("hgs2", "mig2")
  arrow("hgs3", "mig3")
  arrow("hgs4", "mig4")

  arrow("mig1", "exchange")
  arrow("mig2", "exchange")
  arrow("mig3", "exchange")
  arrow("mig4", "exchange")

  arrow("exchange", "stop1")
  arrow("exchange", "stop2")
  arrow("exchange", "stop3")
  arrow("exchange", "stop4")

  arrow("stop1", "output")
  arrow("stop2", "output")
  arrow("stop3", "output")
  arrow("stop4", "output")

  // No branch back to HGS
  let (stop1_x, stop1_y) = coord(x1, stop_y)
  let (stop2_x, stop2_y) = coord(x2, stop_y)
  let (stop3_x, stop3_y) = coord(x3, stop_y)
  let (stop4_x, stop4_y) = coord(x4, stop_y)

  let (_, hgs1_y) = coord(x1, hgs_y)
  let (_, hgs2_y) = coord(x2, hgs_y)
  let (_, hgs3_y) = coord(x3, hgs_y)
  let (_, hgs4_y) = coord(x4, hgs_y)

  arrow((stop1_x - 14mm, stop1_y), (stop1_x - 14mm, hgs1_y + 6mm), dashed: true)
  arrow((stop2_x - 12mm, stop2_y), (stop2_x - 12mm, hgs2_y + 6mm), dashed: true)
  arrow((stop3_x - 12mm, stop3_y), (stop3_x - 12mm, hgs3_y + 6mm), dashed: true)
  arrow((stop4_x - 12mm, stop4_y), (stop4_x - 12mm, hgs4_y + 6mm), dashed: true)

  content((stop1_x + 8mm, stop1_y - 6mm), text(size: 8pt)[Taip], anchor: "south")
  content((stop2_x + 8mm, stop2_y - 6mm), text(size: 8pt)[Taip], anchor: "south")
  content((stop3_x + 8mm, stop3_y - 6mm), text(size: 8pt)[Taip], anchor: "south")
  content((stop4_x + 8mm, stop4_y - 6mm), text(size: 8pt)[Taip], anchor: "south")

  content((stop1_x - 18mm, stop1_y + 6mm), text(size: 8pt)[Ne], anchor: "north")
  content((stop2_x - 16mm, stop2_y + 6mm), text(size: 8pt)[Ne], anchor: "north")
  content((stop3_x - 16mm, stop3_y + 6mm), text(size: 8pt)[Ne], anchor: "north")
  content((stop4_x - 16mm, stop4_y + 6mm), text(size: 8pt)[Ne], anchor: "north")
})

#island_model
