#import "style.typ": style
#import "utils.typ": c, q, qi, tab, todo, mine, note, angl, angl_, br
#import "table1.typ": *
#import "diagrams/gap_threads.typ": gap_speedup_plot, gap_threads_plot, gap_time_plot
#import "diagrams/hgs_flowchart.typ": hgs_flowchart
#import "@preview/drafting:0.2.2": *
#import "@preview/cetz:0.4.2": canvas, draw
#import "@preview/cetz-plot:0.1.3": plot, chart

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

- Populiacija - Rinkinys invididų.
- Individas - Užduoties sprendimas t.y. rinkinys maršrutų.

= Santrumpos <santr>

- VRP - Martšrutų optimizavimo uždavinys #angl[Vechicle Routing Problem].
- CVRP - #angl_[Capacitated Vehicle Routing Problem]. Kiekviena transporto priemonė turi maksimalią siuntų talpą.
- VRPTW - #angl_[VRP with Time Windows].
- GVRP - #angl_[Generalized VRP]. Taškai grupuojami į klusterius. Tik vienas taškas iš viso klusterio turi būti aplankytas.
- CluVRP - #angl_[Clustered VRP]. Taškai grupuojami į klusterius. Visi taškai klusteryje turi būti aplankyti prieš važiuojant į kitą klusterį.
- SoftCluVRP - #angl_[Clustered VRP]. Taškai grupuojami į klusterius. CluVRP variantas, kuriame į klusterį leidžiama aplankyti kelis kartus.
- MDVRP - #angl_[Multidepot VRP].
- PVRP - #angl_[Periodic VRP]. Pridedama laiko dimescija, t.y. išmetama presumpcija, kad visi taškai turi būti vienu kartu, sprendimas susidaro iš kelių maršrutų rinkinių atitinkačius dienas, kuriomis bus aplankomi taškai.
- MDPVRP - #angl_[Multidepot Periodic VRP]. MDVRP ir PVRP kombinacija.
- CVRPPD - #angl_[CVRP Pickup and Delivery]. CVRP ir VRPPD kombinacija.

= Įvadas

VRP -- Transporto maršrutų optimizavimo uždavinys #angl[Vehicle Routing Problem] yra uždavinys,
kurio tikslas yra surasti kuo optimaliausią maršrutų rinkinį.  #todo[TODO: Čia dar reikia pasidomėti iš ko tiksliai susideda COST funkcija]. Optimaliai parinkti maršrutai gali lemti kiek taškų įmanoma aplankyti per nustatytą laiką, sumažinti transporto kaštus.
Pirmą kartą ši problema aprašyta @dantzig1959The_Tr, kur autorius aprašė algoritmą, kuris suranda optimalius maršrutus tarp kuro depo ir degalinių.
Tai yra modernios logistikos optimizavimo uždavinys -- optimaliai parinkti maršrutai gali lemti mažesnius kainos ir pristatymo laiko kaštus.

Kur keliaujančio pardavėjo uždavinyje pagrindinė užduotis yra surasti optimaliausią kelią vienam keliautojui -- pardavėjui,
VRP sprendimai susidaro iš kelių keliautojų -- literatūroje dažnai tiesiogiai vadinama transporto priemonėmis.

Nors egzistuoja įrankiai, kurie pasiteklia tikslius metodus (pavyzdžiui "Google or-tools" @ortools), kadangi šis uždavinys priklauso #todo[NP-Hard] sudėtingumo klasei, visgi dominuoja heuristikomis ir metaheuristikomis grįsti algoritmai #todo[[CITATION NEEDED]], nes šie beveik optimalius sprendimus suranda per greitesnį laiko tarpą sunaudodami mažiau resursų. Tikslūs metodai su ypač dideliais kiekiais duomenų tampa nepraktiški #todo[[CITATION NEEDED]]. Metaheuristiniai algoritmai išsiskiria šioje uždavinių klasėje kaip efektyviausi, pasižymintys žemu algoritmo vykdymo laiku ir aukšta uždavinių rezultatų kokybe.

