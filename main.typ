#import "style.typ": style
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
// #import "tables/table_parallel_compare.typ": table_parallel_compare
#import "diagrams/hgs_flowchart.typ": hgs_flowchart
#import "diagrams/parallel_hgs_arch.typ": parallel_hgs_diagram
#import "diagrams/parallel_hgs_memory.typ": parallel_hgs_memory
#import "diagrams/island_model.typ": island_model
#import "diagrams/time_target_speedup.typ": speedup_plot_from, efficiency_plot_from
#import "diagrams/neiborhoods.typ": neiborhoods
// #import "diagrams/parallel_hgs_thread_flow.typ": parallel_hgs_thread_flow
#import "@preview/drafting:0.2.2": *
#import "@preview/lovelace:0.3.0": *
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
  date: "Vilnius – 2025",
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

Kaimynystė (angl. _neighborhood_) – žingsnių seka, kuri duoda skirtingus sprendinius, iš dabartinio sprendinio atlikus vieną lokalų pakeitimą (pvz., perkelti klientą, sukeisti du klientus ar apversti maršruto atkarpą).
- HGS – Hibridinis genetinis paieškos algoritmas (angl. _Hybrid Genetic Search_).
- VRP – Transporto maršrutų optimizavimo uždavinys (angl. _Vehicle Routing Problem_).
- CVRP – angl. _Capacitated Vehicle Routing Problem_. Kiekviena transporto priemonė turi maksimalią siuntų talpą.
- VRPTW – angl. _VRP with Time Windows_. Kiekvienas klientas turi pradžios ir pabaigos laiką.
- GVRP – angl. _Generalized VRP_. Klientai grupuojami į klasterius. Tik vienas klientas iš viso klasterio turi būti aplankytas.
- CluVRP – angl. _Clustered VRP_. Klientai grupuojami į klasterius. Visi klientai klasteryje turi būti aplankyti prieš vykstant į kitą klasterį.
- SoftCluVRP – angl. _Soft Clustered VRP_. CluVRP variantas, kuriame į klasterį leidžiama aplankyti kelis kartus.
- MDVRP – angl. _Multidepot VRP_. VPR su daugiau nei vienu depu.
- PVRP – angl. _Periodic VRP_. VRP su pridėta laiko dimensija, sprendinys sudaromas iš kelių maršrutų rinkinių, atitinkančių dienas, kuriomis bus aplankomi klientai.
- MDPVRP – angl. _Multidepot Periodic VRP_. MDVRP ir PVRP kombinacija.
- CVRPPD – angl. _CVRP Pickup and Delivery_. CVRP ir VRPPD kombinacija.
- BKS – Geriausias žinomas sprendinys (angl. _Best Known Solution_).
- CPU - procesorius.
- GPU – Grafikos procesorius (angl. _Graphics Processing Unit_).
- Populiacija – individų rinkinys.
- Individas – uždavinio sprendinys, t. y. maršrutų rinkinys.
- Įvykdomas sprendinys – sprendinys, tenkinantis visus uždavinio apribojimus.

#pagebreak()

= Įvadas

VRP – transporto maršrutų optimizavimo uždavinys #angl[vehicle routing problem] – yra uždavinys, kurio tikslas yra surasti kuo optimaliausią maršrutų rinkinį (t. y. kuo mažiausią maršruto kainą, žr. #ref(<math_cost>)). Optimaliai parinkti maršrutai lemia, kiek klientų įmanoma aplankyti per nustatytą laiką, bei padeda sumažinti transporto kaštus. Pirmą kartą ši problema aprašyta @dantzig1959The_Tr darbe, kur autoriai pristatė algoritmą, randantį optimalius maršrutus tarp kuro depo ir degalinių. Tai yra vienas iš modernios logistikos optimizavimo uždavinių – net maži maršrutų pagerinimai realiame pasaulyje gali reikšti reikšmingas sąnaudų ir pristatymo laiko taupymo galimybes. Keliaujančio pardavėjo uždavinyje pagrindinė užduotis yra surasti optimaliausią kelią vienam keliautojui (pardavėjui), o VRP sprendiniai susidaro iš kelių keliautojų – literatūroje šie keliautojai vadinami transporto priemonėmis.

Hibridinis genetinės paieškos algoritmas yra vienas iš efektyviausių genetinių metaheuristinių algoritmų @petropoulos2023Operat. Šis algoritmas ir vėlesnės pagerintos versijos išlieka etalonas daugeliui VRP variantų, "DIMACS" konkurse @dimacs2022vrp parodęs geriausius rezultatus VRPTW uždavinyje @kool2022hybrid, ir kurio modifikuotas variantas @jiang2022fhcsolver pasirodė geriausiai CVRP uždavinyje. Šis algoritmas yra pritaikytas CVRP, VRPTW, GVRP @latorre2025A_hybr, CluVRP, SoftCluVRP @latorre2025An_appHybr.

Šio *darbo tikslas* – išlygiagretinti hibridinį genetinį paieškos algoritmą, skirtą transporto maršrutų optimizavimo uždaviniams spręsti,
siekiant sumažinti vykdymo laiką neprarandant ar net pagerinant sprendinių kokybę.

*Uždaviniai:*

