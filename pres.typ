#import "@preview/touying:0.6.1": *
#import themes.simple: *

// Imports from main.typ to reuse data and diagrams
#import "utils.typ": *
#import "data.typ": *
#import "data_gap.typ": gap_data
#import "data_speedup.typ": time_to_target_data, time_to_target_fixed
#import "tables/table1.typ": table_100_avg_from
#import "tables/table_params.typ": table_experiment_params
#import "tables/table_gap.typ": *
#import "tables/speedup.typ": *
#import "diagrams/speedup.typ": *
#import "diagrams/gap_threads.typ": gap_speedup_plot_from, gap_threads_plot_from, amdahl_speedup_plot
#import "diagrams/hgs_flowchart.typ": hgs_flowchart
#import "diagrams/parallel_hgs_arch.typ": parallel_hgs_diagram
#import "diagrams/parallel_hgs_memory.typ": parallel_hgs_memory
#import "diagrams/island_model.typ": island_model
#import "diagrams/time_target_speedup.typ": speedup_plot_from, efficiency_plot_from
#import "diagrams/neiborhoods.typ": neiborhoods

#import "@preview/cetz:0.4.2": canvas, draw
#import "@preview/cetz-plot:0.1.3": plot, chart
#import "style.typ": content-style

#let handout = sys.inputs.at("handout", default: "false") == "true"
#let aspect-ratio = sys.inputs.at("aspect", default: "4-3")

#let viewbox(content, height: 100%) = layout(size => {
  let content-at-12pt = text(size: 12pt, content)
  context {
    let dim = measure(content-at-12pt)
    // Check for zero height to avoid division by zero
    if dim.height == 0pt {
      content-at-12pt
    } else {
      let target-h = size.height * (height / 100%)
      let s = target-h / dim.height * 100
      scale(s * 1%, content-at-12pt)
    }
  }
})

#show: simple-theme.with(
  aspect-ratio: aspect-ratio,
  footer: [HGS-CVRP Lygiagretinimas],
  config-common: (handout: handout),
)

#title-slide[
  = Hibridinio genetinio paieškos algoritmo transporto maršrutų optimizavimo uždaviniams spręsti lygiagretinimas

  *Domantas Keturakis*

  Vadovas: Doc., Dr. Algirdas Lančinskas

  Vilniaus universitetas, MIF
]

#slide[
  ==Įvadas: Transporto maršrutų optimizavimas (VRP)

  *Tikslas:* Surasti optimalų maršrutų rinkinį transporto priemonėms, aplankant visus klientus.

  *CVRP (Capacitated VRP):*
  - Ribota transporto priemonių talpa ($Q$).
  - Tikslas: Minimizuoti bendrą atstumą (kainą).

  *Svarba:*
  - Realaus pasaulio logistikos optimizavimas.
  - $"NP"$-hard uždavinys $\to$ Metaheuristikos (pvz., HGS) yra efektyviausios.
]

#slide[
  == Hibridinis genetinis paieškos algoritmas (HGS)

  *HGS komponentai:*
  1.  *Populiacija:* Įvykdomi (Feasible) ir neįvykdomi (Infeasible) sprendiniai.
  2.  *Kryžminimas (Crossover):* Dvejetainis turnyras tėvų atrankai.
  3.  *Vietinė paieška (Local Search):* Intensyvus gerinimas (*Swap\**, *Relocate*, *2-opt*).
  4.  *Populiacijos valdymas:* Įvairovės palaikymas ir blogiausių šalinimas.

  #align(center)[
     #content-style[#viewbox(hgs_flowchart, height: 60%)]
  ]
]

