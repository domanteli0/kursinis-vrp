#import "style.typ": style
#import "utils.typ": c, q, qi, tab, todo, mine, note, angl, angl_, br, lt_ame, lt_oje, lt_a
#import "data.typ": golden_instances, cmt_instances, x_vrp_instances
#import "table1.typ": *
#import "data_gap.typ": gap_data
#import "diagrams/gap_threads.typ": gap_speedup_plot_from, gap_threads_plot_from
#import "diagrams/hgs_flowchart.typ": hgs_flowchart
#import "@preview/drafting:0.2.2": *
#import "@preview/cetz:0.4.2": canvas, draw
#import "@preview/cetz-plot:0.1.3": plot, chart
#import "@preview/i-figured:0.2.4"

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

// #show heading: i-figured.reset-counters
// #show figure: i-figured.show-figure
// #show math.equation: i-figured.show-equation

= Terminai

- Populiacija - Rinkinys invididų.
- Individas - Užduoties sprendinys t.y. rinkinys maršrutų.
- VRP - Martšrutų optimizavimo uždavinys #angl[Vechicle Routing Problem].
- CVRP - #angl_[Capacitated Vehicle Routing Problem]. Kiekviena transporto priemonė turi maksimalią siuntų talpą.
- VRPTW - #angl_[VRP with Time Windows].
- GVRP - #angl_[Generalized VRP]. Klientai grupuojami į klusterius. Tik vienas klientas iš viso klusterio turi būti aplankytas.
- CluVRP - #angl_[Clustered VRP]. Klientai grupuojami į klusterius. Visi klientai klusteryje turi būti aplankyti prieš važiuojant į kitą klusterį.
- SoftCluVRP - #angl_[Clustered VRP]. Klientai grupuojami į klusterius. CluVRP variantas, kuriame į klusterį leidžiama aplankyti kelis kartus.
- MDVRP - #angl_[Multidepot VRP].
- PVRP - #angl_[Periodic VRP]. Pridedama laiko dimescija, sprendinys susidaro iš kelių maršrutų rinkinių atitinkačius dienas, kuriomis bus aplankomi klientai.
- MDPVRP - #angl_[Multidepot Periodic VRP]. MDVRP ir PVRP kombinacija.
- CVRPPD - #angl_[CVRP Pickup and Delivery]. CVRP ir VRPPD kombinacija.

#pagebreak()

= Įvadas

VRP -- Transporto maršrutų optimizavimo uždavinys #angl[Vehicle Routing Problem] yra uždavinys,
kurio tikslas yra surasti kuo optimaliausią maršrutų rinkinį @math_cost. Optimaliai parinkti maršrutai gali lemti kiek klientų įmanoma aplankyti per nustatytą laiką, sumažinti transporto kaštus.
Pirmą kartą ši problema aprašyta @dantzig1959The_Tr, kur autorius aprašė algoritmą, kuris suranda optimalius maršrutus tarp kuro depo ir degalinių.
Tai yra modernios logistikos optimizavimo uždavinys -- optimaliai parinkti maršrutai gali lemti mažesnius kainos ir pristatymo laiko kaštus.

Kur keliaujančio pardavėjo uždavinyje pagrindinė užduotis yra surasti optimaliausią kelią vienam keliautojui -- pardavėjui,
VRP sprendiniai susidaro iš kelių keliautojų -- literatūroje dažnai tiesiogiai vadinama transporto priemonėmis.

Hibridinis genetinis paieškos #angl[Hydrid Genetic Search -- HGS] -- yra vienas iš efektyviausių genetinių metaheuristinių algoritmų @petropoulos2023Operat. Šis algoritmas ir vėlesnės pagerintos versijos išlieka etalonas daugeliui VRP variantų, "DIMACS" konkurse @dimacs2022vrp parodęs geriausius rezultatus VRPTW uždavinyje @kool2022hybrid, ir kurio modifikuotas variantas @jiang2022fhcsolver pasirodė geriausiai CVRP uždavinyje. Šis algoritmas yra pritaikytas CVRP, VRPTW, GVRP @latorre2025A_hybr, CluVRP, SoftCluVRP @latorre2025An_appHybr.