1. Išsirinkti duomenų rinkinį, pagal kurį galima būtų testuoti ir analizuoti sprendinius.
2. Išanalizuoti, kaip veikia HGS algoritmas.
3. Atrinkti lygiagretinamas dalis, kurias galima pakeisti lygiagrečiomis.
4.Palyginti rezultatus su literatūroje aprašytais pažangiausiais algoritmais.

#pagebreak()

#set heading(numbering: "1.")
= Transporto maršrutų optimizavimo uždaviniai

== Tikslūs ir apytiksliai metodai

Nors egzistuoja įrankiai, pasitelkiantys tikslius metodus (pavyzdžiui, "Google OR-Tools" @ortools), šis uždavinys priklauso _NP-hard_ sudėtingumo klasei, todėl praktikoje dominuoja heuristikomis ir metaheuristikomis grįsti algoritmai. Tikslūs metodai (dažniausiai mišrus sveikųjų skaičių programavimas #angl[mixed integer programming], ar šakojimosi ir ribų #angl[branch & bound], metodai) suranda optimaliausius sprendinius, tačiau jų skaičiavimo laikas sparčiai auga didėjant uždavinio dydžiui. Dėl to jie tampa nepraktiški dideliems uždaviniams – pavyzdžiui, tik mažesni VRP uždaviniai išsprendžiami tiksliais metodais per optimalų laiką. Tokie metodai dažniau taikomi mažesnėms problemoms.
Tuo tarpu metaheuristiniai algoritmai šioje uždavinių klasėje išsiskiria efektyvumu – jie per priimtiną laiką randa beveik optimalius sprendinius, pasižyminčius aukšta kokybe, ir dėl to yra tinkamesni realiems logistikos uždaviniams.

Šiam uždaviniui dažniau naudojami heuristiniai ir metaheuristiniai algoritmai, jos išlieka patrauklios realiems logistikos uždaviniams. Metaheuristika – aukštesnio lygio strategija, kuri parenka, kurias heuristikas taikyti, kad sprendiniai būtų randami efektyviau. Keli dominuojantys pavyzdžiai @adamo2024A_revi:

  - "Adaptive Large Neighborhood Search" ir "Hybrid Adaptive Large Neighborhood Search";

  - "Hybrid Genetic Search" (HGS);

  - "Simulated Annealing Algorithm" (SAA);

  - "Ant colony optimization" (ACO).

== VRP variacijos

Egzistuoja ir VRP variacijos (CVRP, VRPTW, MDPVRP, PVRP ir kt.).
Jos įveda papildomus apribojimus, pavyzdžiui: maršrutų ilgiui, transporto priemonių panaudojimo laikui ir talpai, arba prideda papildomas sąlygas:
- naudojamos transporto priemonės turi limituotą talpą (CVRP);
- visi klientai gali būti aplankyti tik specifinėmis darbo valandomis (VRPTW);
- keli depai, iš kurių galima pradėti maršrutą (MDVRP);
- maršrutai planuojami per kelias dienas, t. y. vieni klientai gali būti aplankyti vieną dieną, o kiti kitą (PVRP);
- kt.
Šis darbas atsižvelgia tik į CVRP uždavinį.

== CVRP

CVRP nagrinėjamas grafas $G = (V, E)$, kuriame $v_0 in V$ žymi depą, kuris turi $m$ transporto priemonių, o likusios viršūnės ${v_1, ..., v_(|V|)}$ atitinka klientus, kuriuos reikia aplankyti. Kiekviena briauna $(i, j) in E$ reiškia galimybę keliauti tarp vietų $i$ ir $j$ su kaina $c_(i,j)$ – euklidinis atstumas tarp vietų $i$ ir $j$. CVRP reikia surasti sprendinį, kuriame panaudotos ne daugiau kaip $K$ transporto priemonių, prasidedančių ir pasibaigiančių depe, taip, kad kiekvienas klientas būtų aplankytas vieną kartą ir bendras klientų paklausos dydis bet kuriame maršrute neviršytų transporto priemonės talpos $Q$, o bendras transporto priemonių nuvažiuotas atstumas – kaina (žr. #ref(<math_cost>)) – būtų kiek įmanoma mažesnis.

$ c_(i, j) = sqrt((x_i - x_j)^2 + (y_i - y_j)^2) $
<math_dist>

$
  "Sprendinio kaina" &= &&sum_(k=1)^(K) sum_(i=0)^(|V|) sum_(j=0)^(|V|) c_(i,j) x_(i,j,k) \
  x_(i,j,k) &= &&1 "Indikatorinė" "funkcija", "kuri" \
  & &&"lygi" 1, "jei" "transporto" "priemonė" k " " (1 <= k <= K)\
  & &&"keliauja" "nuo" "kliento" i "iki" "kliento" j, \
  & &&"lygi" 0 "priešingu" "atveju"
$ <math_cost>

Lyginant transporto maršrutų optimizavimo uždavinio sprendinius naudojama spraga #angl[gap], nusakanti atstumą procentais nuo geriausio sprendinio #angl[Best Known Solution - BKS] @math_gap.

$
  "Spraga" &= ((Z_s - Z_"BKS") / Z_"BKS") dot 100% \
  Z_s &= #[Pasirinkto algoritmo sprendinio kaina] \
  Z_"BKS" &= #[Geriausio sprendinio kaina]
$ <math_gap>

#pagebreak()
= HGS algoritmo veikimas

HGS algoritmas pirmiausia sukurtas MDPVRP spręsti @vidal2012A_Hybr. Algoritmas patobulintas per daugelį iteracijų @vidal2014A_unif, @vidal2016Large_, @vidal2017Node__, @vidal2021Arc_Ro, @vidal2022Hybrid, ir pritaikytas CVRP. Pastarasis variantas vadinamas HGS-CVRP, o pirmasis HGS-2012.

Genetiniai algoritmai imituoja evoliucijos procesą. Populiacija yra aibė, kurią sudaro individai (t. y. užduoties sprendiniai). Šie algoritmai kombinuoja (dar vadinama kryžminimu) individus, kad sukurti naują individą palikuonį #angl[offspring], jį mutuoja ir prideda prie visų individų aibės – populiacijos. Kad genetinio algoritmo eiga pernelyg nesulėtėtų, prasčiausi individai yra pašalinami iš populiacijos.

HGS pradinę populiaciją sukuria taikant greitas konstravimo heuristikas.
Kryžminimo operacija sukuria vieną ilgą maršrutą, kuris vėliau efektyviai sukarpomas į kelis maršrutus pasitelkiant _Split_ kaimynystę ir prideda prie populiacijos (#lt_ame(<hgs_flowchart>) pavyzdyje 1-as žingsnis).

Tėvų atranka palikuoniui vykdoma dvejetainiu turnyru #angl[binary tournament]. Kryžminimui parenkami du individai kurių tinkamumas #angl[fitness], t. y. sprendinio kainos ir įvairovės (_broken-pairs_ atstumo) suma yra didžiasios, ir išrenkami didžiausią tinkamumą turintys individai.

HGS populiacija yra sudaryta iš įvykdomų ir neįvykdomų subpopuliacijų, t. y. tų individų, kurie atitinka uždavinio apribojimus ir tų kurie jų neatitinka.
Palaikant neįvykdomus #angl[infeasible] ir įvykdomus #angl[feasible] individus, išlaikoma populiacijos įvairovė #angl[diversity], kuri leidžia išvengti lokalaus minimumo #angl[local minima] beieškant geriausio individo. Neįvykdomi individai taip pat per kelias algoritmo vykdymo iteracijas gali tapti įvykdomais, todėl palaikant neįvykdomų individų subpopuliaciją, patikrinama daugiau skirtingų sprendinių.

// $ δ(S1​,S2​)=∣{(i,j)∣(i,j) "yra individe" S_1, "bet nėra individe" S_2}∣+∣{(i,j)∣(i,j) "yra individe" S_2, "bet nėra" S_1}∣ $

#figure(
  caption: [HGS veikimas @vidal2022Hybrid],
  scale(65%, reflow: true, hgs_flowchart)
) <hgs_flowchart>

HGS prie genetinio komponento prideda pagerinimo žingsnį (dar vadinama mokymo ar taisymo žingsniu) – vietinę paiešką #angl[local search], kuri po kryžminimo žingsnio pritaikoma naujam individui, siekiant pagerinti gauto individo kokybę (#lt_ame(<hgs_flowchart>) pavyzdyje 3 žingsnis).

Vietinė paieška vykdoma iteratyviai taikant kelias kaimynystes, kol nebelieka gerinančių judesių. Kaimynystės _relocate_ ir _swap_ leidžia keisti klientų vietas tarp maršrutų, o _2-opt_ ir _2-opt\*_ koreguoja maršruto vidinę struktūrą. _Swap\*_ yra brangiausia, bet dažnai duodanti didžiausią pagerėjimą kaimynystė. Esminis patobulinimas leidžiantis HGS-CVRP pasiekti vienus iš geriausių rezultatų yra _Swap\*_ kaimynystės pridėjimas prie prieš tai naudojamų kaimynysčių.

_Swap\*_ kaimynystėje du klientai iš skirtingų maršrutų išimami ir kiekvienas įterpiamas į bet kurią kito maršruto poziciją; nors galimų judesių labai daug, geriausiam judesiui pakanka tikrinti įterpimą į tą pačią vietą arba į vieną iš trijų geriausių iš anksto įvertintų pozicijų, todėl kaimynystė tiriama efektyviai. Toks apribojimas sumažina vietinės paieškos sudėtingumą nuo kvadratinio iki maždaug tiesinio pagal klientų skaičių, kartu išlaikant pakankamai gerą sprendinių kokybę @vidal2022Hybrid. Jeigu po vietinės paieškos individas yra neįvykdomas, su 50 % tikimybe taikoma taisymo procedūra (pakartotinė vietinė paieška).

#figure(caption: [Įvairių kaimynysčių veikimas])[#neiborhoods]

Jeigu po vietinės paieškos individas yra neįvykdomas, algoritmas jį, su 50 % tikimybe, bando taisyti (t. y. vėl taikyti vietinę paiešką) ir, priklausomai nuo rezultatų, individas yra įterpiamas į atitinkamą subpopuliaciją. Šis mechanizmas taip taupo procesoriaus išteklius bei išlaiko didesnę įvairovę.

Paskutinis HGS elementas yra populiacijos valdymas, tai individų iš įvykdomų ir neįvykdomų subpopuliacijų mažiausią tinkamumą turinčių individų (t. y. didžiausios kainos ir panašių individų) pašalinimas kas numatytą iteracijų skaičių pagal baudos parametrus. Šie baudos parametrai yra kiekvieną ciklą patikslinami, kad būtų išlaikytas balansas tarp įvykdomų ir neįvykdomų subpopuliacijų, tai vėl palaiko įvairovę ir mažina sprendinių kainą @vidal2012A_Hybr, @vidal2022Hybrid.

Svarbus niuansas – atrenkant tik geriausius individus, populiacija tampa mažai įvairi, t. y. visi individai yra identiški arba beveik identiški. Tai gali sukelti problemų, nes populiacija gali praleisti geriausius sprendinius, kurie nėra panašūs į esamus sprendinius populiacijoje. Šiai problemai išvengti populiacijos valdymo metu paliekami nebūtinai geriausios kainos sprendimai, bet ir tie, kurie yra labiausiai skirtingi.

#figure(
  caption: [HGS algoritmo pseudokodas @vidal2012A_Hybr],
  pseudocode-list(booktabs: true)[
  + Sugeneruoti pradinę populiaciją ir pagerinti ją vietine paieška
  + *Kol* iteracijų be pagerėjimo skaičius ir vykdymo laikas neviršija limitų:
    + Pasirinkti tėvinius individus (dvejetainis turnyras #angl[binary tournament])
    + Atlikti kryžminimą #angl[crossover]
    + Išmokyti naują individą (vietinė paieška)
    +Įterpti išmokytą individą į atitinkamą subpopuliaciją
    + *Jeigu* individas neįvykdomas:
      + Su 50 % tikimybe bandyti sutaisyti individą ir įtraukti į atitinkamą subpopuliaciją
    + *Jeigu* pasiektas maksimalus populiacijos dydis
      + Pašalinti blogiausius ir neįvairius individus iš populiacijos
    + Patikslinti baudos parametrus #angl[penalty parameters]
  + Grąžinti geriausią įvykdomą individą
  ]
) <algo>


#pagebreak()
= Literatūros analizė

== Testų rinkiniai ir vertinimo metrikos

// Vertinimo praktikoje akcentuojama palyginamumo problema. @uchoa2017 pasiūlė naują CVRP testinių duomenų rinkinį. o @jastrzab2024Standa rekomenduoja aiškiai apibrėžti laiko matavimą, paleidimų skaičių. Tokia standartizacija leidžia prasmingai lyginti lygiagretintų ir nuoseklių algoritmų efektyvumą.

Algoritmų lyginimui VRP literatūroje plačiai naudojami standartizuoti testų rinkiniai su geriausiais žinomais sprendiniais (BKS). Vienas iš plačiausiai taikomų yra Uchoa 2017 CVRP rinkinys @uchoa2017. Šis uždavinių rinkinys apima platų įmanomų uždavinių skirtumus: maršruto ilgis, depo pradinė vieta, klientų pasiskirstymas ir geografinis tankumas. Todėl galima tiksliau įvertinti algoritmo charakteristikas skirtinguose uždavinių tipuose.

Kadangi metaheuristikos yra stochastinės, rezultatų vertinimui paprastai naudojami vidurkiai ir geriausi pasiekti sprendiniai iš kelių paleidimų. Spraga nuo BKS išlieka svarbiausia algoritmo kokybės metrika.

Rekomenduojama aiškiai apibrėžti laiko limitus, paleidimų skaičių ir aparatinę įrangą, nes šie veiksniai daro didelę įtaką rezultatų interpretacijai. Standartizuotos metodikos leidžia palyginti tiek algoritmo kokybę, tiek jo greitėjimo potencialą skirtingose platformose.

== Lygiagretinimo kryptys

Lygiagretinimo literatūra HGS srityje orientuojasi į GPU pagrįstą skaičiavimą, kartais pasitelkiant daugiagijes CPU realizacijas. GPU sprendimai leidžia masiškai lygiagretinti kaimynystes, tačiau dažnai reikalauja supaprastinti sprendinio reprezentaciją ir mažina kaimynysčių įvairovę.

@abdelatti2020An_imp siūlo genetinį algoritmą, kuris visiškai vykdomas GPU (CUDA): GPU branduoliai atlieka pradinę populiacijos generaciją, kainų skaičiavimą, kryžminimą, mutaciją ir _2-opt_ vietinę paiešką. Sprendinių kokybei gerinti taikomos _2-opt_ ir artimiausio kaimyno #angl[nearest neighbor] heuristikos, o autoriai pateikia CPU ir GPU versijų palyginimą bei parodo, kad _2-opt_ reikšmingai mažina spragą, nors didina vykdymo laiką.

@yelmewad2021Parall pasitelkia GPU lygiagretinimui. Kiekvienam maršrutui skiriama atskira GPU gija, kuri vykdo vietinės paieškos žingsnį naudojant GPU. Šiuo metodu visiškas išteklių išnaudojimas priklauso nuo to, ar sukurtų maršrutų skaičius sutampa su gijų skaičiumi. Jei vietinės paieškos žingsniai modifikuoja kitų maršrutų sprendinį, gijos įrašo savo sprendinius į atskirą masyvą, kuris vėliau yra redukuojamas į vieną sprendinį, pasirenkant geriausią sprendinį. Analogiškai, vėlesniame žingsnyje kiekvienam klientui priskiriama gija. Vietinė paieška apima _swap_ ir _relocate_ (tarp maršrutų) bei _2-opt_, _or-opt_, _3-opt_ (maršruto viduje) kaimynystes, o pradinis sprendinys konstruojamas artimiausio kaimyno metodu.

#figure(
  caption: [Lygiagretinto HGS veikimo CPU ir GPU pavyzdys iš @stadtler2023parallel[11]],
  scale(50%, reflow: true, parallel_hgs_diagram)
) <parallel_hgs>

Vienas iš lygiagretintų HGS variantų, pritaikytas pilnai išnaudoti aukšto našumo skaičiavimo #angl[high-performance computing] sistemas @stadtler2023parallel, pasitelkia tiek CPU, tiek GPU resursus (žr. #lt_a(<parallel_hgs>) pavyzdį). Šis algoritmo variantas, skirtas CVRPPD spręsti, perkelia tėvų atrankos #angl[selection], kryžminimo #angl[crossover] žingsnius į atskiras CPU gijas skirtinguose kompiuterių tinklo mazguose (angl. _node_). Kiekviena gija papildomai atlieka vietinę paiešką (_2-opt_, _relocate_, _swap_) pasitelkiant GPU, tačiau nenaudoja _swap\*_ kaimynystės. Nepaisant to, kad vieno mazgo našumas nėra pranašesnis, uždaviniai su ypač dideliais duomenų kiekiais taip gali būti greičiau apskaičiuoti negu įprastas HGS, vykdantis skaičiavimus vienu procesoriumi.

@lei2025Speedi lygiagretinimui vietinės paieškos algoritmą išreiškia tenzorių aritmetinėmis operacijomis, tai leidžia HGS vykdymą perkelti ant GPU. Taip pagreitintas vietinės paieškos operatorius. Tačiau @lei2025Speedi pasiūlytas metodas nėra pritaikomas HGS su _swap\*_.
#qi[Dabartinė sprendinių reprezentacija per tenzorius neleidžia lengvai įgyvendinti apkarpymo strategijų ir kaimynysčių mažinimo technikų, kurios dažnai naudojamos vietine paieška grįstuose algoritmuose @lei2025Speedi[33].][The current design of the tensor representation of solutions doesn’t support easy implementation of pruning strategies and neighborhood reduction techniques that are often used in local search-based routing algorithms.]

Priešingai nei dauguma realizacijų, "ParMDS" naudoja grafų duomenų struktūras; panaudojami tik _2-opt_ ir artimiausio kaimyno heuristikos (angl. _nearest-neighbor_). Šios heuristikos pritaikytos vykdymui GPU aplinkoje naudojant CUDA @muniasamy2023Effect.
Autoriai lygina su GPU pagrįstomis genetinėmis realizacijomis ir pateikia didelį greitėjimą, tačiau jų metodas nėra HGS ir siekia greitai gauti priimtiną sprendinį, o ne maksimalios kokybės sprendinį.

// CPU pagrįsti lygiagretinimai dažniausiai remiasi užduočių lygmens paralelizavimu, kai vienu metu apdorojami keli palikuonys arba keli nepriklausomi HGS paleidimai. Tokie sprendimai riboti, nes populiacijos valdymas ir baudos parametrų reguliavimas išlieka nuoseklūs.

// Ši schema rodo, kad dalinis operatorių perkėlimas į GPU gali pagreitinti vietinę paiešką, tačiau bendras greitėjimas vis dar priklauso nuo nuoseklių populiacijos valdymo etapų. Dėl to spartinimas dažniausiai mažėja didinant gijų skaičių ir pasiekus tam tikrą lygį pradeda grąžinti mažėjančią naudą.

#figure(
  caption: [HGS su salų modeliu @jamshidi2025A_Para],
  scale(50%, reflow: true, island_model)
) <hgs_island_model>