#slide[
  == Literatūros analizė

  *Egzistuojantys sprendimai:*
  - *GPU skaičiavimai:* Masiškai lygiagretina kaimynystes (pvz., *2-opt*), bet dažnai atsisako sudėtingų operatorių (*Swap\**).
  - *Salų modelis (Island Model):* Kelios nepriklausomos populiacijos su periodine migracija.

  *Problematika:*
  - GPU realizacijos reikalauja specifinių duomenų struktūrų ir yra sudėtingos įgyvendinti pilnam HGS.
  - Daugelis metodų aukoja *Swap\** kaimynystę, kuri yra kritinė HGS kokybei.

  *Pasirinkta kryptis:* Lygiagreti vietinė paieška (CPU) išlaikant visus HGS operatorius.
]

#slide[
  == Darbo tikslas ir uždaviniai

  *Tikslas:* Išlygiagretinti HGS-CVRP algoritmą, siekiant sumažinti vykdymo laiką neprarandant sprendinių kokybės.

  *Uždaviniai:*
  1.  Išanalizuoti HGS veikimą (Vietinė paieška – 86% laiko).
  2.  Atrinkti ir realizuoti lygiagretinimo strategiją (OpenMP).
  3.  Palyginti su nuoseklia versija naudojant standartinius duomenis (Uchoa 2017).
]

#slide[
  == Lygiagretinimo strategija

  *Daugiagijis apdorojimas (OpenMP):*
  - Nuosekli tėvų atranka ir kryžminimas.
  - *Lygiagreti vietinė paieška:* Kiekviena gija apdoroja atskirą palikuonį.
  - Sinchronizacija prieš populiacijos atnaujinimą.

  #align(center)[
    #content-style[#viewbox(parallel_hgs_memory, height: 75%)]
  ]
]

#let x_gap_result = gap_data(instances: x_vrp_instances)
#let x_speedups = calculate_all_speedups(x_vrp_instances)

#slide[
  == Rezultatai: Sprendinių kokybė (Gap)

  Lygiagreti versija (spalvotos linijos) pasiekia geresnius rezultatus (mažesnę spragą) greičiau nei nuosekli (juoda linija).

  #align(center)[
    #content-style[#viewbox(gap_threads_plot_from(x_gap_result), height: 70%)]
  ]
]

#slide[
  == Rezultatai: Pagreitėjimas (Speedup)

  #let points = range(0, x_speedups.threads.len()).map(i => { (x_speedups.threads.at(i), x_speedups.average.at(i)) })

  *Vidutinis pagreitėjimas:*
  - 2 gijos: $~#str(points.at(0).at(1)).slice(0, 4) times$
  - 4 gijos: $~#str(points.at(1).at(1)).slice(0, 4) times$
  - 8 gijos: $~#str(points.at(2).at(1)).slice(0, 4) times$
  - 16 gijų: $~#str(points.at(3).at(1)).slice(0, 4) times$

  #align(center)[
    #content-style[#viewbox(plot_average_speedup(x_speedups), height: 60%)]
  ]
]

#slide[
  == Rezultatai: Efektyvumas

  Efektyvumas mažėja didėjant gijų skaičiui. Tai lemia Amdahlo dėsnis (nuoseklios dalys: populiacijos valdymas, kryžminimas) ir sinchronizacijos laukimas.

  #align(center)[
    #content-style[#viewbox(plot_average_efficiency(x_speedups), height: 60%)]
  ]
]

#slide[
  == Išvados

  1.  *Sėkmingas realizavimas:* HGS-CVRP sėkmingai išlygiagretintas naudojant OpenMP, išlaikant sudėtingą *Swap\** kaimynystę.
  2.  *Kokybės pagerėjimas:* Lygiagreti versija randa geresnius sprendinius per tą patį laiką.
  3.  *Našumas:* Pasiektas ~5.5x pagreitėjimas su 16 gijų.
  4.  *Ribojimai:* Pagreitėjimą riboja nuoseklios algoritmo dalys (Amdahlo dėsnis).
]

#slide[
  #align(center + horizon)[
    *Ačiū už dėmesį!*

    Klausimai?
  ]
]