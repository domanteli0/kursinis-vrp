#import "style.typ": style
#import "utils.typ": c, q, tab, todo, mine, note, angl, angl_, br

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

=== HGS

Hibridinis genetinis paieškos (HGS) algoritmas yra vienas iš efektyviausių būdų spręsti transporto maršrutų optimizavimo uždavinius. #todo[[Citation needed?]]

Pirma aprašytas #c(<vidal2012A_Hybr>) ir patobulintas #todo[@vidal2014A_unif, @vidal2016Large_, @vidal2017Node__, @vidal2021Arc_Ro].
- #q(a: <vidal2012A_Hybr>)[#image("img/Screenshot From 2025-09-27 23-07-08.png")]
- #q(a: <vidal2012A_Hybr>)[HGSADC proves to be extremely competitive CVRP.]
- maintains diversity in search -> avoids local minima ir dar aukštesnės kokybės sprendimai ir reduced computational time.

#br

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
- ~2000 eilučių C++ kodo

#br

#c(<latorre2025A_hybr>)
  \ grįstas HGS.
  \ Pritaikytas _Generalized Vehicle Routing Problem_ variantui
  \ #note[Nėra viešo source code].
  \ #q[We show that adapting the meta-heuristic strategies designed for the CVRP to the GVRP can be quite a straightforward process.]
  \ #q[we report the numerical results on the well-known instances problems for both the GVRP and CluVRP.]
  \ Straipsnyje rezultatai palyginti tik su kitais CluVRP, GRVP-pritaikytais algoritmais.

#br

#c(<latorre2025An_appHybr>)
  \ grįstas HGS.
  \ #q[we propose a tailored two-level HGS for the SoftCluVRP. Our approach integrates the efficient local search framework and data structures from [21] while restructuring HGS into a two-level algorithm.]
  \ pritaikytas SoftCluVRP/CluVRP VRP variantui
  \ Straipsnyje rezultatai palyginti tik su kitais CluVRP-pritaikytais algoritmais.

#br

#todo[#c(<rezaei2024Explor>)]
  \ grįstas HGS, pristato naujo algoritmą DPIGA-HGS
  \ #q[In the work herein, DPIGA-HGS is shown to outperform existing state-of-the-art algorithms from the literature]

#pagebreak()

=== Kiti

- "Where to Split in Hybrid Genetic Search for the Capacitated Vehicle Routing Problem"
  \ #q[Results indicate that simple adjustments of the starting point for the splitting procedure can improve the performance of the genetic search, as measured by the average primal gaps of the final solutions obtained, by 3.9%.]

- ACO-grįsti:
  - Multi-strategy ant colony optimization with k-means clustering algorithm for capacitated vehicle routing problem

- "Optimization of Heterogeneous Last-Mile Delivery of Fresh Products Considering Traffic Congestions and Other Real-World Parameters"
  \ The variants considered in this paper are: (CVRP), (VRPTW), (VRPSTW), (HVRP), (MTVRP), (SVRP), (SDVRP), (TDVRP),

- "A systematic literature review on the use of metaheuristics for the optimisation of multimodal transportation"

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
- #todo[TODO: #link("https://www.sciencedirect.com/science/article/abs/pii/S0377221724002923")[A hybrid genetic search and dynamic programming-based split algorithm for the multi-trip time-dependent vehicle routing problem]]

== Lygiagretinimas

- #todo["Pathways to Efficient and Equitable Solutions for Large-Scale Routing Problems" (2025)]
  \ Dar neišleista disertacija - PREVIEW
  \ Pagreitina HGS veikimą naudojant deep learning (ir vėliau jį pritaiko last-mile gig-economy panaudojimui).
  \ #q[The third problem extends the classical Rural Postman Problem (RPP) to a mixed-
  fleet scenario involving multiple trucks and drones, with the objective of minimizing makespan]

