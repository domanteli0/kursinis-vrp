#import "@preview/cetz:0.4.2": canvas, draw
#import draw: rect, line, content
#set text(font: "palemonas")

#let parallel_hgs_memory = canvas({
  let gx = 80mm
  let gy = 20mm

  let left_x = 0mm
  let right_x = 90mm

  let box(center, size, label, name: none, fill: white, stroke: 1pt + black, radius: 4pt, align_left: false) = {
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
    if align_left {
      content((x - w / 2 + 4mm, y), label, anchor: "west")
    } else {
      content((x, y), label, anchor: "center")
    }
  }

  let arrow(a, b) = line(a, b, mark: (end: "stealth", scale: 0.8))

  let init_fill = rgb("#d9e7ff")
  let seq_fill = rgb("#f6e7d5")
  let par_fill = rgb("#dff2d6")
  let mem_fill = rgb("#e9e9f5")

  content((left_x, 12mm), text(size: 10pt)[Algoritmo eiga], anchor: "west")
  content((right_x, 12mm), text(size: 10pt)[Atmintis], anchor: "west")

  let step_size = (70mm, 18mm)
  let (step_w, _) = step_size
  let step_y0 = 0mm

  let init_step = (left_x + step_w / 2, step_y0)
  let cross_step = (left_x + step_w / 2, step_y0 - gy)
  let local_step = (left_x + step_w / 2, step_y0 - 2 * gy)
  let repair_step = (left_x + step_w / 2, step_y0 - 3 * gy)
  let update_step = (left_x + step_w / 2, step_y0 - 4 * gy)

  box(
    init_step,
    (70mm, 18mm),
    text(size: 9pt)[1) Inicijavimas (nuoseklus) \
    N = omp_get_max_threads()],
    name: "init_step",
    fill: init_fill,
    align_left: true,
  )

  box(
    cross_step,
    (70mm, 18mm),
    text(size: 9pt)[2) Kryžminimas ir masyvų paruoša \
    (nuoseklus)],
    name: "cross_step",
    fill: seq_fill,
    align_left: true,
  )

  box(
    local_step,
    (70mm, 16mm),
    text(size: 9pt)[3) Vietinė paieška (OpenMP)],
    name: "local_step",
    fill: par_fill,
    align_left: true,
  )

  box(
    repair_step,
    (70mm, 16mm),
    text(size: 9pt)[4) Taisymas (OpenMP)],
    name: "repair_step",
    fill: par_fill,
    align_left: true,
  )

  box(
    update_step,
    (70mm, 18mm),
    text(size: 9pt)[5) Populiacijos atnaujinimas \
    (nuoseklus)],
    name: "update_step",
    fill: seq_fill,
    align_left: true,
  )

  let mem_size = (110mm, 68mm)
  let (mem_w, mem_h) = mem_size
  let mem_center = (right_x + mem_w / 2, step_y0 - 2 * gy)
  box(
    mem_center,
    mem_size,
    text(size: 9pt)[
      *Atmintis (bendras regionas)* \
      1) Parametrai ir atsitiktinumo būsenos \
      2) Populiacija (įvykdomi ir neįvykdomi) \
      3) Palikuonių buferis \
      4) Vietinės paieškos kontekstai (gijų privatūs) \
      5) Vietinės paieškos rezultatai \
      6) Taisymo rezultatai ir žymos
    ],
    name: "memory",
    fill: mem_fill,
    align_left: true,
  )

  arrow("init_step", "cross_step")
  arrow("cross_step", "local_step")
  arrow("local_step", "repair_step")
  arrow("repair_step", "update_step")

  let (mem_x, mem_y) = mem_center
  let mem_left = mem_x - mem_w / 2
  let mem_top = mem_y + mem_h / 2
  let mem_gap = mem_h / 5

  let (init_x, init_y) = init_step
  let (cross_x, cross_y) = cross_step
  let (local_x, local_y) = local_step
  let (repair_x, repair_y) = repair_step
  let (update_x, update_y) = update_step

  arrow((mem_left, mem_top - mem_gap * 0.7), (init_x + 35mm, init_y + 6mm))
  arrow((init_x + 35mm, init_y - 6mm), (mem_left, mem_top - mem_gap * 0.5))

  arrow((mem_left, mem_top - mem_gap * 1.7), (cross_x + 35mm, cross_y + 6mm))
  arrow((cross_x + 35mm, cross_y - 6mm), (mem_left, mem_top - mem_gap * 1.5))

  arrow((mem_left, mem_top - mem_gap * 2.7), (local_x + 35mm, local_y + 6mm))
  arrow((local_x + 35mm, local_y - 6mm), (mem_left, mem_top - mem_gap * 2.5))

  arrow((mem_left, mem_top - mem_gap * 3.7), (repair_x + 35mm, repair_y + 6mm))
  arrow((repair_x + 35mm, repair_y - 6mm), (mem_left, mem_top - mem_gap * 3.5))

  arrow((mem_left, mem_top - mem_gap * 4.7), (update_x + 35mm, update_y + 6mm))
  arrow((update_x + 35mm, update_y - 6mm), (mem_left, mem_top - mem_gap * 4.5))
})

#parallel_hgs_memory
