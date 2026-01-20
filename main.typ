#import "style.typ": style
#import "utils.typ": *
#import "data.typ": format_2, x_vrp_instances
#import "data_gap.typ": gap_data
#import "data_speedup.typ": time_to_target_data, time_to_target_fixed
#import "tables/table1.typ": table_100_avg_from
#import "tables/table_params.typ": table_experiment_params
#import "tables/table_gap.typ": *
#import "diagrams/gap_threads.typ": gap_speedup_plot_from, gap_threads_plot_from, amdahl_speedup_plot
// #import "tables/table_parallel_compare.typ": table_parallel_compare
#import "diagrams/hgs_flowchart.typ": hgs_flowchart
#import "diagrams/parallel_hgs_arch.typ": parallel_hgs
#import "diagrams/parallel_hgs_memory.typ": parallel_hgs_memory
#import "diagrams/island_model.typ": island_model
#import "diagrams/time_target_speedup.typ": speedup_plot_from, efficiency_plot_from
// #import "diagrams/parallel_hgs_thread_flow.typ": parallel_hgs_thread_flow
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

// Bibliografijos rikiavimui pagal identifikatorius.
#hide[
  @abdelatti2020An_imp @adamo2024A_revi @dantzig1959The_Tr @dimacs2022vrp
  @jamshidi2025A_Para @jastrzab2024Standa @jiang2022fhcsolver @kool2022hybrid
  @lei2025Speedi @latorre2025A_hybr @latorre2025An_appHybr @muniasamy2023Effect
  @ortools @pandian2023Effect @petropoulos2023Operat @PyVRPwouda2024
  @rezaei2024Explor @stadtler2023parallel
  @uchoa2017 @vidal2012A_Hybr @vidal2014A_unif
  @vidal2016Large_ @vidal2021Arc_Ro @VIDAL2016 @vidal2017Node__
  @vidal2022Hybrid @yelmewad2021Parall
]

= Santrumpos

- HGS – Hibridinis genetinis paieškos algoritmas #angl[Hybrid Genetic Search].
- VRP – Transporto maršrutų optimizavimo uždavinys #angl[Vehicle Routing Problem].
- CVRP – #angl_[Capacitated Vehicle Routing Problem]. Kiekviena transporto priemonė turi maksimalią siuntų talpą.
- VRPTW – #angl_[VRP with Time Windows].
- GVRP – #angl_[Generalized VRP]. Klientai grupuojami į klasterius. Tik vienas klientas iš viso klasterio turi būti aplankytas.
- CluVRP – #angl_[Clustered VRP]. Klientai grupuojami į klasterius. Visi klientai klasteryje turi būti aplankyti prieš vykstant į kitą klasterį.
- SoftCluVRP – #angl_[Soft Clustered VRP]. CluVRP variantas, kuriame į klasterį leidžiama aplankyti kelis kartus.
- MDVRP – #angl_[Multidepot VRP].
- PVRP – #angl_[Periodic VRP]. Pridedama laiko dimensija, sprendinys sudaromas iš kelių maršrutų rinkinių, atitinkančių dienas, kuriomis bus aplankomi klientai.
- MDPVRP – #angl_[Multidepot Periodic VRP]. MDVRP ir PVRP kombinacija.
- CVRPPD – #angl_[CVRP Pickup and Delivery]. CVRP ir VRPPD kombinacija.
- BKS – Geriausias žinomas sprendinys #angl[Best Known Solution].
- GPU – Grafikos procesorius #angl[Graphics Processing Unit].
- Populiacija – individų rinkinys.
- Individas – uždavinio sprendinys, t. y. maršrutų rinkinys.
- Įvykdomas sprendinys – sprendinys, tenkinantis visus uždavinio apribojimus.

#pagebreak()

= Įvadas

