#import "style.typ": style
#import "utils.typ": c, q, tab, todo

#show: style.with(
  university: "Vilniaus universitetas",
  faculty: "Matematikos ir informatikos fakultetas",
  department: "Programų sistemų studijų programa",
  papertype: "Kursinis darbas",
  title: "Hibridinio genetinio paieškos algoritmo transporto maršrutų optimizavimo uždaviniams spręsti lygiagretinimas",
  titleineng: "Parallelization of Hybrid Genetic Search Algorithm for Solving Vehicle Routing Problem",
  author: "Domantas Keturakis",
  status: "4 kurso 1 grupės studentas",
  supervisor: "Doc., Dr. Algirdas Lančinskas",
  date: "Vilnius - 2025",
)

= Terminai

= Įvadas

#todo[paragrafas apie VRP relevance]

== Plačiau apie #todo[VRP] #todo[constraints]

Galimi #todo[constraints], kuriuos galima uždėti ant VRP problemų:

- kiekviena transporto priemonė gali turėti (skirtingą) maršruto pradžios laiką
- kiekviena transporto priemonė gali turėti (skirtingą) maksimalų atstumą, kurį gali nukeliauti
- kiekviena transporto priemonė gali turėti (skirtingą) maksimalią talpą
- kiekvienos transporto priemonės vairuotojas gali turėti (skirtingą) tvarkaraštį (skirtingas pamainos laikas, su arba be pertraukų)

- kiekvienas taškas gali turėti (skirtingas) veikimo valandas (galimai su pietų pertraukom, etc...)
- kiekvienas taškas gali turėti (skirtingas) #todo[service time]
- kiekvienas taškui gali būti arba nebūti griežtas reikalavimas jį aplankyti

- apmokėjimo #todo[constraints]:
  - per tašką
  - per atstumą
  - etc...

== Metodai

#todo[
- Matematinis modeliavimas (google or-tools)
- Heuristic -- A problem-specific rule or method to quickly find a good (not necessarily optimal) solution.
  https://chatgpt.com/share/68b3151a-85a8-800e-9cc6-3558041fe679
- Metaheuristic -- A higher-level strategy/framework that guides heuristics to explore solutions more effectively.
  https://chatgpt.com/share/68b3151a-85a8-800e-9cc6-3558041fe679

  - Adaptive Large Neighborhood Search
    \ 🛠️ https://reinterpretcat.github.io/vrp/

    - Hybrid Adaptive Large Neighborhood Search

  - Hybrid Genetic Search (HGS)
    \ 🛠️ https://pyvrp.org/
]

== Konkursai ir #todo[sprendimų/įrankių?] palyginimai

- DIMACS @dimacs2022vrp
- #todo[the Amazon Last Mile Routing Research
Challenge (Amazon last mile routing, 2021),
where a specific problem was tackled, namely,
the challenge of embedding driver knowledge
into route optimisation;]

== Įrankiai

- Matrix
  - OSMR
  - GraphHopper
  - Valhalla
  - BRouter
- Routing
  - https://pgrouting.org/

  - PyVRP
    \ supports CVRP, VRPTW

  - RouteOpt
    \ RouteOpt: An Open-Source Modular Exact Solver for Vehicle Routing Problems (2025)

- Simulation
  https://roadsimulator3.fr/these/chapters/chapitre00.html


Hibridinis genetinis paieškos (HGS) algoritmas yra vienas iš efektyviausių būdų spręsti transporto maršrutų optimizavimo uždavinius.

#pagebreak()
Pirma aprašytas #c(<vidal2012A_Hybr>).
- #q(a: <vidal2012A_Hybr>)[#image("img/Screenshot From 2025-09-27 23-07-08.png")]
- #q(a: <vidal2012A_Hybr>)[HGSADC proves to be extremely competitive CVRP.]
- maintains diversity in search -> avoids local minima ir dar aukštesnės kokybės sprendimai ir reduced computational time.

#pagebreak()
Esminis patogulinimas - @vidal2022Hybrid.

#todo[įvadas]

== Tikslas ir uždaviniai

*Tikslas* - Išlygiagretinti hibridinio genetinio paieškos algoritmą, skirto transporto maršrutų optimizavimo uždaviniams spręsti.

