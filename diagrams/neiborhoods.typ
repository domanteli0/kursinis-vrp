#import "@preview/cetz:0.4.2": canvas, draw
#import draw: line, content, circle

/// --- Styling (nodes a bit smaller) ---
#let V(pos, lab) = {
  circle(pos, radius: 3.2mm, stroke: 0.85pt, fill: luma(95%))
  content(pos, text(size: 4mm)[$#lab$], anchor: "center")
}
#let del(a, b) = line(a, b, stroke: (thickness: 1.1pt, dash: (2pt, 2pt)))
#let add(a, b) = line(a, b, stroke: 1.1pt)

/// --- Fixed sizing for layout independence ---
#let panel_w = 16mm
#let panel_h = 10mm
#let label_h = 4mm
#let title_h = 4mm
#let max_gutter = 5mm
#let op_w = 3 * panel_w + 2 * max_gutter
#let op_h = panel_h + label_h + title_h + 3mm

/// --- Panel label (fixed dimensions) ---
#let panel(label, body) = grid(
  columns: (panel_w,),
  rows: (panel_h, label_h),
  row-gutter: 1mm,
  align: center,
  block(width: panel_w, height: panel_h, align(center, scale(42%, body))),
  block(width: panel_w, height: label_h, align(center + bottom, text(size: 3mm, weight: "medium")[#label])),
)

/// --- Operator block: a/b/c horizontally (fixed width/height) ---
#let opblock(title, a, b, c, gutter: 0mm) = block(
  width: op_w,
  height: op_h,
  align(top + center, stack(
    spacing: 1mm,
    grid(
      columns: (panel_w, panel_w, panel_w),
      column-gutter: gutter,
      align: center,
      panel("1)", a),
      panel("2)", b),
      panel("3)", c),
    ),
    block(width: op_w, height: title_h, align(center + bottom, text(size: 3mm, title))),
  ))
)

/// --- Row helpers (fixed column widths) ---
#let row3(a, b, c) = grid(
  columns: (op_w, op_w, op_w),
  column-gutter: 5mm,
  align: top + center,
  a, b, c
)
#let row2(a, b) = grid(
  columns: (op_w, op_w),
  column-gutter: 5mm,
  align: top + center,
  a, b
)

/// --- Shared geometry ---
#let x = 1.4
#let y = 1.4

#let dx = 8.5mm
#let dy = 8.5mm

/// =====================
/// Diagrams
/// =====================

#let d2opt_a = canvas({
  let p(x, y) = (x * dx, -y * dy)

  add(p(0, 0), p(x, y))
  add(p(0, y), p(x, 0))
  V(p(0, 0), "A")
  V(p(x, 0), "B")
  V(p(0, y), "C")
  V(p(x, y), "D")
})

#let d2opt_b = canvas({
  let p(x, y) = (x * dx, -y * dy)

  del(p(0, 0), p(x, y))
  del(p(0, y), p(x, 0))
  add(p(0, 0), p(x, 0))
  add(p(0, y), p(x, y))
  V(p(0, 0), "A")
  V(p(x, 0), "B")
  V(p(0, y), "C")
  V(p(x, y), "D")
})

#let d2opt_c = canvas({
  let p(x, y) = (x * dx, -y * dy)

  add(p(0, 0), p(x, 0))
  add(p(0, y), p(x, y))
  V(p(0, 0), "A")
  V(p(x, 0), "B")
  V(p(0, y), "C")
  V(p(x, y), "D")
})

#let drel_a = canvas({
  let p(x, y) = (x * dx, -y * dy)

  add(p(0, 0), p(x, 0))
  add(p(x, 0), p(2 * x, 0))
  add(p(0, y), p(2 * x, y))

  V(p(0, 0), "A")
  V(p(x, 0), "X")
  V(p(2 * x, 0), "B")
  V(p(0, y), "C")
  V(p(2 * x, y), "D")
})