VRP – transporto maršrutų optimizavimo uždavinys [vehicle routing problem] – yra uždavinys, kurio tikslas yra surasti kuo optimaliausią maršrutų rinkinį (t. y. kuo mažiausią maršruto kainą, žr. #ref(<math_cost>)). Optimaliai parinkti maršrutai lemia, kiek klientų įmanoma aplankyti per nustatytą laiką, bei padeda sumažinti transporto kaštus. Pirmą kartą ši problema aprašyta @dantzig1959The_Tr darbe, kur autoriai pristatė algoritmą, randantį optimalius maršrutus tarp kuro depo ir degalinių. Tai yra vienas iš modernios logistikos optimizavimo uždavinių – net maži maršrutų pagerinimai realiame pasaulyje gali reikšti reikšmingas sąnaudų ir pristatymo laiko taupymo galimybes. Keliaujančio pardavėjo uždavinyje pagrindinė užduotis yra surasti optimaliausią kelią vienam keliautojui (pardavėjui), o vrp sprendiniai susidaro iš kelių keliautojų – literatūroje šie keliautojai tiesiogiai vadinami transporto priemonėmis.

Hibridinis genetinės paieškos algoritmas #angl[Hybrid Genetic Search -- HGS] -- yra vienas iš efektyviausių genetinių metaheuristinių algoritmų @petropoulos2023Operat. Šis algoritmas ir vėlesnės pagerintos versijos išlieka etalonas daugeliui VRP variantų, "DIMACS" konkurse @dimacs2022vrp parodęs geriausius rezultatus VRPTW uždavinyje @kool2022hybrid, ir kurio modifikuotas variantas @jiang2022fhcsolver pasirodė geriausiai CVRP uždavinyje. Šis algoritmas yra pritaikytas CVRP, VRPTW, GVRP @latorre2025A_hybr, CluVRP, SoftCluVRP @latorre2025An_appHybr.

Šio *darbo tikslas* -- išlygiagretinti hibridinio genetinio paieškos algoritmą, skirtą transporto maršrutų optimizavimo uždaviniams spręsti,
siekiant sumažinti vykdymo laiką neprarandant ar net pagerinant sprendinių kokybę.

*Uždaviniai:*

1. Išsirinkti duomenų rinkinį, pagal kurį galima būtų testuoti ir analizuoti sprendinius.
2. Išanalizuoti, kaip veikia HGS algoritmas.
3. Atrinkti paralelizuojamas dalis, kurias galima pakeisti lygiagrečiomis.
4. Palyginti rezultatus su literatūroje aprašytais pažangiausiais algoritmais.

#pagebreak()

#set heading(numbering: "1.")
= Transporto maršrutų optimizavimo uždaviniai

== Tikslūs ir apytiksliai metodai

Nors egzistuoja įrankiai, pasitelkiantys tikslius metodus (pavyzdžiui, "Google OR-Tools" @ortools), šis uždavinys priklauso _NP-hard_ sudėtingumo klasei, todėl praktikoje dominuoja heuristikomis ir metaheuristikomis grįsti algoritmai. Tikslūs metodai (dažniausiai mišrus sveikųjų skaičių programavimas #angl[mixed integer programming] ar šakojimosi ir ribų #angl[branch & bound] metodai) suranda optimaliausius sprendinius, tačiau jų skaičiavimo laikas sparčiai auga didėjant uždavinio dydžiui. Dėl to jie tampa nepraktiški dideliems uždaviniams – pavyzdžiui, tik mažesni VRP Uždaviniai išsprendžiami tiksliais metodais per protingą laiką. Tokie metodai dažniau taikomi mažesnėms problemoms.
Tuo tarpu metaheuristiniai algoritmai šioje uždavinių klasėje išsiskiria efektyvumu – jie per priimtiną laiką randa beveik optimalius sprendinius, pasižyminčius aukšta kokybe, ir dėl to yra tinkamesni realiems logistikos uždaviniams.

Šiam uždaviniui dažniau naudojami heuristiniai ir metaheuristiniai algoritmai, jos išlieka patrauklios realiems logistikos uždaviniams. Metaheuristika -- aukštesnio lygio strategija, kuri parenka, kurias heuristikas taikyti, kad sprendiniai būtų randami efektyviau. Keli dominuojantys pavyzdžiai @adamo2024A_revi:

  - "Adaptive Large Neighborhood Search" ir "Hybrid Adaptive Large Neighborhood Search"

  - "Hybrid Genetic Search (HGS)"

  - "Simulated Annealing Algorithm (SAA)"

  - "Ant colony optimization (ACO)"

== VRP variacijos

Praktikoje taikomos kelios VRP variacijos (CVRP, VRPTW, MDPVRP, PVRP ir kt.).
Jos įveda papildomus apribojimus maršrutų ilgiui, transporto priemonių panaudojimo laikui ir talpai arba prideda papildomas sąlygas:
- naudojamos transporto priemonės turi limituotą talpą (CVRP);
- visi klientai gali būti aplankyti tik specifinėmis darbo valandomis (VRPTW);
- keli depai, iš kurių galima pradėti maršrutą (MDVRP);
- maršrutai planuojami per kelias dienas, t. y. vieni klientai gali būti aplankyti vieną dieną, o kiti kitą (Periodic VRP);
- kt.
Šis darbas atsižvelgia tik į CVRP uždavinį.

== CVRP

CVRP nagrinėjamas grafas $𝐺 = (𝑉, 𝐸)$, kuriame $v_0 in V$ žymi depą, kuris turi $m$ transporto priemonių, o likusios viršūnės ${v_1, ..., v_(|V|)}$ atitinka klientus, kuriuos reikia aplankyti. Kiekviena briauna $(i, j) in E$ reiškia galimybę keliauti tarp vietų $i$ ir $j$ su kaina $c_(i,j)$ -- euklidinis atstumas tarp vietų $i$ ir $j$. CVRP reikia surasti sprendinį, kuriame panaudotos ne daugiau kaip $K$ transporto priemonių, prasidedančių ir pasibaigiančių depe, taip, kad kiekvienas klientas būtų aplankytas vieną kartą ir bendras klientų paklausos dydis bet kuriame maršrute neviršytų transporto priemonės talpos $Q$, o bendras transporto priemonių nuvažiuotas atstumas -- kaina (žr. #lt_a(<math_cost>) lygtį) kiek įmanoma mažesnis.

$
  c_(i, j) = sqrt((x_i - x_j)^2 + (y_i - y_j)^2) \
$ <math_dist>

$
  "Sprendinio kaina" &= &&sum_(k=1)^(K) sum_(i=0)^(|V|) sum_(j=0)^(|V|) c_(i,j) x_(i,j,k) \
  x_(i,j,k) &= &&1 "Indikatorinė" "funkcija", "kuri" \
  & &&"lygi" 1, "jei" "transporto" "priemonė" k " " (1 <= k <= K)\
  & &&"keliauja" "nuo" "kliento" i "iki" "kliento" j, \
  & &&"lygi" 0 "priešingu" "atveju"
$ <math_cost>

Lyginant transporto maršrutų optimizavimo uždavinio sprendinius taip pat naudojama spraga #angl[gap], kuri nusako atstumą nuo geriausio sprendinio, išreikštą procentais @math_gap.

$
  "Spraga" &= ((Z_s - Z_"BKS") / Z_"BKS") dot 100% \
  Z_s &= #[Pasirinkto algoritmo sprendinio kaina] \
  Z_"BKS" &= #[Geriausio sprendinio kaina]
$ <math_gap>

#pagebreak()
= HGS algoritmo veikimas

Pirmą kartą aprašytas #c(<vidal2012A_Hybr>) skirtas spręsti MDPVRP. Patobulintas per daugelį iteracijų: @vidal2014A_unif, @vidal2016Large_, @vidal2017Node__, @vidal2021Arc_Ro, @vidal2022Hybrid ir pritaikytas CVRP. Pastarasis variantas vadinamas HGS-CVRP.

Genetiniai algoritmai imituoja evoliucijos procesą. Populiacija yra aibė, kurią sudaro individai (t. y. užduoties sprendiniai). Šie algoritmai naudoja įvairius kryžminimo operatorius, kurie iš kelių individų populiacijoje sukuria naują, mutuotą individą ir prideda prie populiacijos (#lt_ame(<hgs_flowchart>) pavyzdyje 1, 2 ir 4 žingsniai). Prastos kokybės ir panašūs individai (sprendiniai) vykdimo eigoje yra pašalinami iš populiacijos.

Genetinis hibridinis paieškos algoritmas prie genetinio komponento prideda pagerinimo žingsnį -- vietinę paiešką #angl[local search], kuri po kryžminimo žingsnio yra pritaikoma naujam individui, siekiant pagerinti gauto individo kokybę (#lt_ame(<hgs_flowchart>) pavyzdyje 3 žingsnis).

Kryžminimo operacija iš esmės sukuria vieną maršrutą, kuris vėliau yra efektyviai sukarpomas į kelis maršrutus pasitelkiant #angl[split] algoritmą.

//
// Vietinė paieška vykdoma iteratyviai taikant kelias kaimynystes, kol nebelieka gerinančių judesių. Operatoriai kaip _relocate_ ir _swap_ leidžia keisti klientų vietas tarp maršrutų, o _2-opt_ ir _2-opt\*_ koreguoja maršruto vidinę struktūrą. _Swap\*_ yra brangiausia, bet dažnai duodanti didžiausią pagerėjimą kaimynystė.

Vietinei paieškai pasitelkiami _relocate_, _swap_, _2-opt_, _2-opt\*_ ir _swap\*_ kaimynystės. Kaimynystė #angl[neighborhood] -- tai sprendinių rinkinys, kurį galima gauti iš dabartinio sprendinio atlikus vieną lokalų pakeitimą (pvz., perkelti klientą, sukeisti du klientus ar apversti maršruto atkarpą). Vietinė paieška tikrina tokius kaimyninius sprendinius ir renkasi geresnį už dabartinį. _Swap\*_ kaimynystėje du klientai iš skirtingų maršrutų išimami ir kiekvienas įterpiamas į bet kurią kito maršruto poziciją; nors galimų judesių labai daug, geriausiam judesiui pakanka tikrinti įterpimą į vietą arba vieną iš trijų geriausių iš anksto įvertintų pozicijų, todėl kaimynystė tiriama efektyviai. Toks apribojimas sumažina vietinės paieškos sudėtingumą nuo kvadratinio iki maždaug linijinio pagal klientų skaičių, kartu išlaikant pakankamai gerą sprendinių kokybę. @vidal2022Hybrid. Jeigu po vietinės paieškos individas yra neįvykdomas, su 50% tikimybe taikoma taisymo procedūra t. y. pakartotinė vietinė paieška.


#figure(
  caption: [HGS veikimas @vidal2022Hybrid],
  scale(65%, reflow: true, hgs_flowchart)
) <hgs_flowchart>

Pradinė populiacija HGS algoritme sukuriama taikant greitas konstravimo heuristikas.

Tėvų atranka vykdoma dvejetainiu turnyru #angl[binary tournament], kur paskaičiuojamas tinkamumas #angl[fitness], t. y. sprendinio kainos ir įvairovės (_broken-pairs_ atstumo) suma ir išrenkami didžiausią tinkamumą turintys individai; populiacija palaikoma kaip įvykdomų ir neįvykdomų subpopuliacijų rinkinys, o baudos parametrai tikslinami, kad būtų išlaikytas įvykdomų ir neįvykdomų sprendinių santykis @vidal2022Hybrid, @vidal2012A_Hybr. Palaikant neįvykdomus #angl[infeasible] ir įvykdomus #angl[feasible] sprendinius, išlaikoma populiacijos įvairovė #angl[diversity], kuri leidžia išvengti lokalaus minimo #angl[local minima] iteruojant per sprendinius.

// $f_P (S) = f_P^phi.alt (S) + (1 - (n^"ELITE")/(| cal(P) |)) f_P^"DIV" (S) $
// $$

// $ δ(S1​,S2​)=∣{(i,j)∣(i,j) "yra individe" S_1, "bet nėra individe" S_2}∣+∣{(i,j)∣(i,j) "yra individe" S_2, "bet nėra" S_1}∣ $

Jeigu sugeneruojamas neįvykdomas sprendinys, algoritmas gali pabandyti jį sutaisyti ir, priklausomai nuo rezultatų, įtraukti į atitinkamą subpopuliaciją. Šis mechanizmas leidžia išlaikyti balansą tarp paieškos intensyvinimo ir diversifikacijos.

Dar vienas svarbus elementas yra populiacijos valdymas. Tai individų iš įvykdomų ir neįvykdomų sprendinių subpopuliacijų mažiasią tinkamumą turintys individai (t. y. didžiausios kainos ir panašių individų) pašalinimi kas numatytą iteracijų skaičių pagal baudos parametrus, kurie patys yra tikslinami genetinio algoritmo eigos metu; tai palaiko įvairovę ir mažina sprendinių kainą @vidal2012A_Hybr, @vidal2022Hybrid.

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
        spacing: 0.75em,
        alg-line("1", [Sugeneruoti pradinę populiaciją ir pagerinti ją vietine paieška]),
        alg-line("2", [*Kol* iteracijų be pagerėjimo skaičius ir vykdymo laikas neviršija limitų:], bar: true),
        alg-line("3", [Pasirinkti tėvinius individus (dvejetainis turnyras #angl[binary tournament])], indent: 1, bar: true),
        alg-line("4", [Atlikti kryžminimą #angl[crossover]], indent: 1, bar: true),
        alg-line("5", [Išmokyti naują individą (vietinė paieška)], indent: 1, bar: true),
        alg-line("6", [Įterpti išmokytą individą į atitinkamą subpopuliaciją], indent: 1, bar: true),
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

#pagebreak()
= Literatūros analizė

== Testų rinkiniai ir vertinimo metrikos

Vertinimo praktikoje akcentuojama palyginamumo problema. @uchoa2017 pasiūlė naują CVRP testų rinkinį su BKS, o @jastrzab2024Standa rekomenduoja aiškiai apibrėžti laiko matavimą, paleidimų skaičių ir pateikti vidurkius kartu su geriausiais rezultatais. Tokia standartizacija leidžia prasmingai lyginti lygiagretintų ir nuoseklių algoritmų efektyvumą.

Algoritmų lyginimui VRP literatūroje plačiai naudojami standartizuoti testų rinkiniai su geriausiais žinomais sprendiniais (BKS). Vienas iš plačiausiai taikomų yra Uchoa 2017 CVRP rinkinys @uchoa2017, kuriame pateiktos klientų koordinatės, paklausos ir talpos apribojimai, todėl galima lyginti sprendinių kokybę tarp skirtingų algoritmų ir platformų.
Šiame uždavinių rinkinyje apima platų klientų skaičiaus intervalą, todėl leidžia įvertinti algoritmo elgesį didėjant problemos dydžiui.

Kadangi metaheuristikos yra stochastinės, rezultatų vertinimui paprastai naudojami vidurkiai ir geriausi pasiekti sprendiniai iš kelių paleidimų. Spraga nuo BKS išlieka svarbiausia kokybės metrika, tačiau lyginant lygiagretintas ir nuoseklias versijas svarbu vertinti ne tik galutinę spragą, bet ir spragos kitimą per laiką.

Rekomenduojama aiškiai apibrėžti laiko limitus, paleidimų skaičių ir aparatinę įrangą, nes šie veiksniai daro didelę įtaką rezultatų interpretacijai. Standartizuotos metodikos leidžia palyginti tiek algoritmo kokybę, tiek jo greitėjimo potencialą skirtingose platformose.

== Lygiagretinimo kryptys

Lygiagretinimo darbai VRP srityje dažniausiai skirstomi į dvi kryptis: GPU pagrįstą skaičiavimą ir daugiagijes CPU implementacijas. GPU sprendimai leidžia masiškai lygiagretinti kaimynystes, tačiau dažnai reikalauja supaprastinti sprendinio reprezentaciją ir mažina operatorių įvairovę. CPU daugiagijės schemos paprastai išlaiko originalų algoritmo rinkinį, bet jų greitėjimą riboja sinchronizacija ir nuoseklūs populiacijos valdymo etapai.

@abdelatti2020An_imp siūlo genetinį algoritmą, kuris pilnai vykdomas GPU (CUDA): GPU branduoliai atlieka pradinę populiacijos generaciją, kaštų skaičiavimą, kryžminimą, mutaciją ir _2-opt_ vietinę paiešką. Sprendinių kokybei gerinti taikomos _2-opt_ ir artimiausio kaimyno heuristikos, o autoriai pateikia CPU ir GPU versijų palyginimą bei parodo, kad _2-opt_ reikšmingai mažina spragą, nors didina vykdymo laiką.

@yelmewad2021Parall pasitelkia GPU lygiagretinimui. Kiekvienam maršrutui skiriama atskira GPU gija, kuri vykdo vietinės paieškos žingsnį naudojant GPU. Šiuo metodu visiškas išteklių išnaudojimas priklauso nuo to, ar sukurtų maršrutų skaičius sutampa su gijų skaičiumi. Atvejai, kai vietinės paieškos žingsniai modifikuoja kitų maršrutų sprendinį, gijos įrašo savo sprendinius į atskirą masyvą, kuris vėliau yra redukuojamas į vieną sprendinį, pasirenkant geriausią sprendinį. Analogiškai, vėlesniame žingsnyje kiekvienam klientui priskiriama gija. Kiekviena gija apskaičiuoja pagerėjimą ar pablogėjimą apsikeitus vietomis maršrute su kitu klientu. Vietinė paieška apima _swap_ ir _relocate_ (tarp maršrutų) bei _2-opt_, _or-opt_, _3-opt_ (maršruto viduje) heuristikas, o pradinis sprendinys konstruojamas artimiausio kaimyno metodu.

@lei2025Speedi lygiagretinimui vietinės paieškos algoritmą išreiškia tenzorių operatoriais, tai leidžia HGS vykdymą perkelti ant GPU. Taip pagreitintas vietinės paieškos operatorius.
Tačiau @lei2025Speedi pasiūlytas metodas nėra pritaikomas HGS su _swap\*_.
#qi[Dabartinė sprendinių reprezentacija per tensorius neleidžia lengvai įgyvendinti apkarpymo strategijų ir kaimynysčių sumažinimo technikų, kurios dažnai naudojamos vietinės paieškos grįstais algoritmais @lei2025Speedi[33].][the current design of the tensor representation of solutions doesn’t support easy implementation of pruning strategies and neighborhood reduction techniques that are often used in local search-based routing algorithms.]

@pandian2023Effect siūlo ParMDS metodą, kuris jungia MST/DFS pagrįstą konstravimą, lokalią paiešką ir atsitiktinumą, o spartinimui naudoja "OpenMP". Autoriai lygina su GPU pagrįstomis genetinėmis realizacijomis ir pateikia didelį greitėjimą, tačiau jų metodas nėra HGS ir siekia greitai gauti priimtiną sprendinį, o ne maksimalios kokybės sprendinį. Tai rodo, kad bendrojo pobūdžio CPU lygiagretinimas gali pranokti GPU realizacijas, bet metodų tikslai ir kokybės metrika skiriasi.

CPU pagrįsti lygiagretinimai dažniausiai remiasi užduočių lygmens paralelizavimu, kai vienu metu apdorojami keli palikuonys arba keli nepriklausomi HGS paleidimai. Tokie sprendimai riboti, nes populiacijos valdymas ir baudos parametrų reguliavimas išlieka nuoseklūs.

#figure(
  caption: [Lygiagretintas HGS pagal @stadtler2023parallel],
  scale(50%, reflow: true, parallel_hgs)
)

@stadtler2023parallel HGS pritaiko CVRPPD, perkelia tėvų pasirinkimo #angl[selection], kryžminimo #angl[crossover] ir taisymo #angl[repair] žingsnius į atskiras gijas. Kiekviena gija papildomai atlieka vietinę paiešką (_2-opt_, _relocate_, _swap_) pasitelkiant GPU, tačiau nepasitelkia _swap\*_ heuristika, kuri pagal @vidal2022Hybrid padeda surasti aukštesnės kokybės sprendinius.

// Ši schema rodo, kad dalinis operatorių perkėlimas į GPU gali pagreitinti vietinę paiešką, tačiau bendras greitėjimas vis dar priklauso nuo nuoseklių populiacijos valdymo etapų. Dėl to spartinimas dažniausiai mažėja didinant gijų skaičių ir pasiekus tam tikrą lygį pradeda grąžinti mažėjančią naudą.

Priešingai nei dauguma implementacijų @muniasamy2023Effect naudoja grafų duomenų struktūras, panaudojami tik _2-opt_ ir arčiausio kaimyno heuristikos #angl[nearest-neighbor]. Šios heuristikos pritaikytos vykdymui GPU aplinkoje naudojant CUDA.

#figure(
  caption: [HGS su salų modeliu @jamshidi2025A_Para],
  scale(50%, reflow: true, island_model)
) <hgs_island_model>

@jamshidi2025A_Para aprašo _PHGS_ #angl[Parallel Hybrid Genetic Search], kur kombinuoja HGS su salų #angl[islands] modeliu, aprašytu @rezaei2024Explor. #lt_ame(<hgs_island_model>) pavyzdyje parodytas šio algoritmo veikimas. Kiekviena gija vykdo tą patį HGS algoritmą, pridedamas individų migracijos žingsnis, kuris leidžia keistis sprendiniais tarp gijų. // _PHGS_ rodo vos ne du kartus geresnius rezultatus galutiniame laiko momente (žr. #lt_a(<jamshidi2025A_Para_gap_speed>) pavyzdį).

// #figure(
//   caption: [Palyginimas tarp vidutinio tarpo (Y ašis) ir vykdymo laiko (X ašis) @jamshidi2025A_Para.]
// )[#image(width: 50%, "img/44196_2025_1059_Fig6_HTML (Edited).png")] <jamshidi2025A_Para_gap_speed>

@PyVRPwouda2024 pristato "PyVRP" paketą, kuris įgyvendina HGS algoritmą, o našumo kritines dalis realizuoja C++ kalba. Autoriai rodo, kad tokia architektūra leidžia pasiekti mažas spragas CVRP, nors lygiagretinimas nėra pagrindinis jų tikslas. Tai pabrėžia, kad našumą galima gerinti ir per efektyvią realizaciją.

Nemaža dalis literatūros yra aprašiusi tik greitinimą ant GPU. Vis dėlto nemažos dalies pagreitinimų pritaikomumas HGS-CVRP (su _swap\*_ operatoriumi) išlieka atvira problema.

// Apibendrinant, literatūra rodo, kad didžiausias potencialas slypi vietinės paieškos spartinime, tačiau praktinis efektyvumas priklauso nuo to, ar pavyksta suderinti lygiagretumą su algoritmo struktūra. Tai motyvuoja šiame darbe pasirinkti konservatyvų lygiagretinimo variantą, išlaikant pilną HGS operatorių rinkinį.

#pagebreak()
= HGS-CVRP lygiagretinimas

Paimta @vidal2022Hybrid HGS-CVRP algoritmo implementacija#footnote[Nuolatinė repozitorijos nuoroda https://github.com/vidalt/HGS-CVRP/tree/1a927955cd2861a29d978f0d359d6e647db9319c], kuri naudojama kaip pagrindas lygiagretinimui.

Daugiausiai laiko užima vietinės paieškos žingsnis @jamshidi2025A_Para; autoriaus matavimais vietinė paieška užima apie 85% vykdymo laiko. Todėl, siekiant sumažinti viso HGS algoritmo vykdymo laiką, šį žingsnį labiausiai verta lygiagretinti.

HGS-CVRP (su _swap\*_ kaimynystę), pasiekia tą pačią sprendinių kokybę kaip HGS-2012 per dalį skaičiavimo laiko ir jį lenkia bet kuriame laiko taške. _Swap\*_ paieška sudaro iki 32% vietinės paieškos CPU laiko, bet duoda apie 15% visų patobulinimų, todėl lygiagretinant svarbu šią kaimynystę išlaikyti @vidal2022Hybrid. Dėl įgyvendinimo sudėtingumo ši kaimynystė dažnai praleidžiama @stadtler2023parallel @jamshidi2025A_Para.

Lygiagretinimas realizuotas naudojant "OpenMP". Kiekvienoje iteracijoje nuosekliai veikiančioje algoritmo dalyje parenkami $2N$ tėviniai individai ir iš jų sugeneruojami $N$ palikuonių, o vietinė paieška vykdoma lygiagrečiai -- kiekviena gija apdoroja po vieną palikuonį.

Kiekviena gija dirba su savo palikuoniu, o įrašai į bendrą populiaciją atliekami nuosekliai veikiančioje algoritmo dalyje.
Toks lygiagretinimo būdas sumažina sinchronizacijos kaštus. Kiekviena gija įrašo pakeitimus tik į savo individo kopiją. Bendra populiacija atnaujinama tik nuoseklioje sekcijoje, todėl į ją patenka tik jau įvertinti individai.

@parallel_hgs_memory pavyzdys pavaizduoja, kaip kiekvienas algoritmo žingsnis modifikuoja bendrus duomenis.

Sinchronizacija vyksta pasitelkaint "OpenMP" barjerus: po lygiagrečios vietinės paieškos ir taisymo etapų visos nuoseklios algoritmo sekcijos vykdymas blokuojamas iki tol, kol visos gijos baigia mokymo etapą. Nauji individai nuosekliai įterpiami į bendrą populiaciją.

Papildomai, šis lygiagretinimo būdas leidžia išlaikyti _swap\*_ kaimynystę. Šis sprendimas taip pat leidžia išlaikyti HGS populiacijos valdymą vienoje vietoje ir yra paprastesnis nei GPU pagrįstas operatorių perrašymas ar salų modelio migracija.

#figure(
  caption: "Bendros atminties rašymo etapai",
  scale(20%, reflow: true, image("img/parallel_memory.png"))
) <parallel_hgs_memory>

Greitaveiką riboja nuoseklūs žingsniai. Kryžminimo, baudų parametrų tikslinimo bei populiacijos valdymo žingsniai atliekami nuosekliai, todėl dalį laiko visos gijos, išskyrus vieną, neatlieka jokių veiksmų. Be to, prieš populiacijos valdymo žingsnį visos gijos privalo baigti vietinę paiešką, todėl lėtai veikianti gija gali užtęsti visos iteracijos vykdymo laiką.

// == Įgyvendinimo detalės

// Tokiai schemai svarbus deterministinis parametrų valdymas: baudos parametrai ir populiacijos dydis tikslinami tik po barjero, kad visos gijos dirbtų su tuo pačiu kontekstu. Matavimams fiksuotos atsitiktinės sėklos leidžia palyginti skirtingus gijų skaičius, nors dėl stochastinių pasirinkimų identiškas sprendimo kelias nėra garantuojamas.

// Lygiagrečioje schemoje kiekvienos iteracijos trukmę lemia lėčiausia gija, todėl darbo balansavimas tampa svarbus. Jei palikuonių sudėtingumas tarp gijų smarkiai skiriasi, dalis gijų priverstinai laukia barjero, ir realus greitėjimas mažėja.

// Granuliarumo parinkimas yra kompromisas: per mažas kaimynų skaičius sumažina paieškos erdvę ir gali praleisti gerus judesius, o per didelis padidina vykdymo laiką. Šiame darbe naudotos numatytosios algoritmo reikšmės, kad palyginimas su nuoseklia versija būtų korektiškas.

// Be kandidatų sąrašų, dažnai naudojamos iš anksto apskaičiuotos atstumo matricos ir sukaupti maršrutų kaštų komponentai, leidžiantys greitai įvertinti lokalių judesių efektą. Tokios struktūros mažina kiekvieno judesio skaičiavimo kainą ir yra ypač svarbios lygiagretinant vietinę paiešką.


#figure(
  caption: [Lygiagretinto HGS-CVRP pseudokodas (grįstas pagal @vidal2012A_Hybr)]
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
        spacing: 0.5em,
        alg-line("1", [Sugeneruoti pradinę populiaciją ir pagerinti ją vietine paieška]),
        alg-line("2", [*Kol* iteracijų be pagerėjimo skaičius ir vykdymo laikas neviršija limitų:], bar: true),
        alg-line("3", [Pasirinkti $2N$#footnote[N -- gijų skaičius] tėvinius individus (dvejetainis turnyras #angl[binary tournament])], indent: 1, bar: true),
        alg-line("4", [Atlikti kryžminimą #angl[crossover] N kartų], indent: 1, bar: true),
        alg-line("5", [(Kiekvienoje gijoje) išmokyti naują individą], indent: 1, bar: true),
        alg-line("6", [Įterpti išmokytą individą į atitinkamą subpopuliaciją], indent: 1, bar: true),
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

// == Teorinis greitėjimo apribojimas

// Lygiagretinimo teorinį pagreitinimą galima apytiksliai įvertinti Amdahl dėsniu, kuris susieja nuoseklią algoritmo dalį su maksimaliu greitėjimu. Jei algoritmo nuosekli dalis užima $1 - f$ laiko dalį, o likusi $f$ dalis gali būti vykdoma lygiagrečiai, teorinis greitėjimas $S_p$ su $p$ gijų aprašomas:

// $ S_p = 1 / ((1 - f) + f / p) $

// Kadangi vietinė paieška, populiacijos valdymas ir baudos parametrų tikslinimas sudaro apie 85% vykdymo laiko, gaunamas spartėjimas didėjant gijų skaičiui, bet horizontalus prisotinimas. Amdahl modelis fiksuoja, kad sinchronizacijos žingsniai stabdo didėjantį greitėjimą.

// Pasirinktas $f = 0.86$ duoda teorinius greitėjimus 1.75, 2.82, 4.04 ir 5.16 atitinkamai 2, 4, 8 ir 16 gijų.

// Praktiniai duomenys rodo, kad tikrasis greitėjimas (#ref(<speedup-table>)) kartais viršija Amdahl ribas: 2 gijų atveju vidutinė vertė siekia ~2.8, o 16 gijų – ~5.5. Toks elgesys paaiškinamas tuo, kad paralelinės gijos ne tik dalijasi komputaciniais žingsniais, bet ir kuria skirtingų sprendinių versijas bei greičiau pasiekia tikslinį spragą. Pandian et al. @pandian2023Effect ir Yelmewad & Talawar @yelmewad2021Parall taip pat fiksuoja, kad papildoma įvairovė ir GPU sinchronizacijos sumažinimas leidžia pasiekti patenkinamą sprendinį greičiau nei griežtai numatyta nuosekliame modelyje, taigi didesnis greitėjimas nėra registro pažeidimas, o superlinijinis efektas dėl geresnės paieškos pradžios.

#pagebreak()

= Lygiagretintos ir nuoseklios programos palyginimas

== Metodika

_HGS_ ir kiti iteratyvūs algoritmai sustoja pasiekus tam tikrą kriterijų. HGS atveju tai iteracijų skaičius be pagerėjimo arba veikimo laikas. Parinkus per aukštas ribas, algoritmo vykdymo laikas gali būti neprograzuojamas ir užsitęsti ilgiau negu praktiška praktikoje.

Dėl rezultatų palyginamumo pasirinkta naudoti @vidal2022Hybrid aprašytus duomenų rinkinius (@uchoa2017) ir metodiką:
#qi()[Mes stebime kiekvieno algoritmo pažangą iki laiko ribos $𝑇_"max" = 𝑛 dot 240∕100$ sekundžių, kur $n$ reiškia klientų skaičių.
Todėl mažiausias atvejis su 100 klientais vykdomas 4 minutes,
o didžiausias atvejis su 1000 klientų vykdomas 40
minučių. Kiekvieno veikimo metu mes užregistruojame geriausią sprendimo vertę po
1%, 2%, 5%, 10%, 15%, 20%, 30%, 50%, 75% ir 100%
laiko ribos, kad galėtume įvertinti algoritmų našumą skirtinguose
paieškos etapuose @vidal2022Hybrid[6].][We monitor each algorithm’s progress up to a time limit of $𝑇_"max" = 𝑛 dot 240∕100$ seconds, where 𝑛 represents the number of customers.
Therefore, the smallest instance with 100 clients is run for 4 minutes,
whereas the largest instance containing 1000 clients is run for 40
minutes. During each run, we record the best solution value after
1%, 2%, 5%, 10%, 15%, 20%, 30%, 50%, 75%, and 100% of the
time limit to measure the performance of the algorithms at different
stages of the search.]

Šiam eksperimentui iteracijų skaičius be pagerėjimo laikytas begaliniu, o $T_"max" = n dot 24/100$, t. y. 10 kartų mažesnis negu @vidal2022Hybrid, kad būtų sutilpta į MIF STSC išteklių limitus.
Rezultatuose pateikiami 5 paleidimų sprendinių vykdymo laiko ir kainos vidurkiai.
Lygiagretintos programos versija patalpinta "Codeberg" repozitorijoje#footnote[https://codeberg.org/Dom/HGS-CVRP/src/commit/411e391ffefac9a308d28e280194d65004d8332c].

Naudoti algoritmo ir vykdymo parametrai pateikti #lt_ame(<priedas-params>) priede. Dauguma parametrų palikti pagal numatytas reikšmes, o eksperimente fiksuoti gijų skaičius, atsitiktinės atrankos sėkla #angl[randomization seed] ir laiko limitas.

== Eksperimentinė aplinka

Šiame darbe analizuotas Uchoa 2017 X-n uždavinių rinkinys.
Palyginimui naudoti geriausių sprendinių rinkiniai#footnote[https://galgos.inf.puc-rio.br/cvrplib/index.php/en/instances, prieigos data: 2026-01-07].

Vykdimo duomenys surinkti paleidžiant lygiagretintą ir palyginimui originalią HGS-CVRP programos versijas. Naudotodos įrangos konfiguracija: "Intel® Xeon® Gold 6252" procesorius, 384GiB atmintis, "Qlustar 13" ("Ubuntu" pagrindas) opracinė sistema.

#todo[restore original par]
// Kadangi spragos mažėjimo fazė sutraukia 90–99% vykdymo laiko, @yelmewad2021Parall ir @abdelatti2020An_imp pabrėžia, kad svarbu fiksuoti realų laiką #angl[wall-clock] ir negryninti CPU laiko sumos. Vadovaujamės tomis rekomendacijomis, todėl matavimai fiksuojami tiesiogiai iš sistemos laikrodžio ir užfiksuojamas tik geriausias sprendimas kiekviename 1% žingsnyje.

// == Duomenų surinkimas ir apdorojimas

// Duomenys renkami fiksuojant geriausio sprendinio spragą nustatytais laiko momentais. Taip sudaromos spragos laiko eilutės, kurios vėliau naudojamos palyginti skirtingus gijų skaičius.

// Pagrindiniai duomenų apdorojimo žingsniai:
// 1. Kiekvienai instancijai atliekami keli paleidimai su skirtingomis sėklomis.
// 2. Kas 1% laiko limito užregistruojama geriausia spraga.
// 3. Rezultatai agreguojami ir skaičiuojami vidurkiai pagal gijų skaičių.
// 4. Spraga nustatoma kaip bazinės viengijos spraga pabaigoje, o kiekviena gijų konfigūracija vertinama pagal pirmą etapą, kuriame ši spraga arba geresnė pasiekiama.

== Rezultatai

#let x_gap_result = gap_data(instances: x_vrp_instances)
// #let golden_gap_result = gap_data(instances: golden_instances)
#let table_100ths_x = table_100_avg_from(x_gap_result)
// #let table_100ths_golden = table_100_avg_from(golden_gap_result)
#let gap_threads_table = table_gap_threads_from(x_gap_result)
#let gap_speedup_table = table_gap_speedup_from(x_gap_result)
// #let gap_threads_table = table_gap_threads_from(x_gap_result)
// #let gap_speedup_table = table_gap_speedup_from(x_gap_result)

#grid(
  columns: 2,
  gutter: 2em,
  figure(
    caption: [Vidutinė sprendinių spraga pagal gijų skaičių per vykdymo laiką (Uchoa 2017 X-n rinkinys)]
  )[#scale(60%, reflow: true)[#gap_threads_plot_from(x_gap_result)]],
  figure(
    caption: [Vidutinės sprendinių spragos santykis tarp viengijio ir N gijų sprendimų (Uchoa 2017 X-n rinkinys)]
  )[#scale(65%, reflow: true)[#gap_speedup_plot_from(x_gap_result) #v(1em)]]
)

Vidutinių spragų kreivė parodo, kad lygiagreti versija sparčiau mažina spragą ne tik galutiniame taške, bet ir ankstyvuose etapuose. Santykio grafikas, pateiktas šalia, įrodo, jog grąža didėja greitai iki 8 gijų, o vėlesnėse stadijose stagnuoja – analogiškas prisotinimas aptariamas @pandian2023Effect ir @stadtler2023parallel, kai sinchronizacijos kaštai ima dominuoti. 16 gijų atveju galutinis santykis apie 1.8 artimas @jamshidi2025A_Para rezultatams, tačiau tiesioginis palyginimas ribotas dėl skirtingų $T_"max"$ ir aparatinės įrangos.

// // Pagreitėjimo duomenys:
// #let amdahl_parallel_fraction = 0.86
// #let x_time_to_target = time_to_target_data(instances: x_vrp_instances)
// #x_time_to_target.series

// #grid(
//   columns: 2,
//   gutter: 1.5em,
//   figure(
//     caption: [Tikrasis greitėjimas (vidurkiai per 5 paleidimus) lyginant su laiko $T_"max"$]
//   )[#scale(85%, reflow: true)[#speedup_plot_from(x_time_to_target)]],
//   figure(
//     caption: [Teorinis Amdahl greitėjimo apribojimas ($f$ = #format_2(amdahl_parallel_fraction * 100)%)]
//   )[#scale(85%, reflow: true)[#amdahl_speedup_plot(parallel_fraction: amdahl_parallel_fraction, threads: x_time_to_target.threads)]]
// )


// #figure(
//   caption: [Tikrasis ir teorinis greitėjimas (gijų skaičius, $S_p$ ir $E_p$)]
// )[
//   #table(
//     columns: 4,
//     align: (left, right, right, right),
//     table.header(
//       [Gijų skaičius],
//       [Tikr. greitėjimas $S_p$],
//       [Teorinis $S_p$ (Amdahl, $f$ = #format_2(amdahl_parallel_fraction * 100)%)],
//       [Efektyvumas $E_p$],
//     ),
//     ..x_time_to_target.map(row => (
//       table.cell(breakable: false)[#str(row.thread)],
//       table.cell(breakable: true)[#fmt_speedup(row.speedup)],
//       table.cell(breakable: true)[#fmt_speedup(row.theoretical)],
//       table.cell(breakable: true)[#fmt_speedup(row.efficiency_p50)],
//     )).flatten(),
//   )
// ] <speedup-table>

// Tikrojo greitėjimo figūra parodo, kad 2, 4, 8 ir 16 gijų atveju vidutinės vertės yra maždaug 2.81, 3.66, 4.85 ir 5.48 (lentelė #ref(<speedup-table>)). Teorinis Amdahl greitėjimas (1.75, 2.82, 4.04, 5.16) pateiktas šalia esančioje diagramoje, tačiau skirtumas paaiškinamas tuo, kad paralelinės gijos kuria daugiau sprendinių variantų ir pirmos pasiekia tikslinį spragos slenkstį. Tokie superlinijiniai efektai taip pat pastebimi `@pandian2023Effect`, `@yelmewad2021Parall` ir `@abdelatti2020An_imp`, kai papildomi leidimai bei GPU sinchronizacijos sumažinimas leidžia greičiau pagerinti sprendinius.
// Efektyvumas (#ref(<speedup-table>)) krenta nuo 1.00 iki maždaug 0.34 16 gijų atveju, kas rodo, kad sinchronizacija ir laukimo laikai ima dominuoti.
#pagebreak()
#set heading(numbering: none)
= Rezultatai ir išvados

== Rezultatai

1. Parinktas duomenų rinkinys, pagal kurį galima testuoti ir analizuoti sprendinius.
2. Atlikta HGS algoritmo veikimo analizė ir aprašyta HGS-CVRP specifika.
3. Įgyvendintas vietinės paieškos lygiagretinimas ir aprašyta lygiagretinimo schema.
4. Pateiktas rezultatų palyginimas.

== Išvados

1. Lygiagreti vietinė paieška HGS-CVRP algoritme pagerina sprendinių kokybę per tą patį laiko limitą.
2. Schema išsaugo pilną HGS kaimynysčių rinkinį (įsk. _swap\*_), tačiau pagreitėjimą riboja nuoseklūs populiacijos valdymo ir baudos parametrų tikslinimo žingsniai bei gijų sinchronizacija, todėl nauda didinant gijų skaičių mažėja.

#pagebreak()
= Priedai

#set heading(numbering: "1.")
#counter(heading).update(0)
#set text(size: 10pt)
#show figure.where(kind: table): set block(breakable: true)

= Priedas. Eksperimento parametrai <priedas-params>

#figure(
  caption: [Eksperimento parametrai]
)[#table_experiment_params()] <tab-params>

= Priedas. Vidutinės pasiektos sprendimų kainos ir spraga galutiniu laiko momentu <priedas-costs-x>
#figure(
  block(breakable: true, width: 118%)[#table_100ths_x],
    caption: [Vidutinės pasiektos sprendimų kainos ir spraga galutiniu laiko momentu]
)

#pagebreak()
#set heading(numbering: none)
#set text(size: 12pt)
#bibliography(title: [Šaltiniai], "bibliography.bib")

// = The bad list
// - A Hybrid Approach for Simultaneous Effective Automobile Navigation with DE and PSO (2024)