_PHGS_ (angl. _Parallel Hybrid Genetic Search_) lygiagretina HGS su salų (angl. _islands_) modeliu @jamshidi2025A_Para @rezaei2024Explor. #lt_ame(<hgs_island_model>) pavyzdyje parodytas algoritmo veikimas: kiekviena gija vykdo tą pačią HGS algoritmo versiją, o migracijos žingsnis leidžia periodiškai keistis sprendiniais tarp gijų.

// #figure(
//   caption: [Palyginimas tarp vidutinio tarpo (Y ašis) ir vykdymo laiko (X ašis) @jamshidi2025A_Para.]
// )[#image(width: 50%, "img/44196_2025_1059_Fig6_HTML (Edited).png")] <jamshidi2025A_Para_gap_speed>

@PyVRPwouda2024 pristato "PyVRP" paketą, kuris įgyvendina HGS algoritmą, o našumo kritines dalis realizuoja C++ kalba. Autoriai rodo, kad tokia architektūra leidžia pasiekti mažas spragas CVRP, nors lygiagretinimas nėra pagrindinis jų tikslas. Tai pabrėžia, kad našumą galima gerinti ir per efektyvią realizaciją.

Nemaža dalis literatūros yra aprašiusi tik greitinimą ant GPU. Vis dėlto nemažos dalies pagreitinimų pritaikomumas HGS-CVRP (su _swap\*_ operatoriumi) išlieka atvira problema.