Šio *darbo tikslas* -- išlygiagretinti hibridinio genetinio paieškos algoritmą, skirto transporto maršrutų optimizavimo uždaviniams spręsti,
siekiant sumažinti vykdymo laiką neprarandant ar net pagerinant sprendinių kokybę.

*Uždavinai:*

1. Išsirinkti duomenų rinkinį pagal, kurį galima būtų testuoti/analizuoti sprendinius.
2. Išanalizuoti, kaip veikia HGS algoritmas
3. Atrinkti paralelizuojamas dalis, ar dalis, kurias galima galima pakeisti paralelizuojamomis.
4. Palyginti rezultatus su kitais #todo[state-of-the-art] algoritmais

#pagebreak()

= Transporto maršrutų optimizavimo uždaviniai

== Tikslūs ir apytiksliai metodai

Nors egzistuoja įrankiai, kurie pasiteklia tikslius metodus (pavyzdžiui "Google or-tools" @ortools), kadangi šis uždavinys priklauso _NP-Hard_ sudėtingumo klasei, visgi dominuoja heuristikomis ir metaheuristikomis grįsti algoritmai, nes šie beveik optimalius sprendinius suranda per greitesnį laiko tarpą sunaudodami mažiau resursų. Tikslūs metodai su ypač dideliais kiekiais duomenų tampa nepraktiški. Metaheuristiniai algoritmai išsiskiria šioje uždavinių klasėje kaip efektyviausi, pasižymintys žemu algoritmo vykdymo laiku ir aukšta uždavinių rezultatų kokybe.

Šiai problemai egzistuoja heuristiniai ir metaheuristinai (Aukštesnio lygio strategija, kuris diriguoja, kurias heuristikas pritaikyti, kad efektyviau atrasti sprendinius) algoritmai. Keli dominuojantys pavyzdžiai @adamo2024A_revi

  - "Adaptive Large Neighborhood Search" ir "Hybrid Adaptive Large Neighborhood Search"

  - "Hybrid Genetic Search (HGS)"

  - "Simulated Annealing Algorithm (SAA)"

  - "Ant colony optimization (ACO)"

== VRP variacijos

Praktikoje taikomos keletas VRP variacijų (CVRP, VRPTW, MDPVRP, PVRP ir kt.).
Jos įveda papildomus apribojimus maršrutų ilgiui, transporto priemonių panaudojimo laikui ir talpai, ar prideda papildomas salygas:
- naudojamos transporto priemonės turi limituotą talpą (CVRP);
- visi klientai turi gali būti aplankyti tik specifinėmis darbo valandomis (VRPTW);
- keli depai iš kurių galima pradėti maršrutą (MDVRP);
- maršrutai planuojami per kelias dienas, t.y. vieni klientai gali būti aplankyti vieną dieną, o kiti kitą. (Periodic VRP);
- kt.
Šis darbas atsižvelgia tik į CVRP uždavinį.

== CVRP

