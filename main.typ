#import "style.typ": style
#import "utils.typ": c, tab, todo

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

== Plačiau apie #todo[VRP] tipus ir #todo[constraints]

#todo[

Constraints:
1. Each vehicle has a maximum shift duration
2. Each vehicle has a maximum distance range
3. Each vehicle has a start time
4. Each vehicle has a capacity (in number of points)
5. Each point has opening hours, potentially with short closures in between
6. Each point has an expected service time
7. Each driver is paid per stop
8. ---
9. All stops are mandatory
10. Multi-trips are modeled explicitly:
	- The algorithm is not responsible for scheduling returns to the warehouse.
11. Driver breaks: The maximum shift duration is reduced by 30 minutes to account for the
drivers required break. Breaks are not explicitly scheduled in routing.
12. Parcel capacity modelling
]

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

== Tools

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

Pirma aprašytas @vidal2012A_Hybr. Esminis patogulinimas - @vidal2022Hybrid.

#todo[įvadas]

== Tikslas ir uždaviniai

*Tikslas* - Išlygiagretinti hibridinio genetinio paieškos algoritmą, skirto transporto maršrutų optimizavimo uždaviniams spręsti.

*Uždavinai:*

1. Išsirinkti duomenų rinkinį pagal, kurį galima būtų testuoti/analizuoti sprendimus, pvz.:
  - Solomon
  - CVRPLIB repository (repository of BKSs - Best Known Solutions)
  - Neural Combinatorial Optimization for Real-World Routing (2025)
  - Test-data generation and integration for long-distance e-vehicle routing (2023)
2. Išanalizuoti, kaip veikia HGS algoritmas
3. Atrinkti paralelizuojamas dalis, ar dalis, kurias galima galima pakeisti paralelizuojamomis
3. Palyginti rezultatus su kitais state-of-the-art algoritmais

= Notes

- VRPTW $in$ CVRP

= Research areas

Related research:

#tab "A Parallel Hybrid Genetic Search for the Capacitated VRP with Pickup and Delivery" (2023)

#tab "Effective Parallelization of the Vehicle Routing Problem" (2023)

#pagebreak()
#bibliography(title: [Šaltiniai], "bibliography.bib")
