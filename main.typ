#import "style.typ": style
#import "utils.typ": c, q, qi, tab, todo, mine, note, angl, angl_, br
#import "@preview/drafting:0.2.2": *

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
- Individas - #todo[Individual solution (i.e. set of routes and points assigned to them)]

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

= TODO

- .

= Įvadas

VRP -- Transporto maršrutų optimizavimo uždavinys #angl[Vehicle Routing Problem] yra uždavinys,
kurio tikslas yra surasti kuo optimaliausią maršrutų rinkinį.  #todo[TODO: Čia dar reikia pasidomėti iš ko tiksliai susideda COST funkcija]. Optimaliai parinkti maršrutai gali lemti kiek taškų įmanoma aplankyti per nustatytą laiką, sumažinti transporto kaštus.
Pirmą kartą ši problema aprašyta @dantzig1959The_Tr, kur autorius aprašė algoritmą, kuris suranda optimalius maršrutus tarp kuro depo ir degalinių.
Tai yra modernios logistikos optimizavimo uždavinys -- optimaliai #todo[sudelioti] maršrutai gali lemti mažesnius kainos ir pristatymo laiko kaštus.

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

Hibridinis genetinis paieškos (#angl[Hydrid Genetic Search -- HGS]) -- yra vienas iš efektyviausių genetinių metaheuristinių algoritmų @petropoulos2023Operat. Šis algoritmas ir vėlesnės pagerintos versijos išlieka etalonas daugeliui VRP variantų, "DIMACS" konkurse @dimacs2022vrp parodęs geriausius rezultatus VRPTW uždavinyje @kool2022hybrid, ir kurio modifikuotas variantas @jiang2022fhcsolver pasirodė geriausiai CVRP uždavinyje. Šis algoritmas yra pritaikytas CVRP, VRPTW, GVRP @latorre2025A_hybr, CluVRP, SoftCluVRP @latorre2025An_appHybr, #todo[k.t.].

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

    1. Parinkti tinkamus (hyper-) parametrus (see @jastrzab2024Standa [3/1337 psl.])
]

#pagebreak()

// = Užduoties apibrėžimas

// #todo[== Kokybės, COST, diversity apibrėžimas]

= HGS algoritmo veikimas

Pirma aprašytas #c(<vidal2012A_Hybr>) skirtas spręsti MDPVRP. Patobulintas per daugelį iteracijų: #todo[@vidal2014A_unif, @vidal2016Large_, @vidal2017Node__, @vidal2021Arc_Ro, @vidal2022Hybrid] ir pritaikytas CVRP.
- #q(a: <vidal2022Hybrid>)[Beyond a simple reimplementation of the original algorithm, HGS-
CVRP takes advantage of several lessons learned from the past decade
of VRP studies: it relies on simple data structures to avoid move reevaluations and uses the optimal linear-time Split algorithm of Vidal
(2016). Moreover, its specialization to the CVRP permits significant
methodological simplifications. In particular, it does not rely on the visit-pattern improvement (PI) operator (Vidal et al., 2012) originally
designed for VRPs with multiple periods, and uses instead a new neighborhood called Swap\*.]
- #q(a: <vidal2022Hybrid>)[In HGS-CVRP, we rely on the efficient linear-time Split algorithm introduced by Vidal (2016) #mine[@VIDAL2016] after each crossover operation.]

Genetiniai algoritmai imituoja evoliucijos procesą. Populiacija yra aibė, kurią sudaro individai (t.y. užduoties sprendimai). Šie algoritmai naudoja įvairius kryžminimo operatorius, kurie iš kelių individų populiacijoje sukuria naują, mutuotą individą ir prideda prie populiacijos. Prastos kokybės ir panašūs individai (sprendimai) vykdimo eigoje yra pašalinami iš populiacijos.

Genetinis hydridinis paieškos algoritmas prie genetinio komponento prideda pagerinimo žingsnį (lokalią paiešką), kuri po kryžminimo žinsnio yra pritaikoma mutuotam individui, kad pagerinti gautą individo kokybę.

Lokalioje paieškoje taikomos _relocate_, _2-opt_, _2-opt\*_, bei  _swap\*_ heuristikos.

It carefully applies a combination of well-known local search
heuristics, and also proposes an efficient inter-route refinement
heuristic called SWAP