*Uždavinai:*

1. Išsirinkti duomenų rinkinį pagal, kurį galima būtų testuoti/analizuoti sprendimus, pvz.:
  - Solomon
  - CVRPLIB repository (repository of BKSs - Best Known Solutions)
  - Neural Combinatorial Optimization for Real-World Routing (2025)
  - Test-data generation and integration for long-distance e-vehicle routing (2023)
  - #c(<uchoa2017New_be>)
2. Išanalizuoti, kaip veikia HGS algoritmas
3. Atrinkti paralelizuojamas dalis, ar dalis, kurias galima galima pakeisti paralelizuojamomis
3. Palyginti rezultatus su kitais state-of-the-art algoritmais

= Abreviations

- VRP - Vechicle Routing Problem.
- #todo[CVRP - Capacitated Vehicle Routing Problem.]
- VRPTW - VRP with Time Windows.
- MVRP - multidepot VRP
- PVRP - periodic VRP
  #q(a: [https://neo.lcc.uma.es/vrp/vrp-flavors/periodic-vrp/])[In classical VRPs, typically the planning period is a single day. In the case of the Period Vehicle Routing Problem (PVRP), the classical VRP is generalized by extending the planning period to M days.]
- MDVRP - multidepot periodic MDPVRP
- #todo[CVRP with Backhauls]

= Matematinis formulavimas

#todo[TODO: matematikai aprašyti problemą ir siekiamą tikslą.]

= Notes

- VRPTW $in$ CVRP
- Specializuota optimizacija specializuotam uždaviniui
  \ #c(<bulhões2018The_ve>)
- #image("img/Screenshot From 2025-09-27 22-41-30.png")

== Literatūros apžvalgos

- #c(<hameed2025A_Deta>)
  \ tl;dr: aprašto logistikos problemų kriterijus ir tipus,
  tada šias priskiria tam tikriem VRP tipams (e.g. VRPPD, VRPTW, etc...)

- #c(<adamo2024A_revi>)
  \ tl;dr: pagrinde pristato ir aprašo CVRP.
  Išskiria metodų grupes (tikslūs; apytikslūs - heuristiniai ir metaheuristiniai).
  Iš metaheuristinių algoritmų grupių išskiria tris grupes:
  #q(a: <adamo2024A_revi>)[
  •Evolutionary such as “Genetic Algorithm (GA)”;\
  •Physic - Based such as “Simulated Annealing Algorithm (SAA)”; and\
  •Swarm Intelligence like “Ant colony optimization (ACO)”.]
  pasirinkti ACO grįsti algortimai ir palyginti tarpusavyje.

- #c(<petropoulos2023Operat>)
  \ tl;dr: apriebia visą _Operations Research_ iš 200 psl. ~2 skirta VRP.
  Pateikia įvairius naujus metaheuristinius algoritmus, išskiria HGS kaip vieną iš geresnių.
  #q()[An up-to-date survey on recent trends can be
    found in Vidal et al. (2020) [@vidal2020A_conc]]
  #q()[Clear standards have been set by the CVRP com­
  munity around which benchmark instances should be
  used for testing the performance of an algorithm, and
  which are ways of testing a computer code for a fair
  comparison with other previously proposed algorithms.
  Uchoa et al. (2017) discuss the most widely used
  instances and provides a link to the repository, in
  which the input data, as well as the best known solu­
  tions, are provided and kept up-to-date by the authors.
  A more recent set of instances and best known solu­
  tions is available in Queiroga et al. (2022), where the
  authors provide data enabling the use of machine
  learning approaches to solve the CVRP. Accorsi et al.
  (2022) present the standard practices to test CVRP
  algorithms: how to determine computing time (typic­
  ally on a single thread), common ways of tuning
  parameters, and providing best and average solutions
  on a specified number of executions, among others.
  ]

- #todo[TODO: #c(<vidal2020A_conc>)]


= Research areas

Related research:

- "A Parallel Hybrid Genetic Search for the Capacitated VRP with Pickup and Delivery" (2023)
- "Effective Parallelization of the Vehicle Routing Problem" (2023)
- #c(<latorre2025A_hybr>)

#pagebreak()
#bibliography(title: [Šaltiniai], "bibliography.bib")