// Apibendrinant, literatūra rodo, kad didžiausias potencialas slypi vietinės paieškos spartinime, tačiau praktinis efektyvumas priklauso nuo to, ar pavyksta suderinti lygiagretumą su algoritmo struktūra. Tai motyvuoja šiame darbe pasirinkti konservatyvų lygiagretinimo variantą, išlaikant pilną HGS operatorių rinkinį.

#pagebreak()
= HGS-CVRP lygiagretinimas

Paimta @vidal2022Hybrid HGS-CVRP algoritmo realizacija#footnote[Nuoroda į saugyklą: https://github.com/vidalt/HGS-CVRP/tree/1a927955cd2861a29d978f0d359d6e647db9319c], kuri naudojama kaip pagrindas lygiagretinimui.

Daugiausiai laiko užima vietinės paieškos žingsnis @jamshidi2025A_Para, @vidal2022Hybrid; autoriaus matavimais vietinė paieška užima apie 86 % vykdymo laiko (naudojant "gprof" profiliavimo įrankį). Todėl, siekiant sumažinti viso HGS algoritmo vykdymo laiką, šį žingsnį labiausiai verta lygiagretinti.

HGS-CVRP (su _swap\*_ kaimynyste) pasiekia tą pačią sprendinių kokybę kaip HGS-2012 per dalį skaičiavimo laiko ir jį lenkia bet kuriame laiko taške. _Swap\*_ paieška sudaro iki 32 % vietinės paieškos CPU laiko, bet duoda apie 15 % visų patobulinimų, todėl lygiagretinant svarbu šią kaimynystę išlaikyti @vidal2022Hybrid. Dėl įgyvendinimo sudėtingumo ši kaimynystė dažnai praleidžiama @stadtler2023parallel @jamshidi2025A_Para.

