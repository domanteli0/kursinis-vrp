#import "@preview/cetz:0.4.2": canvas, draw
#import draw: rect, line, content
#set text(font: "palemonas")

#let parallel_hgs_thread_flow = canvas({
  let left_x = 0mm
  let mem_x = 90mm

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
    content((x, y), align(center, label))
  }

  let arrow(a, b, dashed: false) = {
    let stroke_style = if dashed { (thickness: 1pt, dash: (2pt, 2pt)) } else { (thickness: 1pt) }
    line(a, b, stroke: stroke_style, mark: (end: "stealth", scale: 0.8))
  }

  content((left_x, 10mm), text(size: 9pt, weight: "bold")[Kryžminimas], anchor: "west")
  box((left_x + 20mm, 0mm), (16mm, 6mm), [Gija 1], name: "cross_t1")

  content((left_x, -18mm), text(size: 9pt, weight: "bold")[Vietinė paieška], anchor: "west")
  box((left_x + 20mm, -26mm), (16mm, 6mm), [Gija 1], name: "ls_t1")
  box((left_x + 20mm, -36mm), (17mm, 6mm), [Gija 2], name: "ls_t2")
  box((left_x + 20mm, -46mm), (17mm, 6mm), [...], name: "ls_tn")
  box((left_x + 20mm, -56mm), (17mm, 6mm), [Gija N], name: "ls_tn2")

  content((left_x, -74mm), text(size: 9pt, weight: "bold")[Populiacijos\ valdymas], anchor: "west")
  box((left_x + 20mm, -82mm), (30mm, 14mm), [Populiacijos\ valdymas], name: "pop_mgmt")
  box((left_x + 20mm, -94mm), (16mm, 6mm), [Gija 1], name: "pm_t1")

  content((mem_x, -20mm), text(size: 9pt, weight: "bold")[Atmintis], anchor: "west")
  rect((mem_x, -90mm), (mem_x + 50mm, -10mm), stroke: 1pt + black, fill: white, name: "memory")
  box((mem_x + 25mm, -22mm), (38mm, 6mm), [Populiacija], name: "mem_pop", radius: 0pt)
  box((mem_x + 25mm, -34mm), (38mm, 6mm), [Palikuonis 1], name: "mem_off1", radius: 0pt)
  box((mem_x + 25mm, -46mm), (38mm, 6mm), [Palikuonis 2], name: "mem_off2", radius: 0pt)
  content((mem_x + 25mm, -58mm), text(size: 9pt)[...])
  box((mem_x + 25mm, -70mm), (38mm, 6mm), [Palikuonis N], name: "mem_offn", radius: 0pt)

  arrow("cross_t1", (mem_x, -34mm))
  content((mem_x - 8mm, -30mm), text(size: 8pt)[sukuria], anchor: "east")

  arrow("ls_t1", "mem_off1", dashed: true)
  arrow("ls_t2", "mem_off2", dashed: true)
  arrow("ls_tn", "mem_offn", dashed: true)

  arrow("pm_t1", "mem_pop")
  content((mem_x - 8mm, -22mm), text(size: 8pt)[prideda Palikuonius 1-N], anchor: "east")
})

// #parallel_hgs_thread_flow
