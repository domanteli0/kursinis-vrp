#import "@preview/fletcher:0.5.8" as f: diagram, node, edge
#set text(font: "New Computer Modern")

#let step_box(
  pos,
  label,
  name: none,
  fill: white,
  width: 70mm,
  height: 20mm,
  radius: 4pt,
  stroke: 1pt + black,
  ..args,
) = node(
  pos,
  align(left, label),
  name: name,
  fill: fill,
  stroke: stroke,
  width: width,
  height: height,
  inset: 4pt,
  corner-radius: radius,
  ..args,
)

#let title_node(pos, label) = node(
  pos,
  label,
  stroke: none,
  fill: none,
  inset: 0pt,
)

#let parallel_hgs_memory = diagram(
  spacing: 6pt,
  cell-size: (10mm, 12mm),
  edge-stroke: 1pt,
  edge-corner-radius: 4pt,
  mark-scale: 70%,
  {
    let init_fill = rgb("#d9e7ff")
    let seq_fill = rgb("#f6e7d5")
    let par_fill = rgb("#dff2d6")
    let mem_fill = rgb("#e9e9f5")

    let left_x = -1
    let right_x = 1

    title_node((left_x, -1.2), text(size: 10pt)[Algoritmo eiga])
    title_node((right_x, -1.2), text(size: 10pt)[Atmintis])

    step_box(
      (left_x, 0),
      text(size: 9pt)[
        1) Inicijavimas (nuoseklus) \
        N = omp_get_max_threads()
      ],
      name: <init_step>,
      fill: init_fill,
      height: 18mm,
    )

    step_box(
      (left_x, 1),
      text(size: 9pt)[
        2) Kryžminimas ir masyvų paruoša \
        (nuoseklus)
      ],
      name: <cross_step>,
      fill: seq_fill,
      height: 18mm,
    )

    step_box(
      (left_x, 2),
      text(size: 9pt)[
        3) Vietinė paieška (OpenMP)
      ],
      name: <local_step>,
      fill: par_fill,
      height: 16mm,
    )

    step_box(
      (left_x, 3),
      text(size: 9pt)[
        4) Taisymas (OpenMP)
      ],
      name: <repair_step>,
      fill: par_fill,
      height: 16mm,
    )

    step_box(
      (left_x, 4),
      text(size: 9pt)[
        5) Populiacijos atnaujinimas \
        (nuoseklus)
      ],
      name: <update_step>,
      fill: seq_fill,
      height: 18mm,
    )
    node(
      (right_x, 2),
      align(left, text(size: 9pt)[
        *Atmintis (bendras regionas)* \
        1) Parametrai ir atsitiktinumo būsenos \
        2) Populiacija (įvykdomi ir neįvykdomi) \
        3) Palikuonių buferis \
        4) Vietinės paieškos kontekstai (gijų privatūs) \
        5) Vietinės paieškos rezultatai \
        6) Taisymo rezultatai ir žymos
      ]),
      name: <memory>,
      fill: mem_fill,
      stroke: 1pt + black,
      inset: 4pt,
      corner-radius: 4pt,
    )

    edge(<init_step>, <cross_step>, "->")
    edge(<cross_step>, <local_step>, "->")
    edge(<local_step>, <repair_step>, "->")
    edge(<repair_step>, <update_step>, "->")

    let mem_init_read = (<memory.north-west>, 8%, <memory.south-west>)
    let mem_init_write = (<memory.north-west>, 12%, <memory.south-west>)
    let mem_cross_read = (<memory.north-west>, 28%, <memory.south-west>)
    let mem_cross_write = (<memory.north-west>, 32%, <memory.south-west>)
    let mem_local_read = (<memory.north-west>, 48%, <memory.south-west>)
    let mem_local_write = (<memory.north-west>, 52%, <memory.south-west>)
    let mem_repair_read = (<memory.north-west>, 68%, <memory.south-west>)
    let mem_repair_write = (<memory.north-west>, 72%, <memory.south-west>)
    let mem_update_read = (<memory.north-west>, 88%, <memory.south-west>)
    let mem_update_write = (<memory.north-west>, 92%, <memory.south-west>)

    edge(mem_init_read, <init_step.north-east>, "->")
    edge(<init_step.south-east>, mem_init_write, "->")
    edge(mem_cross_read, <cross_step.north-east>, "->")
    edge(<cross_step.south-east>, mem_cross_write, "->")
    edge(mem_local_read, <local_step.north-east>, "->")
    edge(<local_step.south-east>, mem_local_write, "->")
    edge(mem_repair_read, <repair_step.north-east>, "->")
    edge(<repair_step.south-east>, mem_repair_write, "->")
    edge(mem_update_read, <update_step.north-east>, "->")
    edge(<update_step.south-east>, mem_update_write, "->")
  }
)

#parallel_hgs_memory
