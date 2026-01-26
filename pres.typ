#import "@preview/touying:0.6.1": *
#import themes.metropolis: *
#import "@preview/numbly:0.1.0": numbly
#import "@preview/lovelace:0.3.0": *

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
  set text(lang: "LT", font: "Palemonas", weight: "regular")

  let content-at-12pt = text(size: 12pt, weight: "regular", stroke: none, content)
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

// #set text(font: "Computer Modern")

#show: metropolis-theme.with(
  ratio: aspect-ratio,
  footer: self => self.info.institution,
  config-info(
    title: [Hibridinio genetinio paieškos algoritmo transporto maršrutų optimizavimo uždaviniams spręsti lygiagretinimas],
    subtitle: [Parallelization of Hybrid Genetic Search Algorithm for Solving Vehicle Routing Problem],
    author: [Domantas Keturakis \ Doc., Dr. Algirdas Lančinskas],
    date: datetime.today(),
    institution: [VU MIF],
  ),
  config-colors(
    primary: rgb("#000000"),
    primary-light: rgb("#d6c6b7"),
    secondary: rgb("#3333b2"),
    // neutral-lightest: rgb("#fafafa"),
    // neutral-dark: rgb("#3333b2"),
    // neutral-darkest: rgb("#3333b2"),
  ),
  config-common: (handout: handout),
)
#set text(lang: "LT")

#title-slide()

#set text(weight: "regular")

== Transporto maršrutų optimizavimas (VRP)

*:* Surasti optimalų maršrutų rinkinį transporto priemonėms, aplankant visus klientus.

*CVRP (Capacitated VRP):*
- Ribota transporto priemonių talpa ($Q$).
- Tikslas: Minimizuoti bendrą atstumą (kainą).

*Svarba:*
- Realaus pasaulio logistikos optimizavimas.
- $"NP"$-hard uždavinys $\to$ Metaheuristikos (pvz., HGS) yra efektyviausios.

== Hibridinis genetinis paieškos algoritmas (HGS)

  *HGS komponentai:*
  1.  *Populiacija:* Įvykdomi (Feasible) ir neįvykdomi (Infeasible) sprendiniai.
  2.  *Kryžminimas (Crossover):* Dvejetainis turnyras tėvų atrankai.
  3.  *Vietinė paieška (Local Search):* Intensyvus gerinimas (*Swap\**, *Relocate*, *2-opt*).
  4.  *Populiacijos valdymas:* Įvairovės palaikymas ir blogiausių šalinimas.

  #align(center)[
    #figure(
      caption: [HGS veikimas @vidal2022Hybrid],
      content-style[#viewbox(hgs_flowchart, height: 60%)]
    ) <hgs_flowchart>
  ]

  == Literatūros analizė

  *Egzistuojantys sprendimai:*
  - *GPU skaičiavimai:* Masiškai lygiagretina kaimynystes (pvz., *2-opt*), bet dažnai atsisako sudėtingų operatorių (*Swap\**).
  - *Salų modelis (Island Model):* Kelios nepriklausomos populiacijos su periodine migracija.

  *Problematika:*
  - GPU realizacijos reikalauja specifinių duomenų struktūrų ir yra sudėtingos įgyvendinti pilnam HGS.
  - Daugelis metodų aukoja *Swap\** kaimynystę, kuri yra kritinė HGS kokybei.

  *Pasirinkta kryptis:* Lygiagreti vietinė paieška (CPU) išlaikant visus HGS operatorius.

  == Darbo tikslas ir uždaviniai

  *Tikslas:* Išlygiagretinti HGS-CVRP algoritmą, siekiant sumažinti vykdymo laiką neprarandant sprendinių kokybės.

  *Uždaviniai:*
  1.  Išanalizuoti HGS veikimą (Vietinė paieška – 86% laiko).
  2.  Atrinkti ir realizuoti lygiagretinimo strategiją (OpenMP).
  3.  Palyginti su nuoseklia versija naudojant standartinius duomenis (Uchoa 2017).

  == Lygiagretinimo strategija

  #figure(
    caption: [Dalis lygiagretinto HGS-CVRP pseudokodas (grįstas pagal @vidal2012A_Hybr)],
    pseudocode-list(booktabs: true)[
    + Pasirinkti $2N$#footnote[N – gijų skaičius] tėvinius individus (dvejetainis turnyras, angl. _binary tournament_)
    + Atlikti kryžminimą (angl. _crossover_)
    + *Kiekvienoje gijoje*:
      + Išmokyti naują individą (vietinė paieška)
      + *Jeigu* individas neįvykdomas:
        + Su 50 % tikimybe bandyti sutaisyti individą
    +Įterpti išmokytus individus į atitinkamas subpopuliacijas
    + *Jeigu* pasiektas maksimalus populiacijos dydis
      + Pašalinti blogiausius ir neįvairius individus iš populiacijos
    + Patikslinti baudos parametrus (angl. _penalty parameters_)
    ]
  ) <algo_parallel>

  #align(center)[
    #scale(20%, reflow: true, image("img/parallel_memory.png"))
  ]

#let x_gap_result = gap_data(instances: x_vrp_instances)
#let x_speedups = calculate_all_speedups(x_vrp_instances)

  == Rezultatai: Sprendinių kokybė (Gap)

  Lygiagreti versija (spalvotos linijos) pasiekia geresnius rezultatus (mažesnę spragą) greičiau nei nuosekli (juoda linija).

  #align(center)[
    #content-style[#viewbox(gap_threads_plot_from(x_gap_result), height: 70%)]
  ]

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

  == Rezultatai: Efektyvumas

  Efektyvumas mažėja didėjant gijų skaičiui. Tai lemia Amdahlo dėsnis (nuoseklios dalys: populiacijos valdymas, kryžminimas) ir sinchronizacijos laukimas.

  #align(center)[
    #content-style[#viewbox(plot_average_efficiency(x_speedups), height: 60%)]
  ]

  == Išvados

  1.  *Sėkmingas realizavimas:* HGS-CVRP sėkmingai išlygiagretintas naudojant OpenMP, išlaikant sudėtingą *Swap\** kaimynystę.
  2.  *Kokybės pagerėjimas:* Lygiagreti versija randa geresnius sprendinius per tą patį laiką.
  3.  *Našumas:* Pasiektas ~5.5x pagreitėjimas su 16 gijų.
  4.  *Ribojimai:* Pagreitėjimą riboja nuoseklios algoritmo dalys (Amdahlo dėsnis).

  == Šaltiniai

  #bibliography(title: none, "bibliography.bib")