#figure(
  caption: [Lygiagretinto HGS-CVRP pseudokodas (grįstas pagal @vidal2012A_Hybr)],
  pseudocode-list(booktabs: true)[
  + Sugeneruoti pradinę populiaciją ir pagerinti ją vietine paieška
  + *Kol* iteracijų be pagerėjimo skaičius ir vykdymo laikas neviršija limitų:
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
  + Grąžinti geriausią įvykdomą individą
  ]
) <algo_parallel>

Lygiagretinimas realizuotas naudojant "OpenMP". Kiekvienoje iteracijoje nuosekliai veikiančioje algoritmo dalyje parenkami $2N$ tėviniai individai ir iš jų sugeneruojami $N$ palikuonių, o vietinė paieška vykdoma lygiagrečiai – kiekviena gija apdoroja po vieną palikuonį.

#lt_as(<parallel_hgs_memory>) pavyzdys pavaizduoja, kaip kiekvienas algoritmo žingsnis modifikuoja bendrus duomenis.
Kiekviena gija dirba su savo palikuoniu, o įrašai į bendrą populiaciją atliekami nuosekliai veikiančioje algoritmo dalyje.
Toks lygiagretinimo būdas sumažina sinchronizacijos kaštus. Kiekviena gija įrašo pakeitimus tik į jai skirtą atmintį. Bendra populiacija atnaujinama tik nuoseklioje sekcijoje, todėl į ją patenka tik jau įvertinti individai.