Palaikant neįvykdomus #angl[infeasible] ir įvykdomus #angl[feasible] sprendimus, palaikoma populiacijos įvairovė #angl[diversity], kuri leidžia išvengti lokalios minimos #angl[local minima] iteruojant sprendimais #todo[iteruojant per sprendimus???].

#figure[
  #align(left)[#block(stroke: black, inset: 0.5em)[
    #set par(leading: 0.75em, first-line-indent: (amount: 0cm))
    *HGS algoritmo pseudokodas* @vidal2012A_Hybr

    1: Sugeneruoti pradinę populiaciją \
    2: Kol $"iteracijų skaičius be sprendimo pagerėjimo " <  "ir kol nepraėjo laiko limitas"$ \ // "It"_("NI")$ ir $"time" < T_max$ \
      3: Pasirinkti tėvinius sprendimus #todo[(binary tournament)] \
      4: #todo[Perform crossover (generate offspring)] \
      5: Išmokyti #todo[offsrping] (atlikti lokalią paiešką) \
      6: jeigu sprendimas neįmanomas: \
          pridėti sprendimą prie neįvykdomų aibės bei sutaisyti su tam tikra tikimybe \ // $P_"rep"$ \
      7: jeigu sprendimas įmanomas: \
         pridėti sprendimą prie įvykdomų aibės \
      8: jeigu pasiekas maksimalus sprendimų skaičius: \
         pasirinkti geriausius ir labiausiai įvairius sprendimus \
      9: Pakeisti #todo[penalty parameters] \
      10: Jeigu geriausias sprendimas per $"It"_"div"$ iteracijų nepagerėjo: \
          diversifikuoti populiaciją \
    11: Gražinti geriausią sprendimą
  ]]
] <algo>

#todo[TODO: add swap\*]