- #c(<lei2025Speedi>) "Speeding up Local Optimization in Vehicle Routing with Tensor-based GPU Acceleration"
  #q[In this study, we explore a promising
  direction to address this challenge by introducing an original tensor-based GPU ac-
  celeration method designed to speed up the commonly used local search operators
  in vehicle routing.]
  #q[[25] proposed a hybrid genetic algorithm integrating 2-opt local search to solve
  the capacitated VRP on GPU. The GPU was used to handle all algorith-
  mic components, including population initialization, reproduction, 2-opt local
  search, and refining processes. [26] developed a GPU-based multi-objective
  memetic algorithm for the VRP with route balancing. They proposed two
  schemes for the parallelism: solution-level parallelism, where multiple solutions
  were processed using parallel local search, and route-level parallelism, which
  provided a finer granularity by parallelizing route level evaluations. However,
  their method did not exploit the finer node-level parallelism commonly used
  in neighborhood evaluations.
  [27] explored GPU-based parallelization of 2-opt and 3-opt local search opera-
  tors for the CVRP, achieving significant speedups over CPU implementations.
  Similarly, [28] extended GPU-based local search for the CVRP by incorporat-
  ing additional operators such as or-opt, swap, and relocate, achieving compa-
  rable improvements in computational performance. However, their methods
  were limited to the basic travel distance evaluation. [29] addressed the single
  VRP with deliveries and selective pickups using a GPU-based variable neigh-
  borhood search, where the GPU was also tasked with parallel neighborhood
  evaluations. Despite incorporating multiple local search operators, their ap-
  proach primarily optimized the evaluation of travel distance and struggled to
  effectively manage complex constraints.]
  [25]: "M. F. Abdelatti, M. S. Sodhi, An improved gpu-accelerated heuristic technique
  applied to the capacitated vehicle routing problem, in: Proceedings of the 2020
  Genetic and Evolutionary Computation Conference, 2020"

  #q[We present the first innovative
  tensor-based GPU acceleration method that can be embedded in local search
  algorithms for solving various VRPs.]

  #q[Our tensor-based GPU acceleration (TGA) method is highly extensible and
  can be integrated into various local search based algorithms and frameworks.]

  #q[we incorporated TGA into the MA-FIRD algorithm]

    - #highlight(fill: red.lighten(50%))[NĖRA SOURCE CODE]
    - #note[PREPRINT]
    - ypatingas pagreitėjimas su ypač dideliais duomenų kiekiais
    - pritaikytas šiem _local search operators_ (Relocate, Swap, 2-opt\*, and 2-opt)
    - *IDEA: Pritaikyti HGS* (ir Swap\* ? reiktų pasidomėt ar Swap ir Swap\* tas pats dalykas)
      \ Neaišku, kuriam VRP variantui, tikriausiai CVRP
      \ Galimai bus sunku pritaikyti HGS:
      \ #q[the current design of the tensor representation of solutions doesn’t
      support easy implementation of pruning strategies and neighborhood reduc-
      tion techniques that are often used in local search-based routing algorithms.]

#br

- "A Parallel Hybrid Genetic Search for the Capacitated VRP with Pickup and Delivery" (2023)

  #q[In our paper A Hybrid Genetic Algorithm for Solving the VRP with Pickup and
  Delivery in Rural Areas, we introduced an adapated gene transfer limiting the
  amount of possible mutations in each generation. ]

  #q[Here, several heuristic
  methods are combined in an iterative process to find the most optimal solution
  to the problem [4].]

  #q[Yelmewad and Talawar use a parallel version of the Local Search heuristic, for
  solving the Capacitated Vehicle Routing Problem (CVRP) [7].]

  #q[In "A Multi-GPU Parallel Genetic Algorithm For Large-Scale Vehicle Rout-
  ing Problems" Abdelatti et al. consider solving VRPs using GAs on high-
  performance computing (HPC) platforms with up to 8 GPUs. The authors focus
  on VRPs with up to 20, 000 nodes. To achieve the maximum degree of paral-
  lelism, each array of the algorithm is mapped to block threads to achieve high
  throughput and low latency [9].]

  - [4]: B. D. Backer, V. Furnon, P. Shaw, P. Kilby, and P. Prosser, "Solving vehicle routing problems using constraint programming and metaheuristics," vol. 6, no. 4, pp. 501--523.
  - [7]: "Parallel Version of Local Search Heuristic Algorithm to Solve Capacitated Vehicle Routing Problem" (2021)
  - [9]: "A multi-gpu parallel genetic algorithm for large-scale vehicle routing problem" (2022)

  #q[#image("img/Screenshot From 2025-10-28 22-51-12.png")]

  #q[#image("img/Screenshot From 2025-10-29 01-43-32.png")]

  - Grįstas HGS.
  - padalina darbus per kelis įrenginius/GPUs? ("nodes" straipsnyje) naudojant MPI.
    \ Naudoja CUDA, kad lygiagretinti LS.
    - Reikalauja kelių node'ų kiekvienas su GPU.
  - nėra rezultatų palyginimų, su pvz.: BKS
  - palyginimas su Tabu search grįstu algoritmu, ne HGS
  - Nėra SOURCE CODE: AWAITING RESPONSE

#br

