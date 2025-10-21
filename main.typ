#import "style.typ": style
#import "utils.typ": c, q, tab, todo, mine, note, angl, angl_

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

- Exact methods / Mathematical models (google or-tools)
- Heuristic -- #todo[A problem-specific rule or method to quickly find a good (not necessarily optimal) solution.]
- Metaheuristic -- #todo[A higher-level strategy/framework that guides heuristics to explore solutions more effectively.]

  - Adaptive Large Neighborhood Search / Hybrid Adaptive Large Neighborhood Search
    \ 🛠️ https://reinterpretcat.github.io/vrp/

  - Hybrid Genetic Search (HGS)
    \ 🛠️ https://github.com/vidalt/HGS-CVRP
    \ 🛠️ https://pyvrp.org/

  - Simulated Annealing Algorithm (SAA)

  - Ant colony optimization (ACO)

== Konkursai

- DIMACS @dimacs2022vrp
- #c(<AmazonChallengeDataSet>) #todo[TODO: properly cite the challenge, not just the dataset]
- #todo[EURO meets NeurIPS 2022 vehicle routing competition]

== Įrankiai

#note[
- Matrix
  - OSMR
  - GraphHopper
  - Valhalla
  - BRouter

- Simulation
  https://roadsimulator3.fr/these/chapters/chapitre00.html
]

#pagebreak()

Hibridinis genetinis paieškos (HGS) algoritmas yra vienas iš efektyviausių būdų spręsti transporto maršrutų optimizavimo uždavinius. #todo[[Citation needed?]]

Pirma aprašytas #c(<vidal2012A_Hybr>) ir patobulintas #todo[@vidal2014A_unif, @vidal2016Large_, @vidal2017Node__, @vidal2021Arc_Ro].
- #q(a: <vidal2012A_Hybr>)[#image("img/Screenshot From 2025-09-27 23-07-08.png")]
- #q(a: <vidal2012A_Hybr>)[HGSADC proves to be extremely competitive CVRP.]
- maintains diversity in search -> avoids local minima ir dar aukštesnės kokybės sprendimai ir reduced computational time.

\ \
Per daugelį iteracijų patobulintas aprašytas #c(<vidal2022Hybrid>).
- #q(a: <vidal2022Hybrid>)[the generalization of this method into a unified algorithm for the vehicle routing problem (VRP) family (Vidal et al., 2014, 2016; Vidal, 2017; Vidal et al., 2021)]
- #q(a: <vidal2022Hybrid>)[Beyond a simple reimplementation of the original algorithm, HGS-
CVRP takes advantage of several lessons learned from the past decade
of VRP studies: it relies on simple data structures to avoid move re-
evaluations and uses the optimal linear-time Split algorithm of Vidal
(2016). Moreover, its specialization to the CVRP permits significant
methodological simplifications. In particular, it does not rely on the visit-pattern improvement (PI) operator (Vidal et al., 2012) originally
designed for VRPs with multiple periods, and uses instead a new neigh-
borhood called Swap\*.]
- #q(a: <vidal2022Hybrid>)[In HGS-CVRP, we rely on the efficient linear-time Split algorithm introduced by Vidal (2016) #mine[@VIDAL2016] after each crossover operation.]
  \ #todo[TODO: #c(<VIDAL2016>)]
- naudoja #todo[#c(<UCHOA2017845>)] metodiką rezultatų palyginimui

#pagebreak()

#c(<latorre2025A_hybr>)
  \ grįstas HGS.
  \ Pritaikytas _Generalized Vehicle Routing Problem_ variantui
  \ #note[Nėra viešo source code].
  \ #q[We show that adapting the meta-heuristic strategies designed for the CVRP to the GVRP can be quite a straightforward process.]
  \ #q[we report the numerical results on the well-known instances problems for both the GVRP and CluVRP.]
  \ Straipsnyje rezultatai palyginti tik su kitais CluVRP, GRVP-pritaikytais algoritmais.

#pagebreak()

#c(<latorre2025An_appHybr>)
  \ grįstas HGS.
  \ #q[we propose a tailored two-level HGS for the SoftCluVRP. Our approach integrates the efficient local search framework and data structures from [21] while restructuring HGS into a two-level algorithm.]
  \ pritaikytas SoftCluVRP/CluVRP VRP variantui
  \ Straipsnyje rezultatai palyginti tik su kitais CluVRP-pritaikytais algoritmais.

== Lygiagretinimas

- "A Parallel Hybrid Genetic Search for the Capacitated VRP with Pickup and Delivery" (2023)
- "Effective Parallelization of the Vehicle Routing Problem" (2023)

== Tikslas ir uždaviniai

*Tikslas* -- Išlygiagretinti hibridinio genetinio paieškos algoritmą, skirto transporto maršrutų optimizavimo uždaviniams spręsti.

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

= Santrumpos

- VRP - #angl_[Vechicle Routing Problem].
- CVRP - #angl_[Capacitated Vehicle Routing Problem].
- VRPTW - #angl_[VRP with Time Windows].
- MVRP - #angl_[Multidepot VRP].
- PVRP - #angl_[Periodic VRP].
  #q(a: [https://neo.lcc.uma.es/vrp/vrp-flavors/periodic-vrp/])[In classical VRPs, typically the planning period is a single day. In the case of the Period Vehicle Routing Problem (PVRP), the classical VRP is generalized by extending the planning period to M days.]
- MDPVRP - #angl_[Multidepot Periodic VRP].
- #todo[CVRP with Backhauls]
- GVRP - #angl_[Generalized VRP] - #q(a: <latorre2025A_hybr>)[In this problem each vertex belongs to a cluster, and only one vertex per cluster must be visited, satisfying the associated cluster demands.]
- CluVRP - #angl_[Clustered VRP] - #q(a: <latorre2025A_hybr>)[In the CluVRP, vehicles must visit all the nodes within a cluster before progressing to the next cluster, instead of visiting just one node per cluster as in the GVRP.]
= Matematinis formulavimas

#todo[TODO]

= Notes

- VRPTW $in$ CVRP
- Specializuota optimizacija specializuotam uždaviniui
  \ #c(<bulhões2018The_ve>)
- #image("img/Screenshot From 2025-09-27 22-41-30.png")
- idea:
  \ implement calculations on GPU to explore all possibilities (probs not faster, but might produce better results)
  #q(a: <vidal2022Hybrid>)[We therefore only evaluate Swap\* moves between 𝑟 and 𝑟′ if the polar
  sectors (from the depot) associated with these routes intercept each
  other. As shown in our computational experiments, with this additional
  restriction, the computational effort needed to explore Swap\* decreases]


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

= Algoritmai

// #table(
//   columns: (auto, auto, auto, auto, auto, auto),
//   table.header([], [PyVRP @PyVRPwouda2024], [HGS-CVRP @vidal2022Hybrid], [@vidal2012A_Hybr], [@latorre2025A_hybr], [@latorre2025An_appHybr]),
//   [Pritaikytas variantams], [#todo[many]], [CVRP], [MDPVRP], [GVRP], [SoftCluVRP],
//   [#todo[Crossover]], [OX _arba_ selective route exchange crossover (SREX)], [ordered crossover (OX) ], [], [], [],
//   [#todo[Diversity]], [], [], [], [], [],
//   [#todo[Repair]], [], [], [], [], [],
//   [#todo[Search]], [], [], [], [], [],
//   [#todo[Stopping criteria]], [], [], [], [], [],
// )

#pagebreak()
#bibliography(title: [Šaltiniai], "bibliography.bib")
