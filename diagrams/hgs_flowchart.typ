#import "@preview/cetz:0.4.2": canvas, draw
#import draw: rect, line, circle, content
#set text(font: "palemonas")

#let hgs_flowchart = canvas({
  let gx = 24mm
  let gy = 18mm

  let coord(x, y) = (x * gx, -y * gy)

  let box(center, size, label, fill: white, stroke: 1pt + black, radius: 4pt) = {
    let (w, h) = size
    let (x, y) = center
    rect(
      (x - w / 2, y - h / 2),
      (x + w / 2, y + h / 2),
      fill: fill,
      stroke: stroke,
      radius: radius,
    )
    content((x, y), label, anchor: "center")
  }

  let arrow(a, b) = line(a, b, mark: (end: "stealth", scale: 0.8))

  let start = coord(2, -1)
  let init = coord(2, 0)
  let pop = coord(3, 0)
  let ret = coord(5, 0)
  let step1 = coord(5, 2)
  let step2 = coord(5, 3.1)
  let step3 = coord(5, 4)
  let step4 = coord(3, 4)

  let init_size = (48mm, 14mm)
  let pop_size = (68mm, 24mm)
  let ret_size = (48mm, 14mm)
  let step1_size = (60mm, 20mm)
  let step2_size = (54mm, 16mm)
  let step3_size = (60mm, 20mm)
  let step4_size = (66mm, 24mm)

  circle(start, radius: 3pt, fill: black, stroke: black)

  box(init, init_size, [PRADINIAI \ INDIVIDAI])
  box(
    pop,
    pop_size,
    [#underline[Įvykdomi]  |  #underline[Neįvykdomi] \ #v(0.1em) *POPULIACIJA*],
    fill: white.darken(15%),
  )
  box(ret, ret_size, [GRĄŽINTI \ GERIAUSIĄ INDIVIDĄ])
  box(
    step1,
    step1_size,
    [1) DVEJETAINIS TURNYRAS \
    #emph[Pagal kainą ir įvairovę]],
  )
  box(step2, step2_size, [2) "OX" KRYŽMINIMAS\ ir "SPLIT"])
  box(step3, step3_size, [3) VIETINĖ PAIEŠKA, \ ir galimas TAISYMAS])
  box(
    step4,
    step4_size,
    [4) ĮTERPIMAS Į POPULIACIJĄ IR \
    POPULIACIJOS VALDYMAS \
    #emph[Baudų tikslinimas \ Išlikusių atranka]],
  )

  let (start_x, start_y) = start
  let (init_x, init_y) = init
  let (_, init_h) = init_size
  let (pop_x, pop_y) = pop
  let (pop_w, pop_h) = pop_size
  let (ret_x, ret_y) = ret
  let (ret_w, _) = ret_size
  let (init_w, _) = init_size
  let (step1_x, step1_y) = step1
  let (_, step1_h) = step1_size
  let (step2_x, step2_y) = step2
  let (_, step2_h) = step2_size
  let (step3_x, step3_y) = step3
  let (_, step3_h) = step3_size
  let (step4_x, step4_y) = step4
  let (step4_w, step4_h) = step4_size

  // Straight flow arrows
  arrow((start_x, start_y - 3pt), (init_x, init_y + init_h / 2))
  arrow((init_x + init_w / 2, init_y), (pop_x - pop_w / 2, pop_y))
  arrow((pop_x + pop_w / 2, pop_y), (ret_x - ret_w / 2, ret_y))

  arrow((step1_x, step1_y - step1_h / 2), (step2_x, step2_y + step2_h / 2))
  arrow((step2_x, step2_y - step2_h / 2), (step3_x, step3_y + step3_h / 2))
  arrow((step3_x, step3_y - step3_h / 2), (step4_x, step4_y + step4_h / 2))

  // If not finished: orthogonal arrow from population to step 1
  let pop_drop_y = pop_y - pop_h / 2 - 10mm
  line(
    (pop_x, pop_y - pop_h / 2),
    (pop_x, pop_drop_y),
    (step1_x, pop_drop_y),
    (step1_x, step1_y + step1_h / 2),
    mark: (end: "stealth", scale: 0.8),
  )
  content((pop_x + 10mm, pop_y - pop_h / 2 - 6mm), text(size: 8pt)[Jei vykdymas \ nebaigtas], anchor: "north")

  // If finished: label on the direct arrow
  content(((pop_x + ret_x) / 2, pop_y + 8mm), text(size: 8pt)[Jei vykdymas \ baigtas], anchor: "south")

  // Loop back to population
  let loop_y = step4_y - step4_h / 2 - 6mm
  line(
    (step4_x + step4_w / 2, step4_y),
    (step4_x + step4_w / 2 + 12mm, step4_y),
    (step4_x + step4_w / 2 + 12mm, loop_y),
    (pop_x + pop_w / 2 + 12mm, loop_y),
    (pop_x + pop_w / 2 + 12mm, pop_y),
    (pop_x + pop_w / 2, pop_y),
    mark: (end: "stealth", scale: 0.8),
  )
})

#hgs_flowchart
