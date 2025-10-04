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
  quote(attribution: a, block: b)[#body]
}

// ----------------- //
#let tab = "    "

// ----------------- //
#let todo(body) = highlight(fill: red.lighten(50%))[#body]
#let note(body) = highlight(fill: yellow.lighten(50%))[#body]