- #c(<muniasamy2023Effect>)
  - ~1500 eilučių C++ kodo (https://github.com/mrprajesh/parMDS)

  #q[The state-of-the-art GPU
  implementations are due to Yelmewad and Talawar [35], and Abde-
  latti and Sodhi [1].]

  [1]: 2020. An improved GPU-accelerated heuristic technique applied to the capacitated vehicle routing problem.

  [35]: 2021. Parallel Version of Local Search Heuristic Algorithm to Solve Capacitated Vehicle Routing Problem.

  #q[#image("img/Screenshot From 2025-11-01 17-55-54.png")]

  [25]: 2018. A CPU-GPU Parallel Ant Colony Optimization Solver for the Vehicle Routing Problem

  Naudojimas OpenMP pagreitinimui naudojant CPU (shared-memory).

  Ganėtinai paprastas algoritmas, pagrinde naudojamas Local Search, iš esmės lygiagretinima ties kiekvienu bandymu ieškoti sprendimo:

  #q[ #image("img/Screenshot From 2025-11-01 18-40-13.png") ]

  Hmmmmm:

  #q[We plan to develop a
  GPU-parallel version of the proposed method to further enhance
  performance. On the algorithmic front, we plan to build direction-
  awareness into the current scheme, and add inter-route refinement
  strategies to better the solution quality of ParMDS.]



== Tikslas ir uždaviniai

*Tikslas* -- Išlygiagretinti hibridinio genetinio paieškos algoritmą, skirto transporto maršrutų optimizavimo uždaviniams spręsti.

*Uždavinai:*

1. Išsirinkti duomenų rinkinį pagal, kurį galima būtų testuoti/analizuoti sprendimus, pvz.:
  - tikriausiai CVRPLIB repository (repository of BKSs - Best Known Solutions) (https://vrp.galgos.inf.puc-rio.br/index.php/en/)
  - Solomon
  - Neural Combinatorial Optimization for Real-World Routing (2025)
  - Test-data generation and integration for long-distance e-vehicle routing (2023)
  - #c(<uchoa2017New_be>)
  - #q(a: <lei2025Speedi>)[For the CVRP and VRPTW, the BKS values are obtained
  from the CVRPLIB repository (http://vrp.galgos.inf.puc-rio.br/) as of
  April 30, 2025. For the CVRP, we use results from HGS-2012 [38] and HGS-
  CVRP [14]. For the VRPTW, with the objective of minimizing the total travel
  distance, we reference results from the DIMACS competition, including both
  the official DIMACS reference results and the champion team’s algorithm,
  HGS-DIMACS [39]. For the VRPSPDTW, we report the best results from the
  state-of-the-art MA-FIRD method [32].]
2. Išanalizuoti, kaip veikia HGS algoritmas
3. Atrinkti paralelizuojamas dalis, ar dalis, kurias galima galima pakeisti paralelizuojamomis
3. Palyginti rezultatus su kitais state-of-the-art algoritmais

= Santrumpos

- VRP - #angl_[Vechicle Routing Problem].
- CVRP - #angl_[Capacitated Vehicle Routing Problem].
  #q(a: [@stadtler2023parallel])[the CVRPPD divides stops
  into pickup and delivery points for passengers. Passengers are not arbitrary goods
  delivered to interchangeable destinations from a common depot, but they have
  individual starting points and destinations. Therefore, the pickup and delivery
  constraint has multiple implications. On the one hand, the order in which a
  person is picked up and dropped o by a vehicle must be in the correct order. In
  addition, the delivery must be performed by the same vehicle as the pickups]
- VRPTW - #angl_[VRP with Time Windows].
- CVRPPD - #angl_[CVRP Pickup and Delivery].
- MVRP - #angl_[Multidepot VRP].
- PVRP - #angl_[Periodic VRP].
  #q(a: [https://neo.lcc.uma.es/vrp/vrp-flavors/periodic-vrp/])[In classical VRPs, typically the planning period is a single day. In the case of the Period Vehicle Routing Problem (PVRP), the classical VRP is generalized by extending the planning period to M days.]
- MDPVRP - #angl_[Multidepot Periodic VRP].
- #todo[CVRP with Backhauls]
- GVRP - #angl_[Generalized VRP] - #q(a: <latorre2025A_hybr>)[In this problem each vertex belongs to a cluster, and only one vertex per cluster must be visited, satisfying the associated cluster demands.]
- CluVRP - #angl_[Clustered VRP] - #q(a: <latorre2025A_hybr>)[In the CluVRP, vehicles must visit all the nodes within a cluster before progressing to the next cluster, instead of visiting just one node per cluster as in the GVRP.]
- VRPSPDTW - #angl_[VRP with Simultaneous Pickup and Delivery and Time Windows]
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

// = The bad list
// - A Hybrid Approach for Simultaneous Effective Automobile Navigation with DE and PSO (2024)