CVRP nagrinėjamas grafas $𝐺 = (𝑉, 𝐸)$, kuriame $v_0 in V$ žymi depą, kuris turi $m$ transporto priemonių, o likusios viršūnės ${v_1, ..., v_(|V|)}$ atitinka klientus, kuriuos reikia aplankyti. Kiekviena briauna $(i, j) in E$ reiškia galimybę keliauti tarp vietų $i$ ir $j$ su kaina $c_(i,j)$ -- atstumas tarp vietų $i$ ir $j$. CVRP reikia surasti sprendinį, kuriame panaudotos ne daugiau kaip $K$ transporto priemonių, prasidedančių ir pasibaigiančių depe, taip, kad kiekvienas klientas būtų aplankytas vieną kartą ir bendras klientų paklausos dydis bet kuriame maršrute neviršytų transporto priemonės talpos $Q$, o bendras transporto priemonių nuvažiuotas atstumas -- kaina (žr. #lt_a(<math_cost>) lygtis) kiek įmanoma mažesnis.

$
  "Sprendinio kaina" &= &&sum_(k=1)^(K) sum_(i=0)^(|V|) sum_(j=0)^(|V|) c_(i,j) x_(i,j,k) \
  c_(i,j) &= &&"astumas nuo kliento" i "iki kliento" j \
  x_(i,j,k) &= &&1 "Indikatorinė" "funkcija", "kuri" \
  & &&"lygi" 1, "jei" "transporto" "priemonė" k " " (1 <= k <= K)\
  & &&"keliauja" "nuo" "kliento" i "iki" "kliento" j, \
  & &&"lygi" 0 "priešingu" "atveju"
$ <math_cost>

Lyginant transporto maršrutų optimizavimo uždavinio sprendinius taip pat naudojamas tarpas #angl[gap], kuris nusako atstumą nuo geriausio sprendinio išreikštas procentais @math_gap.

$
  "Tarpas" &= ((Z_s - Z_"BKS") / Z_"BKS") dot 100% \
  Z_s &= #[Pasirinkto algoritmo sprendinio kaina] \
  Z_"BKS" &= #[Geriausio sprendinio kaina]
$ <math_gap>

= HGS algoritmo veikimas

Pirma aprašytas #c(<vidal2012A_Hybr>) skirtas spręsti MDPVRP. Patobulintas per daugelį iteracijų: @vidal2014A_unif, @vidal2016Large_, @vidal2017Node__, @vidal2021Arc_Ro, @vidal2022Hybrid ir pritaikytas CVRP.

Genetiniai algoritmai imituoja evoliucijos procesą. Populiacija yra aibė, kurią sudaro individai (t.y. užduoties sprendiniai). Šie algoritmai naudoja įvairius kryžminimo operatorius, kurie iš kelių individų populiacijoje sukuria naują, mutuotą individą ir prideda prie populiacijos. Prastos kokybės ir panašūs individai (sprendiniai) vykdimo eigoje yra pašalinami iš populiacijos.

Genetinis hydridinis paieškos algoritmas prie genetinio komponento prideda pagerinimo žingsnį (vietinę paiešką #angl[local search]), kuri po kryžminimo žinsnio yra pritaikoma naujam individui, kad pagerinti gautą individo kokybę.

Vietinėje paieškoje taikomos _relocate_, _2-opt_, _2-opt\*_, bei  _swap\*_ heuristikos.

Palaikant neįvykdomus #angl[infeasible] ir įvykdomus #angl[feasible] sprendinius, palaikoma populiacijos įvairovė #angl[diversity], kuri leidžia išvengti lokalios minimos #angl[local minima] iteruojant per sprendinius.

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
        alg-line("3", [Pasirinkti tėvinius individus (dvejetainis turnyras #angl[binary tournament])], indent: 1, bar: true),
        alg-line("4", [Atlikti kryžminimą #angl[crossover]], indent: 1, bar: true),
        alg-line("5", [Išmokyti naują individą (vietinė paieška)], indent: 1, bar: true),
        alg-line("6", [Įterpti išmokytą invdividą į atitinkamą subpopuliaciją], indent: 1, bar: true),
        alg-line("7", [*Jeigu* individas neįvykdomas:], indent: 1, bar: true),
        alg-line("8", [Su 50% tikimybe bandyti sutaisyti individą ir įtraukti į atitinkamą subpopuliaciją], indent: 2, bar: true),
        alg-line("9", [*Jeigu* pasiektas maksimalus aibės dydis:], indent: 1, bar: true),
        alg-line("10", [pašalinti blogiausius ir neįvairius individus iš populiacijos], indent: 2, bar: true),
        alg-line("11", [Patikslinti baudos parametrus #angl[penalty parameters]], indent: 1, bar: true),
        alg-line("12", [Grąžinti geriausią įvykdomą individą]),
      )
    ]
  ]
] <algo>

#figure(
  caption: [HGS veikimas @vidal2022Hybrid]
)[#scale(60%)[#hgs_flowchart]]
#todo[TODO: Išversti į lietuvių k.???]

= Literatūros analizė

// GPU metodai dažniausiai orientuojasi į 2-opt, Swap ir susijusių operatorių spartinimą, tačiau daugelyje darbų optimizuojamas tik kelionės ilgio įvertinimas, o sudėtingesnių apribojimų apdorojimas lieka ribotas @lei2025Speedi, @abdelatti2020An_imp, @muniasamy2023Effect. Vis dėlto nemaža dalis pagreitinimų neturi viešo kodo ar detalių palyginimų su BKS, todėl jų pritaikomumas HGS kontekste (pvz., su Swap\* operatoriumi) išlieka atvira problema @vidal2022Hybrid.

@lei2025Speedi lygiagretinimui vietinės paieškios algoritmą išreiškia tenzorių operatoriais, tai leidžia HGS vykdymą perkelti ant GPU. Taip pagreitintas vietinės paieškos operatorius.
Tačiau @lei2025Speedi pasiūlytas metodas nėra pritaikomas HGS su swap\*.
#qi[Dabartinė sprendinių reprezentacija per tensorius neleidžia lengvai įgyvendinti apkarpymo strategijų kaimynysčių sumažinimo technikų, kurie dažnai yra naudojami vietinės paieškos grįstais algoritmais.][the current design of the tensor representation of solutions doesn’t support easy implementation of pruning strategies and neighborhood reduction techniques that are often used in local search-based routing algorithms.]

@stadtler2023parallel HGS pritaiko CVRPPD, perkelia tėvų pasirinkimo #angl[selection], kryžminimo #angl[crossover] ir taisymo #angl[repair] žingsnius į atskiras gijas. Kiekviena gija papildomai atlieka vietinę paiešką (_2-opt_, _relocate_, _swap_) pasitelkiant GPU, tačiau nepasitelkia _swap\*_ heuristika, kuri pagal @vidal2022Hybrid padeda surasti aukštesnės kokybės sprendinius.

Priešintai nei dauguma implementacijų @muniasamy2023Effect naudoja grafų duomenų struktūras, panaudojami tik _2-opt_ ir arčiausio kaimyno heuristikos #angl[nearest-neighbor]. Šios heuristikos pritaikytos vykdymui GPU aplinkoje naudojant CUDA.

#figure(
  caption: [HGS lygiagretintas @stadtler2023parallel]
)[#image("img/611509_1_En_8_Fig3_HTML.webp", width: 50%)]

@yelmewad2021Parall pasitelkia GPU lygiagretinimui. Kiekvienam maršrutui skiriama atskira GPU gija, kuri vykdo vietinės paieškos žingsnį naudojant GPU. Šiuo metodu pilnas resursų išnaudojimas priklauso nuo to ar sukurtų maršrutų skaičius sutampa su gijų skaičiumi. Atvejai, kai vietinės paieškos žingsniai modifikuoja kitų maršrutų sprendinį, gijos įrašo savo sprendinius į atskirą masyvą, kuris vėliau yra redukuojamas į vieną sprendinį, pasirenkant geriausią sprendinį. Analogiškai, vėlesnėme žingsnyje kiekvienam klientui priskiriama gija. Kiekviena gija apskaičiuoja pagerėjimą ar pablogėjimą apsikeistus vietą maršrute su kitu klientu.

@jamshidi2025A_Para aprašo _PHGS_ #angl[Parallel Hybrid Genetic Search], kur kombinuoja HGS su salų modeliu, aprarašytu @rezaei2024Explor, kur kiekviena gija, vykdo tą patį HGS algoritmą, pridedamas individų migracijos žingsnis, kuris leidžia keistis sprendiniais tarp gijų.

#figure(
  caption: [HGS su salų modeliu @jamshidi2025A_Para]
)[#image("img/44196_2025_1059_Fig5_HTML.webp", width: 50%)]

_PHGS_ rodo vos ne du kartus geresnius rezultatus galutiniame laiko momente.

#figure(caption: [Palyginimas tarp vidutino tarpo (Y ašis) ir vykdymo laiko (X ašis) @jamshidi2025A_Para.])[#image(width: 50%, "img/44196_2025_1059_Fig6_HTML (Edited).png")] <jamshidi2025A_Para_gap_speed>

= Lygiagretinimas

Paimta @vidal2022Hybrid HGS algoritmo implementacija#footnote[Nuolatinė repozitoriją nuoroda https://github.com/vidalt/HGS-CVRP/tree/1a927955cd2861a29d978f0d359d6e647db9319c], kuri naudojama kiap pagrindas lygiagretinimui.

Daugiausiai laiko užima vietinės paieškos žingsnis @jamshidi2025A_Para, šio autoriaus atliktais matavimais vietinė paieška užima 85% vykdymo laiko. Todėl siekiant sumažinti viso HGS algoritmo vykdymo laiką šį žingsnį yra labiausiai verta lygiagretinti.

Lygiagretinimas įgyvendintas kiekvienai gijai, atliekant vietinę paiešką. Lygiagretinta HGS-CVRP versija pavaizduota @algo_parallel. Nuosekliai veikiančioje sekcijoje parenkami skirtingi tėviniai individai, kryžminimo metu sukuriami individai kiekvienai gijai. Tada kiekviena gija lygiagrečiai atlieka vietinės paieškos žingsnį. Vėliau, kai kiekviena gija atlieka šį žingsnį, individai yra pridedami į visų populiaciją.

#todo[TODO: praplėsti ir padaryti diagramą]

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
        alg-line("3", [Pasirinkti $N#footnote[N -- gijų skaičius]*2$ tėvinius individus (dvejetainis turnyras #angl[binary tournament])], indent: 1, bar: true),
        alg-line("4", [Atlikti kryžminimą #angl[crossover] N kartų], indent: 1, bar: true),
        alg-line("5", [(Kiekienoje gijoje) išmokyti naują individą], indent: 1, bar: true),
        alg-line("6", [Įterpti išmokytą invdividą į atitinkamą subpopuliaciją], indent: 1, bar: true),
        alg-line("7", [*Jeigu* individas neįvykdomas:], indent: 1, bar: true),
        alg-line("8", [(Kiekvienoje gijoje) su 50% tikimybe bandyti sutaisyti individą ir įtraukti į atitinkamą subpopuliaciją], indent: 2, bar: true),
        alg-line("9", [*Jeigu* pasiektas maksimalus aibės dydis:], indent: 1, bar: true),
        alg-line("10", [pašalinti blogiausius ir neįvairius individus iš populiacijos], indent: 2, bar: true),
        alg-line("11", [Patikslinti baudos parametrus #angl[penalty parameters]], indent: 1, bar: true),
        alg-line("12", [Grąžinti geriausią įvykdomą individą]),
      )
    ]
  ]
] <algo_parallel>


// We measure wall clock
// fair comparison of parallel vs sequential implementations, and (3) alignment with standard evaluation prac-
// tices. This prevents artificial inflation of parallel versions’ apparent resource usage through thread aggregation.


Palyginimui naudoti geriausių sprendinių rinkinys#footnote[https://galgos.inf.puc-rio.br/cvrplib/index.php/en/instances, prieigos data: 2026-01-07].

= Lygiagretintos ir nuoseklios programos palyginimas

== Metodika

_HGS_ ir kiti iteratyvūs algoritmas sustoja tik, kai pasiekiamas tam tikras kriterijus. HGS atveju, tai iteracijų skaičius be pagerėjimo ar veikimo laikas. Kadangi šiek parametrai gali būti laisvai parinkti, pasirinkus pakankamai aukštus parametrus algoritmo veikimo laikas gali tęstis ilgiau negu dabartinis visatos amžius.

Dėl rezultatų palyginamumo pasirinkta naudoti @vidal2022Hybrid aprašytus duomenų rinkinius (@uchoa2017) ir metodiką:
#qi()[Mes stebime kiekvieno algoritmo pažangą iki laiko ribos $𝑇_"max" = 𝑛 dot 240∕100$ sekundžių, kur $n$ reiškia klientų skaičių.
Todėl mažiausias atvejis su 100 klientais vykdomas 4 minutes,
o didžiausias atvejis su 1000 klientų vykdomas 40
minučių. Kiekvieno veikimo metu mes užregistruojame geriausią sprendimo vertę po 1%, 2%, 5%, 10%, 15%, 20%, 30%, 50%, 75% ir 100%
laiko ribos, kad galėtume įvertinti algoritmų našumą skirtinguose
paieškos etapuose @vidal2022Hybrid.][We monitor each algorithm’s progress up to a time limit of $𝑇_"max" = 𝑛 dot 240∕100$ seconds, where 𝑛 represents the number of customers.
Therefore, the smallest instance with 100 clients is run for 4 minutes,
whereas the largest instance containing 1000 clients is run for 40
minutes. During each run, we record the best solution value after
1%, 2%, 5%, 10%, 15%, 20%, 30%, 50%, 75%, and 100% of the
time limit to measure the performance of the algorithms at different
stages of the search.]

Vykdimo duomenys surinkti paleidžiant lygiagretintą ir palyginimui originalią HGS-CVRP programą ant "Intel® Xeon® Gold 6252" procesoriaus. Šiam eksperimentui iteracijų skaičius begalinis iteracijų be pagreitėjimo skaičius ir $T_"max" = n 24/100$, 10 kartų mažesnis negu @vidal2022Hybrid, tam, kad sutilpti į duotus MIF STSC resursų limitus.
Lygiagretintos programos versija patalpinta "Codeberg" repozitorijoje#footnote[https://codeberg.org/Dom/HGS-CVRP/src/commit/411e391ffefac9a308d28e280194d65004d8332c].

== Rezultatai

#let gap_result = gap_data()
#let table1 = table_100_avg_from(gap_result)

#figure(
  caption: [Sprendimo kokybė pagal gijų skaičių. Gap apskaičiuojamas pagal BKS, o x ašis rodo vykdymo laiką procentais.]
)[#scale(85%)[#gap_threads_plot_from(gap_result)]]

#figure(
  caption: [Sprendimo kokybės santykis tarp viengijio ir N gijų sprendimų (Gap(1 gija) / Gap(N gijų)) priklausomai nuo vykdymo laiko.]
)[#scale(85%)[#gap_speedup_plot_from(gap_result)]]


Iš rezultatų matyti, kad užduočių kokybė t.y. COST nesumažėjo, tačiau vykdymo laikas sumažėjo X kartų iki Y gijų skaičiaus, daugiau didinant gijų skaičių vykdymo laikas vidutiniškai pakilo X kartų

Palyginus su @jamshidi2025A_Para matomas didesnis pagreitėjimas su 16



// #q()[An up-to-date survey on recent trends can be
//   found in Vidal et al. (2020) [@vidal2020A_conc]]

// @petropoulos2023Operat
//   #q()[
//   A more recent set of instances and best known solutions is available in Queiroga et al. (2022), where the authors provide data enabling the use of machine learning approaches to solve the CVRP. Accorsi et al.
//   (2022) present the standard practices to test CVRP algorithms: how to determine computing time (typically on a single thread), common ways of tuning parameters, and providing best and average solutions on a specified number of executions, among others.
//   ]

#pagebreak()
= Rezultatai ir išvados

== Rezulatai

1. Išsirinkti duomenų rinkinį pagal, kurį galima būtų testuoti/analizuoti sprendinius.
2. Išanalizuoti, kaip veikia HGS algoritmas
3. Atrinkti paralelizuojamas dalis, ar dalis, kurias galima galima pakeisti paralelizuojamomis.
4. Palyginti rezultatus su kitais state-of-the-art algoritmais

1. Parinktas duomenų rinkinys pagal, kurį galima būtų testuoti/analizuoti sprendinius.
2. Atlinka HGS algoritmo veikimo analizė.
3. Atrinkti paralelizuojamas dalis, ar dalis, kurias galima galima pakeisti paralelizuojamomis.
4. Atliktas palyginimas su kitais #todo[state-of-the-art] algoritmais.

== Išvados

#todo[TODO]

#pagebreak()
= Priedai

== Vidutinės pasiektos sprendimų kainos ir tarpas galutiniu laiko momentu

#show figure.where(kind: table): set block(breakable: true)
#figure(
  block(breakable: true, width: 118%)[#table1],
    caption: [Vidutinės pasiektos sprendimų kainos ir tarpas galutiniu laiko momentu]
)

#pagebreak()
#bibliography(title: [Šaltiniai], "bibliography.bib")

// = The bad list
// - A Hybrid Approach for Simultaneous Effective Automobile Navigation with DE and PSO (2024)