Sinchronizacija vyksta pasitelkiant "OpenMP" barjerus: po lygiagrečios vietinės paieškos ir taisymo etapų visos nuoseklios algoritmo sekcijos vykdymas blokuojamas iki tol, kol visos gijos baigia mokymo etapą. Nauji individai nuosekliai įterpiami į bendrą populiaciją.

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

#pagebreak()

= Lygiagretintos ir nuoseklios programos palyginimas

== Metodika

HGS ir kiti iteratyvūs algoritmai sustoja pasiekus tam tikrą kriterijų. HGS atveju tai iteracijų skaičius be pagerėjimo arba veikimo laikas. Parinkus per aukštas ribas, algoritmo vykdymo laikas gali būti neprognozuojamas ir užsitęsti neapibrėžtam laiko tarpui.

Pasirinkta naudoti @vidal2022Hybrid aprašytus duomenų rinkinius ir metodiką:
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
Iš viso vykdomi 5 paleidimai, o rezultatų palyginimui naudojami šių 5 paleidimų vykdymo laiko ir rezultatų kainos vidurkiai.
Lygiagrečios programos versija patalpinta "Codeberg" saugykloje#footnote[https://codeberg.org/Dom/HGS-CVRP/src/commit/411e391ffefac9a308d28e280194d65004d8332c].

Naudoti algoritmo ir vykdymo parametrai pateikti #lt_ame(<priedas-params>) priede. Dauguma parametrų palikti pagal numatytas reikšmes, o eksperimente fiksuoti gijų skaičius, atsitiktinės atrankos sėkla #angl[randomization seed] ir laiko limitas.

== Eksperimentinė aplinka