Praktikoje taikomos VRP variacijos (CVRP, VRPTW, MDPVRP, PVRP ir kt.)
įveda papildomus apribojimus maršrutų ilgiui, transporto priemonių panaudojimo laikui ir talpai,
ar prideda papildomas salygas:
- naudojamos transporto priemonės turi limituotą talpą (CVRP).
- visi taškai turi gali būti aplankyti tik specifinėmis darbo valandomis (VRPTW)
- keli depai iš kurių galima pradėti maršrutą (MDVRP),
- maršrutai planuojami per kelias dienas, t.y. vieni taškai gali būti aplankyti vieną dieną, o kiti kitą. (Periodic VRP).
- kt.

Šis darbas atsižvelgia tik į CVRP uždavinį.

Šiai problemai egzistuoja heuristiniai ir metaheuristinai (Aukštesnio lygio strategija/karkasas, kuris diriguoja, kurias heuristikas pritaikyti, kad efektyviau atrasti sprendimus) algoritmai. Keli dominuojantys pavyzdžiai @adamo2024A_revi

  - "Adaptive Large Neighborhood Search" ir "Hybrid Adaptive Large Neighborhood Search"

  - "Hybrid Genetic Search (HGS)"

  - "Simulated Annealing Algorithm (SAA)"

  - "Ant colony optimization (ACO)"

Hibridinis genetinis paieškos (#angl[Hydrid Genetic Search -- HGS]) -- yra vienas iš efektyviausių genetinių metaheuristinių algoritmų @petropoulos2023Operat. Šis algoritmas ir vėlesnės pagerintos versijos išlieka etalonas daugeliui VRP variantų, "DIMACS" konkurse @dimacs2022vrp parodęs geriausius rezultatus VRPTW uždavinyje @kool2022hybrid, ir kurio modifikuotas variantas @jiang2022fhcsolver pasirodė geriausiai CVRP uždavinyje. Šis algoritmas yra pritaikytas CVRP, VRPTW, GVRP @latorre2025A_hybr, CluVRP, SoftCluVRP @latorre2025An_appHybr.

Šio *darbo tikslas* -- išlygiagretinti hibridinio genetinio paieškos algoritmą, skirto transporto maršrutų optimizavimo uždaviniams spręsti,
siekiant sumažinti vykdymo laiką neprarandant ar net pagerinant sprendimų kokybės.

*Uždavinai:*

#note[
  1. Išsirinkti duomenų rinkinį pagal, kurį galima būtų testuoti/analizuoti sprendimus, pvz.:
    - tikriausiai CVRPLIB repository (repository of BKSs - Best Known Solutions) (https://vrp.galgos.inf.puc-rio.br/index.php/en/)
    - Solomon
    - Neural Combinatorial Optimization for Real-World Routing (2025)
    - Test-data generation and integration for long-distance e-vehicle routing (2023)
    - #c(<uchoa2017>)
    - #q(a: <lei2025Speedi>)[For the CVRP and VRPTW, the BKS values are obtained
    - @jastrzab2024Standa [3/1337 psl.]
    from the CVRPLIB repository (http://vrp.galgos.inf.puc-rio.br/) as of
    April 30, 2025. For the CVRP, we use results from HGS-2012 [38] and HGS-
    CVRP [14]. For the VRPTW, with the objective of minimizing the total travel
    distance, we reference results from the DIMACS competition, including both
    the official DIMACS reference results and the champion team’s algorithm,
    HGS-DIMACS [39]. For the VRPSPDTW, we report the best results from the
    state-of-the-art MA-FIRD method [32].]
  2. Išanalizuoti, kaip veikia HGS algoritmas
  3. Atrinkti paralelizuojamas dalis, ar dalis, kurias galima galima pakeisti paralelizuojamomis
  4. Palyginti rezultatus su kitais state-of-the-art algoritmais

    // 1. Parinkti tinkamus (hyper-) parametrus (see @jastrzab2024Standa [3/1337 psl.])
]

#pagebreak()

// = Užduoties apibrėžimas

// #todo[== Kokybės, COST, diversity apibrėžimas]

= HGS algoritmo veikimas

Pirma aprašytas #c(<vidal2012A_Hybr>) skirtas spręsti MDPVRP. Patobulintas per daugelį iteracijų: @vidal2014A_unif, @vidal2016Large_, @vidal2017Node__, @vidal2021Arc_Ro, @vidal2022Hybrid ir pritaikytas CVRP.
- #q(a: <vidal2022Hybrid>)[Beyond a simple reimplementation of the original algorithm, HGS-
CVRP takes advantage of several lessons learned from the past decade
of VRP studies: it relies on simple data structures to avoid move reevaluations and uses the optimal linear-time Split algorithm of Vidal
(2016). Moreover, its specialization to the CVRP permits significant
methodological simplifications. In particular, it does not rely on the visit-pattern improvement (PI) operator (Vidal et al., 2012) originally
designed for VRPs with multiple periods, and uses instead a new neighborhood called Swap\*.]
- #q(a: <vidal2022Hybrid>)[In HGS-CVRP, we rely on the efficient linear-time Split algorithm introduced by Vidal (2016) #mine[@VIDAL2016] after each crossover operation.]

