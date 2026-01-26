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
    author: [Domantas Keturakis \ Darbo vadoas: Doc., Dr. Algirdas Lančinskas],
    // date: datetime.today(),
    institution: [],
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
#set cite(style: "alphanumeric")

#title-slide()

#set text(weight: "regular")

== Transporto maršrutų optimizavimo uždavinys

Šis uždavinio #angl[Vehicle Routing Problem - VRP] tikslas surasti optimalų maršrutų rinkinį transporto priemonėms, aplankant visus klientus. Egzistuoja daugelys variantai: _VRPTW_, _GVRP_, _MDPVRP_, kt. .

*CVRP:* Transporto priemonės ribojamos talpa.

*Ypatybės:*
- Tai yra NP-hard uždavinys.
- Tikslūs metodai nėra efektyvūs.
- Praktikoje naudojami (meta-)heuristiniai algoritmai (pvz. HGS ar ALNS).

*Svarba:* Optimaliai suformuoti maršrutai mažina transporto išlaidas.

== Darbo tikslas ir uždaviniai

*Tikslas:* Išlygiagretinti HGS algoritmą, siekiant sumažinti vykdymo laiką neprarandant sprendinių kokybės.

*Uždaviniai:*
1. Išsirinkti duomenų rinkinį, pagal kurį galima būtų testuoti ir analizuoti sprendinius.
2. Išanalizuoti, kaip veikia HGS algoritmas.
3. Atrinkti lygiagretinamas dalis, kurias galima pakeisti lygiagrečiomis.
4. Palyginti rezultatus su literatūroje aprašytais pažangiausiais algoritmais.

== Hibridinis genetinis paieškos algoritmas (HGS)

#grid(
  columns: (auto, auto),
  [
    *HGS komponentai:*
    1.  *Populiacija:* Įvykdomų ir neįvykdomų sprendinių aibės.
    2.  *Kryžminimas:* Dvejetainis turnyras tėvų atrankai.
    3.  *Gerinimas:* "Split" kaimynystės taikymas.
    4.  *Vietinė paieška (Local Search):* Intensyvus gerinimas (*Swap\**, *Relocate*, *2-opt*).
    5.  *Populiacijos valdymas:* Įvairovės palaikymas ir blogiausių šalinimas.
  ],
  align(center)[
    #figure(
      caption: [HGS veikimas @vidal2022Hybrid],
      content-style[#viewbox(hgs_flowchart, height: 60%)]
    ) <hgs_flowchart>
  ]
)



== Vietinė paieška

#figure(caption: [Įvairių kaimynysčių veikimas])[#neiborhoods]

== Literatūros analizė

*Egzistuojantys sprendimai:*
- *GPU skaičiavimai:* Masiškai lygiagretina kaimynystes (pvz., *2-opt*), bet dažnai atsisako sudėtingų operatorių (*Swap\**).
  - Randa beveik optimalius sprendimus greičiau nei nuosekli versija.
  - Daugelis metodų aukoja *Swap\** kaimynystę, kuri yra kritinė HGS kokybei.
- *Salų modelis (Island Model):* Kelios nepriklausomos populiacijos su periodine migracija.
  - Sunkesnis įgyvendinimas ir pritaikymas.


#figure(
  caption: [HGS su salų modeliu @jamshidi2025A_Para],
  scale(50%, reflow: true, island_model)
) <hgs_island_model>


== Lygiagretinimas

*Pasirinkta kryptis:* Lygiagreti vietinė paieška (CPU) išlaikant visus HGS operatorius.

#figure(
  caption: [Dalis lygiagretinto HGS-CVRP pseudokodas (grįstas pagal @vidal2012A_Hybr)],
  pseudocode-list(booktabs: true)[
  + ...
  + Atlikti kryžminimą ir gerinimą $N$#footnote[$N$ - gijų skaičius] kartų
  + *Kiekvienoje gijoje*:
    + Išmokyti naują individą (vietinė paieška)
    + *Jeigu* individas neįvykdomas:
      + Su 50 % tikimybe bandyti sutaisyti individą
  + Įterpti išmokytus individus į atitinkamas subpopuliacijas
  + Kas $N$ ciklų populiacijos valdymas
  + ...
  ]
) <algo_parallel>

