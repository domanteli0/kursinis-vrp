#let style(
  university: "Vilniaus universitetas",
  faculty: "Matematikos ir informatikos fakultetas",
  department: "Programų sistemų studijų programa",
  papertype: "Kursinis darbas",
  title: none,
  titleineng: none,
  author: none,
  status: none,
  supervisor: none,
  date: none,
  body
) = {
  set text(lang: "LT", font: "palemonas", size: 14pt)
  set par(leading: 0.75em, first-line-indent: (amount: 1cm, all: true))
  set cite(style: "alphanumeric")
  show link: it => {
    set text(rgb("#0b00d5"))
    underline(it)
  }

  // Set document properties
  set document(
    title: title,
    author: author
  )

  // Configure page
  set page(
    paper: "a4",
    margin: (
      left: 3cm,
      right: 1.5cm,
      y: 2cm,
    ),
  )

  set page(numbering: (page_num, ..ns) => { if page_num == 1 { "" } else { str(page_num) } })
  set page(number-align: right)

  // Title page
  page(
    align(center)[
      // #image("img/MIF.png")
      #v(1.2cm)
      #par(leading: 0.4cm, first-line-indent: (amount: 0pt))[
        #text(size: 13pt, upper(university)) \
        #text(size: 13pt, upper(faculty)) \
        #text(size: 13pt, upper(department))
      ]

      #v(3.4cm)

      #text(size: 19pt, weight: "bold")[#block(width: 100%)[#par(leading: 0.6em)[#title]]]
      #text(size: 14pt, weight: "bold")[#block(width: 90%)[#par(leading: 0.5em)[#titleineng]]] #v(3.3mm)
      #text(size: 14pt)[#papertype]

      #v(3cm)

      #align(right)[
        #block(width: 60%)[  // Control width for right alignment
          #grid(
            columns: (0.5fr, 1fr),
            gutter: (1.25em, 1.75em),
            align: left,
            [Atliko:], [#status],
            [], [#author #align(right)[]],
            [Darbo vadovas:], [#supervisor]
          )
        ]
      ]

      #v(1fr)

      #text(size: 12pt)[#date]
      #v(2em)
    ]
  )

  // Table of contents
  outline(
    title: "Turinys",
    indent: 1.5em,
  )
  pagebreak()

  set text(size: 12pt)

  // Main content
  body
}