Šiame darbe analizuotas Uchoa 2017 X-n uždavinių rinkinys.
Palyginimui naudoti geriausių sprendinių rinkiniai#footnote[https://galgos.inf.puc-rio.br/cvrplib/index.php/en/instances, prieigos data: 2026-01-07].

Vykdymo duomenys surinkti paleidžiant lygiagretintą ir palyginimui originalią HGS-CVRP programos versijas. Naudotos įrangos konfigūracija: "Intel® Xeon® Gold 6252" procesorius, 384GiB atmintis, "Qlustar 13" ("Ubuntu" pagrindas) operacinė sistema.

Lyginant lygiagrečią ir nuoseklią versijas naudojamas tikrasis laikas (angl. _wall-clock_), vietoje procesoriaus laiko (angl. _CPU-time_), nes daugiagijės versijos procesoriaus laiko matavimas parodytų kiekvieno procesoriaus vykdymo laikų sumą ir neatitiktų realaus vykdymo laiko.

// == Duomenų surinkimas ir apdorojimas

// Duomenys renkami fiksuojant geriausio sprendinio spragą nustatytais laiko momentais. Taip sudaromos spragos laiko eilutės, kurios vėliau naudojamos palyginti skirtingus gijų skaičius.

// Pagrindiniai duomenų apdorojimo žingsniai:
// 1. Kiekvienai instancijai atliekami keli paleidimai su skirtingomis sėklomis.
// 2. Kas 1% laiko limito užregistruojama geriausia spraga.
// 3. Rezultatai agreguojami ir skaičiuojami vidurkiai pagal gijų skaičių.
// 4. Spraga nustatoma kaip bazinės viengijos spraga pabaigoje, o kiekviena gijų konfigūracija vertinama pagal pirmą etapą, kuriame ši spraga arba geresnė pasiekiama.

== Palyginimas

#let x_gap_result = gap_data(instances: x_vrp_instances)
#let table_100ths_x = table_100_avg_from(x_gap_result)
#let gap_threads_table = table_gap_threads_from(x_gap_result)
#let gap_speedup_table = table_gap_speedup_from(x_gap_result)
#let x_speedups = calculate_all_speedups(x_vrp_instances)

// Function to plot average speedup
#grid(
  columns: 2,
  gutter: 2em,
  [#figure(
    caption: [Vidutinė sprendinių spraga pagal gijų skaičių per vykdymo laiką (Uchoa 2017 X-n rinkinys)],
    scale(60%, reflow: true)[#gap_threads_plot_from(x_gap_result)]
  ) <gap_over_time_plot>],
  [#figure(
    caption: [Vidutinis ir tikrasis pagreitėjimas, (Uchoa 2017 X-n rinkinys)],
    scale(60%, reflow: true, plot_average_speedup(x_speedups)),
  ) <x-speedup-plot>]
)

Lygiagreti algoritmo versija rodo mažesnę spragą ne tik vykdymo pabaigoje, bet ir ankstyvuosiuose vykdymo momentuose. Detalesni kiekvieno uždavinio rezultatai pateikti #lt_oje(<priedas-costs-x>) lentelėje.

// Našumas sparčiai didėja iki 8 gijų, o vėliau augimas lėtėja ir stabilizuojasi. Šis prisotinimo reiškinys, kai sinchronizacijos kaštai pradeda viršyti lygiagretinimo teikiamą naudą, yra analogiškas aptariamam @pandian2023Effect ir @stadtler2023parallel darbuose.

// Nors 16 gijų atveju pasiektas ~1.8 santykis yra artimas @jamshidi2025A_Para rezultatams, tiesioginis palyginimas yra komplikuotas dėl skirtingų maksimalaus vykdymo laiko ($T_"max"$) ir aparatinės įrangos konfigūracijų.

Lygiagretinimo teorinį pagreitinimą galima įvertinti Amdahlo dėsniu, kuris susieja nuoseklią algoritmo dalį su maksimaliu greitėjimu. Jei algoritmo nuosekli dalis užima $1 - f$ laiko dalį, o likusi $f$ dalis gali būti vykdoma lygiagrečiai, teorinis greitėjimas $S_p^A$ su $p$ gijų aprašomas:

$ S_p = 1 / ((1 - f) + f / p) $ <math_speedup>

Taip pat lygiagrečią programą galima įvertinti efektyvumu. Jis parodo, kuri dalis visų procesorių atlieka naudingą darbą, t. y. kaip efektyviai išnaudojami turimi resursai. Efektyvumas apibrėžiamas kaip pagreitėjimo ir gijų skaičiaus santykis:

$ E_p = S_p / p $