#let drel_b = canvas({
  let p(x, y) = (x * dx, -y * dy)

  del(p(0, 0), p(x, 0))
  del(p(x, 0), p(2 * x, 0))
  add(p(0, 0), p(2 * x, 0))
  del(p(0, y), p(2 * x, y))
  add(p(0, y), p(x, y))
  add(p(x, y), p(2 * x, y))

  V(p(0, 0), "A")
  V(p(x, 0), "X")
  V(p(2 * x, 0), "B")
  V(p(0, y), "C")
  V(p(x, y), "X")
  V(p(2 * x, y), "D")
})

#let drel_c = canvas({
  let p(x, y) = (x * dx, -y * dy)

  add(p(0, 0), p(2 * x, 0))
  add(p(0, y), p(x, y))
  add(p(x, y), p(2 * x, y))

  V(p(0, 0), "A")
  V(p(2 * x, 0), "B")
  V(p(0, y), "C")
  V(p(x, y), "X")
  V(p(2 * x, y), "D")
})

#let dsw_a = canvas({
  let p(x, y) = (x * dx, -y * dy)

  add(p(0, 0), p(x, 0))
  add(p(x, 0), p(2 * x, 0))
  add(p(0, y), p(x, y))
  add(p(x, y), p(2 * x, y))

  V(p(0, 0), "A")
  V(p(x, 0), "X")
  V(p(2 * x, 0), "B")
  V(p(0, y), "C")
  V(p(x, y), "Y")
  V(p(2 * x, y), "D")
})

#let dsw_b = canvas({
  let p(x, y) = (x * dx, -y * dy)

  del(p(0, 0), p(x, 0))
  del(p(x, 0), p(2 * x, 0))
  del(p(0, y), p(x, y))
  del(p(x, y), p(2 * x, y))
  add(p(0, 0), p(x, y))
  add(p(x, y), p(2 * x, 0))
  add(p(0, y), p(x, 0))
  add(p(x, 0), p(2 * x, y))

  V(p(0, 0), "A")
  V(p(x, 0), "X")
  V(p(2 * x, 0), "B")
  V(p(0, y), "C")
  V(p(x, y), "Y")
  V(p(2 * x, y), "D")
})

#let dsw_c = canvas({
  let p(x, y) = (x * dx, -y * dy)

  add(p(0, 0), p(x, 0))
  add(p(x, 0), p(2 * x, 0))
  add(p(0, y), p(x, y))
  add(p(x, y), p(2 * x, y))

  V(p(0, 0), "A")
  V(p(x, 0), "Y")
  V(p(2 * x, 0), "B")
  V(p(0, y), "C")
  V(p(x, y), "X")
  V(p(2 * x, y), "D")
})

#let dss_a = dsw_a

#let dss_b = canvas({
  let p(x, y) = (x * dx, -y * dy)

  del(p(0, 0), p(x, 0))
  del(p(x, 0), p(2 * x, 0))
  del(p(0, y), p(x, y))
  del(p(x, y), p(2 * x, y))
  add(p(0, 0), p(2 * x, 0))
  add(p(2 * x, 0), p(x, y))
  add(p(0, y), p(x, 0))
  add(p(x, 0), p(2 * x, y))

  V(p(0, 0), "A")
  V(p(x, 0), "X")
  V(p(2 * x, 0), "B")
  V(p(0, y), "C")
  V(p(x, y), "Y")
  V(p(2 * x, y), "D")
})

#let dss_c = canvas({
  let p(x, y) = (x * dx, -y * dy)

  add(p(0, 0), p(x, 0))
  add(p(x, 0), p(2 * x, 0))
  add(p(0, y), p(x, y))
  add(p(x, y), p(2 * x, y))

  V(p(0, 0), "A")
  V(p(x, 0), "B")
  V(p(2 * x, 0), "Y")
  V(p(0, y), "C")
  V(p(x, y), "X")
  V(p(2 * x, y), "D")
})

#let neiborhoods = [
  #row2(
    opblock([2-opt], d2opt_a, d2opt_b, d2opt_c),
    opblock([Relocate], drel_a, drel_b, drel_c),
  )

  #v(0.5em)

  #row2(
    opblock([Swap], dsw_a, dsw_b, dsw_c),
    opblock([Swap\*], dss_a, dss_b, dss_c),
  )
]
