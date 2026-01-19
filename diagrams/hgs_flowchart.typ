#import "@preview/fletcher:0.5.8": diagram, node, edge

#let hgs_flowchart = diagram(
  spacing: (8mm, 7mm),
  node-stroke: 0.8pt,
  edge-stroke: 0.8pt,
  node-corner-radius: 3pt,
  {
    let pop_bounds = ((-0.05, -2.85), (1.25, -1.4))
    node(
      enclose: pop_bounds,
      name: <pop>,
      fill: rgb(230, 230, 230),
      stroke: black,
      corner-radius: 8pt,
    )

    node((0.6, -1.6), [#strong[POPULIACIJA]], stroke: none, fill: none)
    node((0.2, -2.1), [#underline[Įvykdomi]], stroke: none, fill: none)
    node((1.0, -2.1), [#underline[Neįvykdomi]], stroke: none, fill: none)
    edge((0.6, -1.75), (0.6, -2.6), marks: (none, none), stroke: 0.6pt)

    node(
      (-1.0, -2.1),
      [PRADINIAI \ INDIVIDAI],
      name: <initial>,
      shape: rect,
    )
    node(
      (-1.85, -2.1),
      [],
      name: <start>,
      shape: circle,
      radius: 2pt,
      fill: black,
      stroke: black,
    )
    edge(<start>, <initial>, "->")
    edge(<initial>, <pop>, "->")

    node(
      (2.6, -2.1),
      [GRĄŽINTI \ GERIAUSIĄ INDIVIDĄ],
      name: <return>,
      shape: rect,
    )
    edge(<pop>, <return>, [Jei vykdymas baigtas], "->", label-side: left)

    node(
      (1.6, 0.6),
      [
        1) DVEJETAINIS TURNYRAS \
        #emph[Pagal kainą ir įvairovę]
      ],
      name: <step1>,
      shape: rect,
    )
    node((1.6, 1.5), [2) "OX" KRYŽMINIMAS \& "SPLIT"], name: <step2>, shape: rect)
    node(
      (1.6, 2.4),
      [3) VIETINĖ PAIEŠKA, \ ir galimas TAISYMAS],
      name: <step3>,
      shape: rect,
    )
    node(
      (0.0, 1.5),
      [
        4) ĮTERPIMAS Į POPULIACIJĄ IR \
        POPULIACIJOS VALDYMAS \
        #emph[Baudų tikslinimas \ Išlikusių atranka]
      ],
      name: <step4>,
      shape: rect,
    )

    edge(<pop>, <step1>, [Jei vykdymas nebaigtas], "->", label-side: right)
    edge(<step1>, <step2>, "->")
    edge(<step2>, <step3>, "->")
    edge(<step3>, <step4.east>, "->")
    edge(<step4>, <pop>, "->")
  },
)
