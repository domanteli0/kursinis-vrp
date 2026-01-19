#import "@preview/fletcher:0.5.8" as f: diagram, node, edge
#import f.shapes: house, hexagon
#set text(font: "New Computer Modern")

// #let blob(pos, label, tint: white, ..args) = node(
// 	pos, align(center, label),
// 	width: 28mm,
// 	fill: tint.lighten(60%),
// 	stroke: 1pt + tint.darken(20%),
// 	corner-radius: 5pt,
// 	..args,
// )
#let blob(pos, label, tint: white, ..args) = node(
  pos,
  align(center, label),
  fill: tint,
  stroke: 1pt + black,
  corner-radius: 5pt,
  ..args,
)

#let hgs_flowchart = diagram(
	spacing: 8pt,
	cell-size: (8mm, 10mm),
	edge-stroke: 1pt,
	edge-corner-radius: 5pt,
	mark-scale: 70%,

	node(
    (2, -1),
    [],
    name: <start>,
    shape: circle,
    radius: 3pt,
    fill: black,
    stroke: black,
  ),
  edge("->"),

	blob((2,0), [PRADINIAI \ INDIVIDAI], tint: white),
	edge("->"),

	blob((3,0), [#underline[Įvykdomi]  |  #underline[Neįvykdomi] \ #v(0.1em) *POPULIACIJA*], tint: white.darken(15%), inset: 1em, name: <pop>),
	edge(<pop>, <return>, align(center)[Jei vykdymas \ baigtas], "-|>", label-side: right),
	edge("d,rr,d", "->", move(dy: 2em)[Jei vykdymas nebaigtas], label-side: left),

	blob(
        (5, 0),
        [GRĄŽINTI \ GERIAUSIĄ INDIVIDĄ],
        name: <return>,
      ),

	blob(
	  (5,2),
    [
      1) DVEJETAINIS TURNYRAS \
      #emph[Pagal kainą ir įvairovę]
    ],
    name: <binary_tour>,
	),
	edge("->"),

	blob((5, 3.1), [2) "OX" KRYŽMINIMAS\ ir "SPLIT"]),
	edge("->"),

  blob(
    (5, 4),
    [3) VIETINĖ PAIEŠKA, \ ir galimas TAISYMAS],
  ),
	edge("->"),

	blob(
	  (3,4),
    [
      4) ĮTERPIMAS Į POPULIACIJĄ IR \
      POPULIACIJOS VALDYMAS \
      #emph[Baudų tikslinimas \ Išlikusių atranka]
    ],
    name: <step4>,
  ),
  edge(<step4>, <pop>, "->", shift: 1em),

 //      blob(
 //        (0.0, 1.5),
 //        [
 //          4) ĮTERPIMAS Į POPULIACIJĄ IR \
 //          POPULIACIJOS VALDYMAS \
 //          #emph[Baudų tikslinimas \ Išlikusių atranka]
 //        ],
 //        name: <step4>,
 //      )

 //      edge(<pop>, <step1>, [Jei vykdymas nebaigtas], "-|>", label-side: right)
 //      edge(<step1>, <step2>, "-|>")
 //      edge(<step2>, <step3>, "-|>")
 //      edge(<step3>, <step4.east>, "-|>")
 //      edge(<step4>, <pop>, "-|>")

	// blob((0,1), [Add & Norm], tint: yellow, shape: hexagon),
	// edge(),
	// blob((0,2), [Multi-Head\ Attention], tint: orange),
	// blob((0,4), [Input], shape: house.with(angle: 30deg),
	// 	width: auto, tint: red),

	// for x in (-.3, -.1, +.1, +.3) {
	// 	edge((0,2.8), (x,2.8), (x,2), "-|>")
	// },
	// edge((0,2.8), (0,4)),

	// edge((0,3), "l,uu,r", "--|>"),
	// edge((0,1), (0, 0.35), "r", (1,3), "r,u", "-|>"),
	// edge((1,2), "d,rr,uu,l", "--|>"),

	// // blob((2,0), [Softmax], tint: green),
	// edge("<|-"),
	// blob((2,1), [Add & Norm], tint: yellow, shape: hexagon),
	// edge(),
	// blob((2,2), [Feed\ Forward], tint: blue),
)