Genetiniai algoritmai imituoja evoliucijos procesą. Populiacija yra aibė, kurią sudaro individai (t.y. užduoties sprendimai). Šie algoritmai naudoja įvairius kryžminimo operatorius, kurie iš kelių individų populiacijoje sukuria naują, mutuotą individą ir prideda prie populiacijos. Prastos kokybės ir panašūs individai (sprendimai) vykdimo eigoje yra pašalinami iš populiacijos.

Genetinis hydridinis paieškos algoritmas prie genetinio komponento prideda pagerinimo žingsnį (vietinę paiešką #angl[local search]), kuri po kryžminimo žinsnio yra pritaikoma naujam individui, kad pagerinti gautą individo kokybę.

Vietinėje paieškoje taikomos _relocate_, _2-opt_, _2-opt\*_, bei  _swap\*_ heuristikos.

Palaikant neįvykdomus #angl[infeasible] ir įvykdomus #angl[feasible] sprendimus, palaikoma populiacijos įvairovė #angl[diversity], kuri leidžia išvengti lokalios minimos #angl[local minima] iteruojant per sprendimus.

#figure(
  caption: [HGS algoritmo pseudokodas @vidal2012A_Hybr]
)[
  #let alg-line(num, body, indent: 0, bar: false) = {
    let stroke = if bar { (left: 0.4pt + gray) } else { none }
    grid(
      columns: (auto, 1fr),
      row-gutter: 0em,
      align: top,
    )[
      #text(weight: "semibold")[#num]
      #box(stroke: stroke, inset: (left: indent * 0.85em))#body
    ]
  }

  #block(
    stroke: black,
    inset: 0.55em,
    fill: luma(98%),
    radius: 2pt,
    spacing: 0.5em,
  )[
    #set par(leading: 0.4em, first-line-indent: (amount: 0cm))

    #align(left)[
      #stack(
        spacing: 0.3em,
        alg-line("1", [Sugeneruoti pradinę populiaciją ir pagerinti ją vietine paieška]),
        alg-line("2", [*Kol* iteracijų be pagerėjimo skaičius mažesnis už ribą ir $t < T_max$ atlikti], bar: true),
        alg-line("3", [Pasirinkti tėvinius sprendimus (dvejetainis turnyras #angl[binary tournament])], indent: 1, bar: true),
        alg-line("4", [Atlikti kryžminimą #angl[crossover]], indent: 1, bar: true),
        alg-line("5", [Išmokyti naują individą (vietinė paieška)], indent: 1, bar: true),
        alg-line("6", [Įterpti išmokytą invdividą į atitinkamą subpopuliaciją], indent: 1, bar: true),
        alg-line("7", [*Jeigu* individas neįvykdomas:], indent: 1, bar: true),
        alg-line("8", [Su 50% tikimybe bandyti sutaisyti individą ir įtraukti į atitinkamą subpopuliaciją], indent: 2, bar: true),
        alg-line("9", [*Jeigu* pasiektas maksimalus aibės dydis:], indent: 1, bar: true),
        alg-line("10", [pašalinti blogiausius ir neįvairius individus iš populiacijos], indent: 2, bar: true),
        alg-line("11", [Patikslinti baudos parametrus #angl[penalty parameters]], indent: 1, bar: true),
        alg-line("12", [Grąžinti geriausią įvykdomą sprendimą]),
      )
    ]
  ]
] <algo>

#figure(
  caption: [HGS veikimas @vidal2022Hybrid]
)[#scale(60%)[#hgs_flowchart]]
#todo[TODO: Išversti į lietuvių k.???]

= Literatūros analizė

// Platesnė VRP lygiagretinimo panorama aptariama apžvalginiuose darbuose @jastrzab2024Standa.

// GPU metodai dažniausiai orientuojasi į 2-opt, Swap ir susijusių operatorių spartinimą, tačiau daugelyje darbų optimizuojamas tik kelionės ilgio įvertinimas, o sudėtingesnių apribojimų apdorojimas lieka ribotas @lei2025Speedi, @abdelatti2020An_imp, @muniasamy2023Effect. Vis dėlto nemaža dalis pagreitinimų neturi viešo kodo ar detalių palyginimų su BKS, todėl jų pritaikomumas HGS kontekste (pvz., su Swap\* operatoriumi) išlieka atvira problema @vidal2022Hybrid.

@lei2025Speedi lygiagretinimui vietinės paieškios algoritmą išreiškia tenzorių operatoriais, tai leidžia HGS vykdymą perkelti ant GPU. Taip pagreitintas vietinės paieškos operatorius.
Tačiau @lei2025Speedi pasiūlytas metodas nėra pritaikomas HGS su swap\*.
#qi[Dabartinė sprendimų reprezentacija per tensorius neleidžia lengvai įgyvendinti apkarpymo strategijų kaimynysčių sumažinimo technikų, kurie dažnai yra naudojami vietinės paieškos grįstais algoritmais.][the current design of the tensor representation of solutions doesn’t support easy implementation of pruning strategies and neighborhood reduction techniques that are often used in local search-based routing algorithms.]

@stadtler2023parallel HGS pritaiko CVRPPD, perkelia tėvų pasirinkimo #angl[selection], kryžminimo #angl[crossover] ir taisymo #angl[repair] žingsnius į atskiras gijas. Kiekviena gija papildomai atlieka vietinę paiešką (_2-opt_, _relocate_, _swap_) pasitelkiant GPU, tačiau nepasitelkia _swap\*_ heuristika, kuri pagal @vidal2022Hybrid padeda surasti aukštesnės kokybės sprendimus.

Priešintai nei dauguma implementacijų @muniasamy2023Effect naudoja grafų duomenų struktūras, panaudojami tik _2-opt_ ir arčiausio kaimyno heuristikos #angl[nearest-neighbor]. Šios heuristikos pritaikytos vykdymui GPU aplinkoje naudojant CUDA.

#figure(
  caption: [HGS lygiagretintas @stadtler2023parallel]
)[#image("img/611509_1_En_8_Fig3_HTML.webp", width: 50%)]

@yelmewad2021Parall pasitelkia GPU lygiagretinimui. Kiekvienam maršrutui skiriama atskira GPU gija, kuri vykdo vietinės paieškos žingsnį naudojant GPU. Šiuo metodu pilnas resursų išnaudojimas priklauso nuo to ar sukurtų maršrutų skaičius sutampa su gijų skaičiumi. Atvejai, kai vietinės paieškos žingsniai modifikuoja kitų maršrutų sprendimą, gijos įrašo savo sprendimą į atskirą masyvą, kuris vėliau yra redukuojamas į vieną sprendimą, pasirenkant geriausią sprendimą. Analogiškai, vėlesnėme žingsnyje kiekvienam taškui priskiriama gija. Kiekviena gija apskaičiuoja pagerėjimą ar pablogėjimą apsikeistus vietą maršrute su kitu tašku.

@jamshidi2025A_Para kombinuoja HGS su salų modeliu, aprarašytu @rezaei2024Explor, kur kiekviena gija, vykdo tą patį HGS algoritmą, pridedamas individų migracijos žingsnis, kuris leidžia keistis sprendimais tarp gijų.
// TODO: pridėti migracijos aprašymą.

#figure(
  caption: [HGS su salų modeliu @jamshidi2025A_Para]
)[#image("img/44196_2025_1059_Fig5_HTML.webp", width: 50%)]

= Lygiagretinimas

Paimta @vidal2022Hybrid HGS algoritmo implementacija#footnote[Nuolatinė repozitoriją nuoroda https://github.com/vidalt/HGS-CVRP/tree/1a927955cd2861a29d978f0d359d6e647db9319c], kuri naudojama kiap pagrindas lygiagretinimui.

Daugiausiai laiko užima vietinės paieškos žingsnis @jamshidi2025A_Para, šio autoriaus atliktais matavimais vietinė paieška užima 85% vykdymo laiko. Todėl siekiant sumažinti viso HGS algoritmo vykdymo laiką šį žingsnį yra labiausiai verta lygiagretinti.

Lygiagretinimas įgyvendintas kiekvienai gijai, atliekant vietinę paiešką. Lygiagretinta HGS-CVRP versija pavaizduota @algo_parallel. Nuosekliai veikiančioje sekcijoje parenkami skirtingi tėviniai individai ir , kryžminimo metu sukuriami individai kiekvienai gijai. Tada kiekviena gija lygiagrečiai atlieka vietinės paieškos žingsnį. Vėliau, kai kiekviena gija atlieka šį žingsnį, individai yra pridedami į visų populiaciją.

#figure(
  caption: [HGS algoritmo pseudokodas @vidal2012A_Hybr]
)[
  #let alg-line(num, body, indent: 0, bar: false) = {
    let stroke = if bar { (left: 0.4pt + gray) } else { none }
    grid(
      columns: (auto, 1fr),
      row-gutter: 0em,
      align: top,
    )[
      #text(weight: "semibold")[#num]
      #box(stroke: stroke, inset: (left: indent * 0.85em))#body
    ]
  }

  #block(
    stroke: black,
    inset: 0.55em,
    fill: luma(98%),
    radius: 2pt,
    spacing: 0.5em,
  )[
    #set par(leading: 0.4em, first-line-indent: (amount: 0cm))

    #align(left)[
      #stack(
        spacing: 0.3em,
        alg-line("1", [Sugeneruoti pradinę populiaciją ir pagerinti ją vietine paieška]),
        alg-line("2", [*Kol* iteracijų be pagerėjimo skaičius mažesnis už ribą ir $t < T_max$ atlikti], bar: true),
        alg-line("3", [Pasirinkti $N*2$#footnote[N -- gijų skaičius] tėvinių sprendimų (dvejetainis turnyras #angl[binary tournament])], indent: 1, bar: true),
        alg-line("4", [Atlikti kryžminimą #angl[crossover] N kartų], indent: 1, bar: true),
        alg-line("5", [(Kiekienoje gijoje) išmokyti naują individą], indent: 1, bar: true),
        alg-line("6", [Įterpti išmokytą invdividą į atitinkamą subpopuliaciją], indent: 1, bar: true),
        alg-line("7", [*Jeigu* individas neįvykdomas:], indent: 1, bar: true),
        alg-line("8", [(Kiekvienoje gijoje) su 50% tikimybe bandyti sutaisyti individą ir įtraukti į atitinkamą subpopuliaciją], indent: 2, bar: true),
        alg-line("9", [*Jeigu* pasiektas maksimalus aibės dydis:], indent: 1, bar: true),
        alg-line("10", [pašalinti blogiausius ir neįvairius individus iš populiacijos], indent: 2, bar: true),
        alg-line("11", [Patikslinti baudos parametrus #angl[penalty parameters]], indent: 1, bar: true),
        alg-line("12", [Grąžinti geriausią įvykdomą sprendimą]),
      )
    ]
  ]
] <algo_parallel>

#todo[TODO: praplėsti ir padaryti diagramą]

// @jastrzab2024Standa siūlo metodiką kaip lyginti algoritmus tarpusavyje, taip kad jie kuo tiksliau atitiktų rezultatus realybėje.

// - A Multi-GPU Parallel Genetic Algorithm For Large-Scale Vehicle Routing Problems
// - 2020 An Improved GPU-Accelerated Heuristic Technique Applied to the Capacitated Vehicle Routing Problem
// - 2022 A Multi-GPU Parallel Genetic Algorithm For Large-Scale Vehicle Routing Problems

// = Greitaveikos nagrinėjimas

// Dideliems duomenų rinkiniams net HGS didžiąją laiko dalį skiria lokaliai paieškai #todo[TODO: pateikti skaičius???] #angl[Local Search].
// - GPU pagreitinti 2-opt/Swap operatoriai @lei2025Speedi,

// = Pavyzdinių duomenų rinkiniai ir rezultatų palyginimas

// Algoritmų kokybei vertinti plačiai naudojami _de facto_ standartizuoti rinkiniai @petropoulos2023Operat:  geriausių sprendinių #angl[Best Known Solution -- BKS] rinkiniai, pavyzdžiui "CVRPLIB" @uchoa2017.

= Metodika

// #q(a: <rezaei2024Explor>)[
//   The algorithm’s
//   effectiveness is demonstrated through several experiments on diverse benchmark instances, including classical benchmarks
//   (Uchoa, CMT, and Golden) and #note[real-world application instances (LoggiBUD)].
// ]

#footnote[https://galgos.inf.puc-rio.br/cvrplib/index.php/en/instances, prieigos data: 2026-01-07]

Parinkti duomneų rinkiniai:
- Uchoa @uchoa2017 // CMT @CMT2017, Golden @Golden2017

Dėl rezultatų palyginamumo pasirinkta naudoti @vidal2022Hybrid aprašytus duomenų rinkinius ir metodiką.
#q[We monitor each algorithm’s progress up to a time limit of $𝑇_"max" = 𝑛 × 240∕100$ seconds, where 𝑛 represents the number of customers.
Therefore, the smallest instance with 100 clients is run for 4 minutes,
whereas the largest instance containing 1000 clients is run for 40
minutes. During each run, we record the best solution value after
1%, 2%, 5%, 10%, 15%, 20%, 30%, 50%, 75%, and 100% of the
time limit to measure the performance of the algorithms at different
stages of the search. ]

_Gap_ apbidrėžimas.

$
  "Gap" &= ((Z_s - Z_"BKS") / Z_"BKS") dot 100% \
  Z_s &= #[Algoritmo sprendimo kaina] \
  Z_"BKS" &= #[Geriausio sprendimo kaina]
$

#todo[TODO: sprendimo kaina/COST apibrėžimas]

= Rezultatai

#todo[TODO: pateikti rezultatus]

#figure(
  caption: [Sprendimo kokybė pagal gijų skaičių. Gap apskaičiuojamas pagal BKS, o x ašis rodo vykdymo laiką procentais.]
)[#block(width: 25%)[#gap_threads_plot()]]

#figure(
  caption: [Sprendimo kokybės santykis tarp viengijio ir N gijų sprendimų (Gap(1 gija) / Gap(N gijų)) priklausomai nuo vykdymo laiko.]
)[#block(width: 25%)[#gap_speedup_plot()]]


Iš rezultatų matyti, kad užduočių kokybė t.y. COST nesumažėjo, tačiau vykdymo laikas sumažėjo X kartų iki Y gijų skaičiaus, daugiau didinant gijų skaičių vykdymo laikas vidutiniškai pakilo X kartų

// #q()[An up-to-date survey on recent trends can be
//   found in Vidal et al. (2020) [@vidal2020A_conc]]

// @petropoulos2023Operat
//   #q()[
//   A more recent set of instances and best known solutions is available in Queiroga et al. (2022), where the authors provide data enabling the use of machine learning approaches to solve the CVRP. Accorsi et al.
//   (2022) present the standard practices to test CVRP algorithms: how to determine computing time (typically on a single thread), common ways of tuning parameters, and providing best and average solutions on a specified number of executions, among others.
//   ]

= Išvados

#todo[TODO]

= Priedai

#show figure.where(kind: table): set block(breakable: true)
#figure(
  block(breakable: true, width: 115%)[#table1],
  caption: [Mažiausios pasiektos sprendimų kainos ir Gap]
)

#pagebreak()
#bibliography(title: [Šaltiniai], "bibliography.bib")

// = The bad list
// - A Hybrid Approach for Simultaneous Effective Automobile Navigation with DE and PSO (2024)