#align(center)[
  #scale(30%, reflow: true, image("img/parallel_memory.png"))
]

== Metodika

- Matuojami rezultatai po 1%, 2%, 5%, 10%, 15%, 20%, 30%, 50%, 75% ir 100% vykdymo laiko. // SPEAK: kad būtų galima palyginti tarp duomenų rinkinių.
- Laiko limitas priklauso nuo duomenų kiekio, $T_"max" = n dot 24/100$; $T_"max"$ - laiko limitas, $n$ - klientų skaičius.

== Sprendinių kaina

$
  "Sprendinio kaina" &= &&sum_(k=1)^(K) sum_(i=0)^(|V|) sum_(j=0)^(|V|) c_(i,j) x_(i,j,k) \
  x_(i,j,k) &= &&1 "Indikatorinė" "funkcija", "kuri" \
  & &&"lygi" 1, "jei" "transporto" "priemonė" k " " (1 <= k <= K)\
  & &&"keliauja" "nuo" "kliento" i "iki" "kliento" j, \
  & &&"lygi" 0 "priešingu" "atveju"
$ <math_cost>

$
  #[*Spraga laiko momentu $t$:*] G &= ((Z_s - Z_"BKS") / Z_"BKS") dot 100% \
  Z_s &= #[Pasirinkto algoritmo sprendinio kaina] \
  Z_"BKS" &= #[Geriausio sprendinio kaina]
$ <math_gap>

== Rezultatai: Sprendinių kokybė

#let x_gap_result = gap_data(instances: x_vrp_instances)
#let x_speedups = calculate_all_speedups(x_vrp_instances)

#align(center)[
  #content-style[#viewbox(gap_threads_plot_from(x_gap_result), height: 70%)]
]

== Rezultatai: Pagreitėjimas ir efektyvumas
// NOTE: kadangi HGS gali veikti nustatutą

*Teorinis pagreitėjimas:* $S^A_p = 1 / ((1 - f) + f / p) $, *faktinis pagreitėjimas:* $S_p = T_p / T_1 $,
*Efektyvumas*: $E_p = S_p / p $

$f$ - lygiagretinamos dalies vykdymo laikas $\/$ visas algoritmo vykdymo laikas.

$p$ - gijų skaičius.

$T_p$ - laikas, kurį algoritmas vykdė su $p$ gijomis, kad pasiekti numatytą spragą.

#let points = range(0, x_speedups.threads.len()).map(i => { (x_speedups.threads.at(i), x_speedups.average.at(i)) })

*Vidutinis pagreitėjimas:* 2 gijos: $~#str(points.at(0).at(1)).slice(0, 4) times$, 4 gijos: $~#str(points.at(1).at(1)).slice(0, 4) times$, 8 gijos: $~#str(points.at(2).at(1)).slice(0, 4) times$, 16 gijų: $~#str(points.at(3).at(1)).slice(0, 4) times$.

// Function to plot average speedup
#grid(
  columns: 2,
  gutter: 2em,
  [#figure(
    caption: [Vidutinė sprendinių spraga pagal gijų skaičių per vykdymo laiką (Uchoa 2017 X-n rinkinys)],
    content-style[#viewbox(plot_average_speedup(x_speedups), height: 60%)]
  ) <gap_over_time_plot>],
  [#figure(
    caption: [Vidutinis ir tikrasis efektyvumas, (Uchoa 2017 X-n rinkinys)],
    content-style[#viewbox(plot_average_efficiency(x_speedups), height: 60%)]
  ) <x-speedup-plot>]
)

== Išvados

1. Lygiagreti vietinė paieška HGS-CVRP algoritme pagerina sprendinių kokybę per tą patį laiko tarpą.
2. Įmanoma lygiagretinti hibridinį genetinį paieškos algoritmą, kuris naudoja _swap\*_ kaimynystę, užtikrinant mažesnį vykdymo laiką.

== Šaltiniai

#bibliography(title: none, "bibliography.bib")