#let amdahl_parallel_fraction = 0.86
#let amdahl_from_thread_no = p => 1/((1 - amdahl_parallel_fraction) + amdahl_parallel_fraction / p)
#figure(
  caption: [Teorinis pagreitėjimas pagal Amdalo dėsnį],
  table(
    columns: (auto, auto, auto, auto, auto),
    [$p$], [2 gijos], [4 gijos], [8 gijos], [16 gijos],
    [$S_p^A$],
    [#str(amdahl_from_thread_no(2)).slice(0, 5)],
    [#str(amdahl_from_thread_no(4)).slice(0, 5)],
    [#str(amdahl_from_thread_no(8)).slice(0, 5)],
    [#str(amdahl_from_thread_no(16)).slice(0, 5)],
  )
) <amdalh_theory_table>

Pagreitėjimui nustatyti, reikia baigties kriterijaus, kurį algoritmas pasiekęs. #lt_ame(<x-speedup-plot>) pavyzdyje ir #lt_oje(<x-speedup-table>) lentelėje pasirinkta baigtinis kriterijus yra laiko momentas, kai pasiekta spraga lygi viengijos programos paskutinio laiko momento (t. y. kai nuoseklios programos veikimas baigėsi) spragai.

#let points = range(0, x_speedups.threads.len()).map(i => { (x_speedups.threads.at(i), x_speedups.average.at(i)) })

#figure(
  caption: [Tikrasis pagreitėjimas],
  table(
    columns: (auto, auto, auto, auto, auto),
    [$p$], [2 gijos], [4 gijos], [8 gijos], [16 gijos],
    [$S_p$],
    [#str(points.at(0).at(1)).slice(0, 5)],
    [#str(points.at(1).at(1)).slice(0, 5)],
    [#str(points.at(2).at(1)).slice(0, 5)],
    [#str(points.at(3).at(1)).slice(0, 5)],
  )
) <x-speedup-table>

Viso vykdymo eigoje lygiagreti programa rodo mažesnę spragą nei nuosekli programa. Tačiau, su vis didesniu gijų skaičiumi pastebimas vis proporciškai gijų skaičiui mažesnis pagreitėjimas. Naudojant 16 gijų tas pats rezultatas pasiekiamas vos 2 kartus greičiau negu su 2 gijomis. Taip pat, realus pagreitėjimas nesiekia teorinio įmanomo pagreitėjimo ir tik toliau nuo jo atitrūksta padidinus gijų skaičių. Dėl to didinant gijų skaičių krenta efektyvumas, pridedant daugiau gijų vis daugiau procesorių laiko yra praleidžiama laukiant rezultatų iš kitų gijų ir laukiant kol nuosekli programos dalis baigs savo darbą.

// #figure(
//   caption: [Vidutinis efektyvumas (Uchoa 2017 X-n rinkinys)],
//   scale(60%, reflow: true, plot_average_efficiency(x_speedups)),
// ) <x-efficiency-plot>

#figure(
  caption: [Efektyvumas],
  table(
    columns: (auto, auto, auto, auto, auto),
    [$p$], [2 gijos], [4 gijos], [8 gijos], [16 gijos],
    [$E_p$],
    [#str(points.at(0).at(1) / 2.0).slice(0, 5)],
    [#str(points.at(1).at(1) / 4.0).slice(0, 5)],
    [#str(points.at(2).at(1) / 8.0).slice(0, 5)],
    [#str(points.at(3).at(1) / 16.0).slice(0, 5)],
  )
) <x-efficiency-table>

// Tikrojo greitėjimo figūra parodo, kad 2, 4, 8 ir 16 gijų atveju vidutinės vertės yra maždaug 2.81, 3.66, 4.85 ir 5.48 (lentelė #ref(<speedup-table>)). Teorinis Amdahl greitėjimas (1.75, 2.82, 4.04, 5.16) pateiktas šalia esančioje diagramoje, tačiau skirtumas paaiškinamas tuo, kad paralelinės gijos kuria daugiau sprendinių variantų ir pirmos pasiekia tikslinį spragos slenkstį. Tokie superlinijiniai efektai taip pat pastebimi `@pandian2023Effect`, `@yelmewad2021Parall` ir `@abdelatti2020An_imp`, kai papildomi leidimai bei GPU sinchronizacijos sumažinimas leidžia greičiau pagerinti sprendinius.

#figure(
  caption: [Vidutinis efektyvumas (Uchoa 2017 X-n rinkinys)],
  scale(60%, reflow: true, plot_average_efficiency(x_speedups)),
) <x-efficiency-plot>

#pagebreak()
#set heading(numbering: none)
= Rezultatai ir išvados

== Rezultatai

1. Parinktas duomenų rinkinys, pagal kurį galima testuoti ir analizuoti sprendinius.
2. Atlikta HGS algoritmo veikimo analizė ir aprašyta HGS-CVRP specifika.
3. Įgyvendintas vietinės paieškos lygiagretinimas ir aprašyta lygiagretinimo specifika.
4. Pateiktas rezultatų palyginimas.

== Išvados

1. Lygiagreti vietinė paieška HGS-CVRP algoritme pagerina sprendinių kokybę per tą patį laiko tarpą.
2. Įmanoma lygiagretinti hibridinį genetinį paieškos algoritmą, kuris naudoja _swap\*_ kaimynystę, užtikrinant mažesnį vykdymo laiką.

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

= Priedas. Pagreitėjimo analizė

#figure(
  block(breakable: true, width: 118%)[#table_speedup_all_instances(x_speedups)],
  caption: [Pagreitėjimas kiekvienam uždaviniui.]
) <speedup-table>

#pagebreak()
#set heading(numbering: none)
#set text(size: 12pt)
#bibliography(title: [Šaltiniai], "bibliography.bib")

// = The bad list
// - A Hybrid Approach for Simultaneous Effective Automobile Navigation with DE and PSO (2024)
