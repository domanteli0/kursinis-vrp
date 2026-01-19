#import "@preview/citegeist:0.2.0": load-bibliography

#let bibtex_string = read("bibliography.bib")
#let bib = load-bibliography(bibtex_string)

#let cite-with-title(bibitem) = {
  let key = bib.keys().find(key => key == str(bibitem))
  let entry_fields = bib.at(key).at("fields")

  "\"" + entry_fields.title + "\" " + ref(bibitem) + " (" + entry_fields.year + ")"
}

#let c = cite-with-title
#let q(a: "", b: true, body) = {
  block(
    width: 100%,
    stroke: (left: 2pt + black), // Adds a black line on the right
    inset: (right: 1em),         // Adds some space between text and line
    spacing: 1em,  // Adjust this value as needed
    quote(attribution: a, block: b)[#body]
  )

}

// ----------------- //
#let tab = "    "
#let br = align(center)[#v(1em) #line(stroke: 1pt, length: 70%) #v(1em)]

// ----------------- //

#let angl_(body) = [_angl. #{body}_]
#let angl(body) = [(#{angl_(body)})]

// ----------------- //
#let todo(body) = highlight(fill: red.lighten(50%))[#body]
#let note(body) = highlight(fill: yellow.lighten(50%))[#body]
#let mine(body) = highlight(fill: yellow.lighten(50%))[(autoriaus papildymas: #body)]

#let qi(isBlock: false, body, original) = {
  quote(block: isBlock)[#body]
  footnote(original)
}

#let ref_number(label) = {
  let elem = query(label).at(0)
  if elem.func() == figure {
    elem.counter.at(label).at(0)
  } else if elem.func() == math.equation {
    counter(math.equation).at(label).at(0)
  } else {
    counter(figure).at(label).at(0)
  }
}

#let lt_ame(label) = context { [#str(ref_number(label))-ame] }
#let lt_oje(label) = context { [#str(ref_number(label))-oje] }
#let lt_a(label) = context { [#str(ref_number(label))-a] }
