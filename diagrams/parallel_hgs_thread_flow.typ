// #import "@preview/fletcher:0.5.8" as f: diagram, node, edge
// #set text(font: "New Computer Modern")

// #let stage_box(
//   pos,
//   label,
//   name: none,
//   width: 30mm,
//   height: 14mm,
//   radius: 4pt,
//   ..args,
// ) = node(
//   pos,
//   align(center, text(size: 9pt)[#label]),
//   name: name,
//   fill: white,
//   stroke: 1pt + black,
//   width: width,
//   height: height,
//   inset: 2pt,
//   corner-radius: radius,
//   ..args,
// )

// #let thread_box(
//   pos,
//   label,
//   name: none,
//   width: 16mm,
//   height: 6mm,
//   radius: 3pt,
//   ..args,
// ) = node(
//   pos,
//   align(center, text(size: 8pt)[#label]),
//   name: name,
//   fill: white,
//   stroke: 1pt + black,
//   width: width,
//   height: height,
//   inset: 1pt,
//   corner-radius: radius,
//   ..args,
// )

// #let memory_item(
//   pos,
//   label,
//   name: none,
//   width: 38mm,
//   height: 6mm,
//   ..args,
// ) = node(
//   pos,
//   align(center, text(size: 8pt)[#label]),
//   name: name,
//   fill: white,
//   stroke: 1pt + black,
//   width: width,
//   height: height,
//   inset: 1pt,
//   corner-radius: 0pt,
//   ..args,
// )

// #let text_node(pos, label) = node(
//   pos,
//   label,
//   stroke: none,
//   fill: none,
//   inset: 0pt,
// )

// #let parallel_hgs_thread_flow = diagram(
//   spacing: 8pt,
//   cell-size: (10mm, 10mm),
//   edge-stroke: 1pt,
//   edge-corner-radius: 4pt,
//   mark-scale: 70%,
//   {
//     let left_x = 0
//     let mem_x = 3
//     let mem_y = 3.0

//     text_node((left_x, 0.5), text(size: 9pt, weight: "bold")[Kryžminimas])
//     node(
//       [],
//       height: 2em,
//       enclose: ((0, 0), <cross_t1>),
//       stroke: 1pt + black,
//       name: <local>,
//       fill: white,
//       corner-radius: 0pt,
//     )
//     thread_box((left_x, 1), [Gija 1], name: <cross_t1>)
//     edge("rr", (<cross_t1>, 50%, <mem_off1>), "d,r", "->", label: [sukuria], label-side: right)

//     text_node((left_x, 2.5), text(size: 9pt, weight: "bold")[Vietinė paieška])
//     node(
//       [],
//       enclose: (<ls_t1>, <ls_tn>),
//       stroke: 1pt + black,
//       name: <local>,
//       fill: white,
//       corner-radius: 0pt,
//     )

//     thread_box((left_x, 3), [Gija 1], name: <ls_t1>)
//     thread_box((left_x, 4), [Gija 2], name: <ls_t2>, width: 17mm)
//     stage_box((left_x, 5), [...], name: <ls_tn>, width: 17mm)
//     thread_box((left_x, 6), [Gija N], name: <ls_tn>, width: 17mm)

//     stage_box((left_x, 7), [Populiacijos\ valdymas], name: <pop_mgmt>, height: 14mm)
//     thread_box((left_x, 8), [Gija 1], name: <pm_t1>)

//     text_node((mem_x, mem_y - 0.5), text(size: 9pt, weight: "bold")[Atmintis])
//     node(
//       [],
//       enclose: (<mem_pop>, <mem_offn>),
//       stroke: 1pt + black,
//       name: <memory>,
//       fill: white,
//       corner-radius: 0pt,
//     )

//     memory_item((mem_x, mem_y - 1.4), [Populiacija], name: <mem_pop>)
//     memory_item((mem_x, mem_y - 0.8), [Palikuonis 1], name: <mem_off1>)
//     memory_item((mem_x, mem_y - 0.2), [Palikuonis 2], name: <mem_off2>)
//     text_node((mem_x, mem_y + 0.4), text(size: 9pt)[...])
//     memory_item((mem_x, mem_y + 1.0), [Palikuonis N], name: <mem_offn>)

//     edge(<ls_t1>, <mem_off1>, "->", "dashed", label: [Modifikuoja], label-side: right)
//     edge(<ls_t2>, <mem_off2>, "->", "dashed", label: [Modifikuoja], label-side: right)
//     edge(<ls_tn>, <mem_offn>, "->", "dashed", label: [Modifikuoja], label-side: right)
//     edge(<pm_t1>, <mem_pop>, "->", label: [prideda Palikuonius 1-N], label-side: right)
//   }
// )

// #parallel_hgs_thread_flow