#figure(
  caption: [HGS veikimas @vidal2022Hybrid]
)[#image("img/1-s2.0-S030505482100349X-gr1_lrg.jpg", width: 75%)]
#todo[TODO: Išversti į lietuvių k.???]

#br

= Literatūros analizė

// Platesnė VRP lygiagretinimo panorama aptariama apžvalginiuose darbuose @jastrzab2024Standa.

// GPU metodai dažniausiai orientuojasi į 2-opt, Swap ir susijusių operatorių spartinimą, tačiau daugelyje darbų optimizuojamas tik kelionės ilgio įvertinimas, o sudėtingesnių apribojimų apdorojimas lieka ribotas @lei2025Speedi, @abdelatti2020An_imp, @muniasamy2023Effect. Vis dėlto nemaža dalis pagreitinimų neturi viešo kodo ar detalių palyginimų su BKS, todėl jų pritaikomumas HGS kontekste (pvz., su Swap\* operatoriumi) išlieka atvira problema @vidal2022Hybrid.

#br

@lei2025Speedi lygiagretinimui lokalio paieškios algoritmą išreiškia tenzorių operatoriais, tai leidžia HGS vykdymą perkelti ant GPU. Taip pagreitintas lokalios paieškos operatorius.
Tačiau @lei2025Speedi pasiūlytas metodas nėra pritaikomas HGS su swap\*.
#qi[Dabartinė sprendimų reprezentacija per tensorius neleidžia lengvai įgyvendinti apkarpymo strategijų kaimynysčių sumažinimo technikų, kurie dažnai yra naudojami lokalios paieškos grįstais algoritmais.][the current design of the tensor representation of solutions doesn’t support easy implementation of pruning strategies and neighborhood reduction techniques that are often used in local search-based routing algorithms.]

@stadtler2023parallel HGS pritaiko CVRPPD, perkelia tėvų pasirinkimo #angl[selection], kryžminimo #angl[crossover] ir taisymo #angl[repair] žingsnius į atskiras gijas. Kiekviena gija papildomai atlieka lokalią paiešką (_2-opt_, _relocate_, _swap_) pasitelkiant GPU, tačiau nepasitelkia _swap\*_ heuristika, kuri pagal @vidal2022Hybrid padeda surasti aukštesnės kokybės sprendimus.

Priešintai nei dauguma implementacijų @muniasamy2023Effect naudoja grafų duomenų struktūras, panaudojami tik _2-opt_ ir arčiausio kaimyno heuristikos #angl[nearest-neighbor]. Šios heuristikos pritaikytos vykdymui GPU aplinkoje naudojant CUDA.

#figure(
  caption: [HGS lygiagretintas @stadtler2023parallel]
)[#image("img/611509_1_En_8_Fig3_HTML.webp", width: 50%)]

@yelmewad2021Parall pasitelkia GPU lygiagretinimui. Kiekvienam maršrutui skiriama atskira GPU gija, kuri vykdo lokalios paieškos žingsnį naudojant GPU. Šiuo metodu pilnas resursų išnaudojimas priklauso nuo to ar sukurtų maršrutų skaičius sutampa su gijų skaičiumi. Atvejai, kai lokalios paieškos žingsniai modifikuoja kitų maršrutų sprendimą, gijos įrašo savo sprendimą į atskirą masyvą, kuris vėliau yra redukuojamas į vieną sprendimą, pasirenkant geriausią sprendimą. Analogiškai, vėlesnėme žingsnyje kiekvienam taškui priskiriama gija. Kiekviena gija apskaičiuoja pagerėjimą ar pablogėjimą apsikeistus vietą maršrute su kitu tašku.

@jamshidi2025A_Para kombinuoja HGS su salų modeliu, aprarašytu @rezaei2024Explor, kur kiekviena gija, vykdo tą patį HGS algoritmą, pridedamas individų migracijos žingsnis, kuris leidžia keistis sprendimais tarp gijų.
// TODO: pridėti migracijos aprašymą.

#figure(
  caption: [HGS su salų modeliu @jamshidi2025A_Para]
)[#image("img/44196_2025_1059_Fig5_HTML.webp", width: 50%)]

// @jastrzab2024Standa siūlo metodiką kaip lyginti algoritmus tarpusavyje, taip kad jie kuo tiksliau atitiktų rezultatus realybėje.

= Greitaveikos nagrinėjimas

Dideliems duomenų rinkiniams net HGS didžiąją laiko dalį skiria lokaliai paieškai #todo[TODO: pateikti skaičius???] #angl[Local Search].
// - GPU pagreitinti 2-opt/Swap operatoriai @lei2025Speedi,

= Pavyzdinių duomenų rinkiniai ir rezultatų palyginimas

Algoritmų kokybei vertinti plačiai naudojami _de facto_ standartizuoti rinkiniai @petropoulos2023Operat:  geriausių sprendinių #angl[Best Known Solution -- BKS] rinkiniai, pavyzdžiui "CVRPLIB" @uchoa2017.

= Rezultatai

Iš rezultatų matyti, kad užduočių kokybė t.y. COST nesumažėjo, tačiau vykdymo laikas vidutiniškai pakilo X kartų. Uždaviniai su didesniu kiekiu taškų ypač nukenčia.
HIPOTEZE: Taip atisitinka, dėlto, kad kiekviena gija iš esmės atlieką tą patį darbą, o papildomi resursai sunaudojami duomenų kopijavimui ir sinchronizacijai tarp gijų.
// #q()[An up-to-date survey on recent trends can be
//   found in Vidal et al. (2020) [@vidal2020A_conc]]

#q(a: <rezaei2024Explor>)[
  The algorithm’s
  effectiveness is demonstrated through several experiments on diverse benchmark instances, including classical benchmarks
  (Uchoa, CMT, and Golden) and #note[real-world application instances (LoggiBUD)].
]

@petropoulos2023Operat
  #q()[
  A more recent set of instances and best known solutions is available in Queiroga et al. (2022), where the authors provide data enabling the use of machine learning approaches to solve the CVRP. Accorsi et al.
  (2022) present the standard practices to test CVRP algorithms: how to determine computing time (typically on a single thread), common ways of tuning parameters, and providing best and average solutions on a specified number of executions, among others.
  ]

= Kita

_Gap_ apbidrėžimas.

$
  "Gap" &= ((Z_s - Z_"BKS") / Z_"BKS") dot 100% \
  Z_s &= #[Algoritmo sprendimo kaina] \
  Z_"BKS" &= #[Geriausio sprendimo kaina]
$

#pagebreak()
#bibliography(title: [Šaltiniai], "bibliography.bib")

// = The bad list
// - A Hybrid Approach for Simultaneous Effective Automobile Navigation with DE and PSO (2024)
