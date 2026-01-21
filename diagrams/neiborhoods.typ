#import "@preview/fletcher:0.5.8" as f: diagram, node, edge

/// --- Styling (nodes a bit smaller) ---
#let V(pos, lab) = f.node(
  pos, [$#lab$],
  inset: 3.5pt,          // was 5pt
  stroke: 0.85pt,
  fill: luma(95%)
)
#let del(a, b) = f.edge(a, b, stroke: (thickness: 1.1pt, dash: "dashed"))
#let add(a, b) = f.edge(a, b, stroke: 1.1pt)

/// --- Panel label (kept slightly larger) ---
#let panel(label, body) = stack(
  spacing: 1.5mm,
  // scale diagrams down to 50%
  scale(50%, body),
  text(size: 9.5pt, weight: "medium")[#label],
)

/// --- Operator block: a/b/c horizontally ---
#let opblock(title, a, b, c, gutter: 0mm) = stack(
  spacing: 0.35em,
    grid(
      columns: 3,
      column-gutter: gutter,
      panel("1)", a),
      panel("2)", b),
      panel("3)", c),
    ),
    text(size: 11pt, title)
)

/// --- Row helpers ---
#let row3(a, b, c) = grid(
  columns: 3,
  column-gutter: 12mm,
  align: top + center,
  a, b, c
)
#let row2(a, b) = grid(
  columns: 2,
  column-gutter: 12mm,
  align: top + center,
  a, b
)

/// --- Shared geometry ---
#let s = (8mm, 6mm)
#let x = 1.4
#let y = 1.4

/// =====================
/// Diagrams (unchanged content)
/// =====================

// 2-opt(*)
#let d2opt_a = f.diagram(
  spacing: s,
  V((0,0), "A"), V((x,0), "B"),
  V((0,y), "C"), V((x,y), "D"),
  add((0,0), (x,y)),
  add((0,y), (x,0)),
)
#let d2opt_b = f.diagram(
  spacing: s,
  V((0,0), "A"), V((x,0), "B"),
  V((0,y), "C"), V((x,y), "D"),
  del((0,0), (x,y)),
  del((0,y), (x,0)),
  add((0,0), (x,0)),
  add((0,y), (x,y)),
)
#let d2opt_c = f.diagram(
  spacing: s,
  V((0,0), "A"), V((x,0), "B"),
  V((0,y), "C"), V((x,y), "D"),
  add((0,0), (x,0)),
  add((0,y), (x,y)),
)

// Relocate
#let drel_a = f.diagram(
  spacing: s,
  V((0,0), "A"), V((x,0), "X"), V((2*x,0), "B"),
  add((0,0), (x,0)), add((x,0), (2*x,0)),
  V((0,y), "C"), V((2*x,y), "D"),
  add((0,y), (2*x,y)),
)
#let drel_b = f.diagram(
  spacing: s,
  V((0,0), "A"), V((x,0), "X"), V((2*x,0), "B"),
  del((0,0), (x,0)), del((x,0), (2*x,0)),
  add((0,0), (2*x,0)),
  V((0,y), "C"), V((x,y), "X"), V((2*x,y), "D"),
  del((0,y), (2*x,y)),
  add((0,y), (x,y)), add((x,y), (2*x,y)),
)
#let drel_c = f.diagram(
  spacing: s,
  V((0,0), "A"), V((2*x,0), "B"),
  add((0,0), (2*x,0)),
  V((0,y), "C"), V((x,y), "X"), V((2*x,y), "D"),
  add((0,y), (x,y)), add((x,y), (2*x,y)),
)

// Swap
#let dsw_a = f.diagram(
  spacing: s,
  V((0,0), "A"), V((x,0), "X"), V((2*x,0), "B"),
  add((0,0), (x,0)), add((x,0), (2*x,0)),
  V((0,y), "C"), V((x,y), "Y"), V((2*x,y), "D"),
  add((0,y), (x,y)), add((x,y), (2*x,y)),
)
#let dsw_b = f.diagram(
  spacing: s,
  V((0,0), "A"), V((x,0), "X"), V((2*x,0), "B"),
  V((0,y), "C"), V((x,y), "Y"), V((2*x,y), "D"),
  del((0,0), (x,0)), del((x,0), (2*x,0)),
  del((0,y), (x,y)), del((x,y), (2*x,y)),
  add((0,0), (x,y)), add((x,y), (2*x,0)),
  add((0,y), (x,0)), add((x,0), (2*x,y)),
)
#let dsw_c = f.diagram(
  spacing: s,
  V((0,0), "A"), V((x,0), "Y"), V((2*x,0), "B"),
  add((0,0), (x,0)), add((x,0), (2*x,0)),
  V((0,y), "C"), V((x,y), "X"), V((2*x,y), "D"),
  add((0,y), (x,y)), add((x,y), (2*x,y)),
)

// Swap\*
#let dss_a = dsw_a
#let dss_b = f.diagram(
  spacing: s,
  V((0,0), "A"), V((x,0), "X"), V((2*x,0), "B"),
  V((0,y), "C"), V((x,y), "Y"), V((2*x,y), "D"),
  del((0,0), (x,0)), del((x,0), (2*x,0)),
  del((0,y), (x,y)), del((x,y), (2*x,y)),
  add((0,0), (2*x,0)), add((2*x,0), (x,y)),
  add((0,y), (x,0)), add((x,0), (2*x,y)),
)
#let dss_c = f.diagram(
  spacing: s,
  V((0,0), "A"), V((x,0), "B"), V((2*x,0), "Y"),
  add((0,0), (x,0)), add((x,0), (2*x,0)),
  V((0,y), "C"), V((x,y), "X"), V((2*x,y), "D"),
  add((0,y), (x,y)), add((x,y), (2*x,y)),
)

#let neiborhoods = [
  #row2(
    opblock([2-opt], d2opt_a, d2opt_b, d2opt_c),                 // tight
    opblock([Relocate], drel_a, drel_b, drel_c, gutter: 14mm),   // wide
  )

  #v(0.5em)

  #row2(
    opblock([Swap], dsw_a, dsw_b, dsw_c),                        // tight
    opblock([Swap\*], dss_a, dss_b, dss_c),                      // tight
  )
]
