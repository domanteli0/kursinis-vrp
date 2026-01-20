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

- HGS – hibridinis genetinis paieškos algoritmas #angl[hybrid genetic search].
- vrp – transporto maršrutų optimizavimo uždavinys #angl[vehicle routing problem].
- cvrp – #angl_[capacitated vehicle routing problem]. kiekviena transporto priemonė turi maksimalią siuntų talpą.
- vrptw – #angl_[vrp with time windows].
- gvrp – #angl_[generalized vrp]. klientai grupuojami į klasterius. tik vienas klientas iš viso klasterio turi būti aplankytas.
- cluvrp – #angl_[clustered vrp]. klientai grupuojami į klasterius. visi klientai klasteryje turi būti aplankyti prieš vykstant į kitą klasterį.
- softcluvrp – #angl_[soft clustered vrp]. cluvrp variantas, kuriame į klasterį leidžiama aplankyti kelis kartus.
- mdvrp – #angl_[multidepot vrp].
- pvrp – #angl_[periodic vrp]. pridedama laiko dimensija, sprendinys sudaromas iš kelių maršrutų rinkinių, atitinkančių dienas, kuriomis bus aplankomi klientai.
- mdpvrp – #angl_[multidepot periodic vrp]. mdvrp ir pvrp kombinacija.
- cvrppd – #angl_[cvrp pickup and delivery]. cvrp ir vrppd kombinacija.
- bks – geriausias žinomas sprendinys #angl[best known solution].
- gpu – grafikos procesorius #angl[graphics processing unit].
- populiacija – individų rinkinys.
- individas – uždavinio sprendinys, t. y. maršrutų rinkinys.
- įvykdomas sprendinys – sprendinys, tenkinantis visus uždavinio apribojimus.

= Sąvokų apibrėžimai

- vietinė paieška – iteratyvus sprendinio gerinimas lokaliais judesiais (kaimynystėse), kol nebelieka gerinančių judesių.
- kaimynystė – sprendinių rinkinys, gaunamas iš esamo sprendinio atlikus vieną konkretų pokytį (pvz., perkelti klientą, sukeisti klientus, apversti maršruto atkarpą).
- kandidatinis sąrašas – iš anksto parinktas „perspektyvių“ kaimynų (pvz., artimiausių klientų) sąrašas, ribojantis tikrinamų judesių skaičių ir mažinantis vietinės paieškos sudėtingumą.
- baudos parametrai – koeficientai, kuriais į sprendinio kainą įtraukiamas apribojimų pažeidimas (pvz., talpos viršijimas), kad algoritmas galėtų laikinai tyrinėti neįvykdomus sprendinius.
- spraga (gap) – sprendinio nuokrypis nuo bks, išreikštas procentais (žr. #lt_a(<math_gap>)).

#pagebreak()

= įvadas

vrp -- transporto maršrutų optimizavimo uždavinys #angl[vehicle routing problem] -- yra uždavinys,
kurio tikslas yra surasti kuo optimaliausią maršrutų rinkinį @math_cost.
optimaliai parinkti maršrutai gali lemti kiek klientų įmanoma aplankyti per nustatytą laiką, sumažinti transporto kaštus ir pagerinti paslaugos patikimumą.
pirmą kartą ši problema aprašyta @dantzig1959The_Tr, kur autoriai nagrinėjo maršrutų parinkimą tarp depo ir aptarnavimo taškų (degalinių), taip suformuodami klasikinę maršrutavimo problemų tyrimų kryptį.

kur keliaujančio pardavėjo uždavinyje pagrindinė užduotis yra surasti optimaliausią kelią vienam keliautojui -- pardavėjui,
vrp sprendiniai susidaro iš kelių keliautojų -- literatūroje dažnai tiesiogiai vadinama transporto priemonėmis.

nors egzistuoja įrankiai, kurie pasitelkia tikslius metodus (pavyzdžiui "google or-tools" @ortools), didelio masto vrp variantai priklauso _np-hard_ klasei, todėl praktikoje dominuoja heuristikomis ir metaheuristikomis grįsti algoritmai, kurie pateikia labai gerus sprendinius per ribotą laiką.
metaheuristikos leidžia suderinti sprendinių kokybę ir skaičiavimo laiką, o realiose logistikos sistemose tai dažnai svarbiau už optimalumo garantiją.

hibridinis genetinės paieškos algoritmas #angl[hybrid genetic search -- hgs] -- yra vienas iš efektyviausių genetinių metaheuristinių algoritmų @petropoulos2023Operat.
šis algoritmas ir vėlesnės pagerintos versijos išlieka etalonas daugeliui vrp variantų, "dimacs" konkurse @dimacs2022vrp parodęs geriausius rezultatus vrptw uždavinyje @kool2022hybrid, ir kurio modifikuotas variantas @jiang2022fhcsolver pasirodė geriausiai cvrp uždavinyje.
šis algoritmas taip pat pritaikytas gvrp @latorre2025A_hybr, cluvrp ir softcluvrp @latorre2025An_appHybr.

praktiniame kontekste hgs sprendinių kokybė yra aukšta, tačiau vykdymo laikas didelėms instancijoms gali būti ribojantis veiksnys, ypač kai sprendiniai turi būti perskaičiuojami dažnai (pavyzdžiui, dinamiškoje logistikoje, kai keičiasi užsakymai ar eismo sąlygos). todėl aktualu mažinti algoritmo vykdymo laiką išlaikant sprendinių kokybę.

šio *darbo tikslas* -- išlygiagretinti hibridinio genetinio paieškos algoritmą, skirtą transporto maršrutų optimizavimo uždaviniams spręsti,
siekiant sumažinti vykdymo laiką neprarandant ar net pagerinant sprendinių kokybę.

*uždaviniai:*

1. išsirinkti duomenų rinkinį, pagal kurį galima būtų testuoti ir analizuoti sprendinius.
2. išanalizuoti, kaip veikia hgs algoritmas ir kurie žingsniai dominuoja vykdymo laike.
3. atrinkti paralelizuojamas dalis, kurias galima pakeisti lygiagrečiomis.
4. palyginti rezultatus su literatūroje aprašytais pažangiausiais algoritmais ir įvertinti greitėjimo ribas.

#pagebreak()

#set heading(numbering: "1.")
= transporto maršrutų optimizavimo uždaviniai

== tikslūs ir apytiksliai metodai

nors egzistuoja įrankiai, kurie pasitelkia tikslius metodus (pavyzdžiui "google or-tools" @ortools), šis uždavinys priklauso _np-hard_ sudėtingumo klasei, todėl praktikoje dominuoja heuristikomis ir metaheuristikomis grįsti algoritmai: jie beveik optimalius sprendinius randa per trumpesnį laiką, sunaudodami mažiau išteklių.
tikslūs metodai su ypač dideliais duomenų kiekiais tampa nepraktiški: didėjant klientų skaičiui, optimalaus sprendinio paieška reikalauja eksponentiškai augančių skaičiavimų, todėl dažniausiai taikoma tik mažesnėms instancijoms ar kaip kokybės etalonas.
metaheuristiniai algoritmai išsiskiria šioje uždavinių klasėje kaip efektyviausi, pasižymintys lygintinai mažu algoritmo vykdymo laiku ir aukšta uždavinių rezultatų kokybe.

tikslūs metodai dažniausiai remiasi mišriu sveikųjų skaičių #angl[mixed integer programming] programavimu, šakojimosi ir ribų #angl[branch & bound] metodais. jie suteikia optimalumo garantijas, tačiau jų skaičiavimo laikas sparčiai auga didėjant instancijos dydžiui, todėl praktikoje dažniau taikomi mažesnėms problemoms ar kaip etalonai @petropoulos2023Operat.

šiam uždaviniui dažniau naudojami heuristiniai ir metaheuristiniai algoritmai, jos išlieka patrauklios realiems logistikos uždaviniams.
metaheuristika -- aukštesnio lygio strategija, kuri parenka, kurias heuristikas taikyti, kad sprendiniai būtų randami efektyviau.
vrp literatūroje dažnai minimi keli dominuojantys pavyzdžiai (priklausomai nuo varianto): adaptuojamos didelės kaimynystės paieškos (alns / halns), hgs, imitacinis grūdinimas ir skruzdėlių kolonijos optimizavimas @adamo2024A_revi.
tokie metodai yra stochastiniai, todėl vertinant rezultatus svarbu taikyti kelis paleidimus ir pateikti vidurkius.

== vrp variacijos

praktikoje taikomos kelios vrp variacijos (cvrp, vrptw, mdpvrp, pvrp ir kt.).
jos įveda papildomus apribojimus maršrutų ilgiui, transporto priemonių panaudojimo laikui ir talpai arba prideda papildomas sąlygas:
- naudojamos transporto priemonės turi limituotą talpą (cvrp);
- visi klientai gali būti aplankyti tik specifinėmis darbo valandomis (vrptw);
- keli depai, iš kurių galima pradėti maršrutą (mdvrp);
- maršrutai planuojami per kelias dienas (periodic vrp);
- papildomi realistiškesni modeliai (heterogeniškos transporto priemonės, keli reisai, kelių tipų aptarnavimas) aptariami vrp variantų apžvalgose @vidal2020A_conc.
šis darbas atsižvelgia tik į cvrp uždavinį.

== cvrp

cvrp nagrinėjamas grafas $𝐺 = (𝑉, 𝐸)$, kuriame $v_0 in v$ žymi depą, kuris turi $m$ transporto priemonių, o likusios viršūnės ${v_1, ..., v_(|v|)}$ atitinka klientus, kuriuos reikia aplankyti.
kiekviena briauna $(i, j) in e$ reiškia galimybę keliauti tarp vietų $i$ ir $j$ su kaina $c_(i,j)$ -- euklidinis atstumas tarp vietų $i$ ir $j$.
cvrp reikia surasti sprendinį, kuriame panaudotos ne daugiau kaip $k$ transporto priemonių, prasidedančių ir pasibaigiančių depe, taip, kad kiekvienas klientas būtų aplankytas vieną kartą ir bendras klientų paklausos dydis bet kuriame maršrute neviršytų transporto priemonės talpos $q$, o bendras transporto priemonių nuvažiuotas atstumas -- kaina (žr. #lt_a(<math_cost>) lygtį) kiek įmanoma mažesnis.

$
  c_(i, j) = sqrt((x_i - x_j)^2 + (y_i - y_j)^2) \
$ <math_dist>

$
  "sprendinio kaina" &= &&sum_(k=1)^(k) sum_(i=0)^(|v|) sum_(j=0)^(|v|) c_(i,j) x_(i,j,k) \
  x_(i,j,k) &= &&1 "indikatorinė" "funkcija", "kuri" \
  & &&"lygi" 1, "jei" "transporto" "priemonė" k " " (1 <= k <= k)\
  & &&"keliauja" "nuo" "kliento" i "iki" "kliento" j, \
  & &&"lygi" 0 "priešingu" "atveju"
$ <math_cost>

lyginant transporto maršrutų optimizavimo uždavinio sprendinius taip pat naudojama spraga #angl[gap], kuri nusako atstumą nuo geriausio sprendinio, išreikštą procentais @math_gap.

$
  "spraga" &= ((z_s - z_"bks") / z_"bks") dot 100% \
  z_s &= #[pasirinkto algoritmo sprendinio kaina] \
  z_"bks" &= #[geriausio sprendinio kaina]
$ <math_gap>

#pagebreak()
= hgs algoritmo veikimas

pirmą kartą aprašytas @vidal2012A_Hybr skirtas spręsti mdpvrp. patobulintas per daugelį iteracijų: @vidal2014A_unif, @vidal2016Large_, @vidal2017Node__, @vidal2021Arc_Ro, @vidal2022Hybrid ir pritaikytas cvrp. pastarasis variantas vadinamas hgs-cvrp.

genetiniai algoritmai imituoja evoliucijos procesą. populiacija yra aibė, kurią sudaro individai (t. y. užduoties sprendiniai).
šie algoritmai naudoja įvairius kryžminimo operatorius, kurie iš kelių individų populiacijoje sukuria naują, mutuotą individą ir prideda prie populiacijos (žr. #lt_ame(<hgs_flowchart>) 1, 2 ir 4 žingsnius).
prastos kokybės ir panašūs individai (sprendiniai) vykdymo eigoje yra pašalinami iš populiacijos.

hibridinis genetinės paieškos algoritmas prie genetinio komponento prideda pagerinimo žingsnį -- vietinę paiešką #angl[local search], kuri po kryžminimo žingsnio yra pritaikoma naujam individui, siekiant pagerinti gauto individo kokybę (žr. #lt_ame(<hgs_flowchart>) 3 žingsnį).

kryžminimo operacija iš esmės sukuria vieną maršrutą, kuris vėliau yra efektyviai sukarpomas į kelis maršrutus pasitelkiant #angl[split] algoritmą.
split žingsnis svarbus dėl to, kad leidžia naudoti kryžminimo operatorius, veikiančius sekų (permutacijų) lygmeniu, o maršrutų ribos parenkamos optimizuojant papildomą dinaminio programavimo uždavinį.

vietinei paieškai pasitelkiami _relocate_, _swap_, _2-opt_, _2-opt\*_ ir _swap\*_ kaimynystės.
kaimynystė #angl[neighborhood] -- tai sprendinių rinkinys, kurį galima gauti iš dabartinio sprendinio atlikus vieną lokalų pakeitimą.
vietinė paieška iteratyviai tikrina kaimyninius sprendinius ir pereina į geresnį, kol nebelieka gerinančių judesių.
praktikoje, kad paieška būtų greita, naudojami kandidatiniai sąrašai (pavyzdžiui, tikrinami tik keli artimiausi klientai), taip sumažinant judesių skaičių ir gerinant vykdymo laiką.

_swap\*_ kaimynystėje du klientai iš skirtingų maršrutų išimami ir kiekvienas įterpiamas į bet kurią kito maršruto poziciją.
nors galimų judesių labai daug, geriausiam judesiui pakanka tikrinti įterpimą į vietą arba vieną iš trijų geriausių iš anksto įvertintų pozicijų, todėl kaimynystė tiriama efektyviai.
toks apribojimas sumažina vietinės paieškos sudėtingumą nuo kvadratinio iki maždaug linijinio pagal klientų skaičių, kartu išlaikant pakankamai gerą sprendinių kokybę @vidal2022Hybrid.
jeigu po vietinės paieškos individas yra neįvykdomas, su 50% tikimybe taikoma taisymo procedūra, t. y. pakartotinė vietinė paieška su adaptuotais baudos parametrais.

#figure(
  caption: [hgs veikimas @vidal2022Hybrid],
  scale(65%, reflow: true, hgs_flowchart)
) <hgs_flowchart>

pradinė populiacija hgs algoritme sukuriama taikant greitas konstravimo heuristikas.
praktikoje tai leidžia greitai gauti pradinį sprendinių rinkinį, kurį vėliau metaheuristika intensyviai gerina.

tėvų atranka vykdoma dvejetainiu turnyru #angl[binary tournament], kur paskaičiuojamas tinkamumas #angl[fitness], t. y. sprendinio kainos ir įvairovės suma.
įvairovė dažniausiai vertinama maršrutų briaunų panašumu, pavyzdžiui, per _broken-pairs_ atstumą.
populiacija palaikoma kaip įvykdomų ir neįvykdomų subpopuliacijų rinkinys, o baudos parametrai tikslinami, kad būtų išlaikytas įvykdomų ir neįvykdomų sprendinių santykis @vidal2022Hybrid, @vidal2012A_Hybr.
palaikant neįvykdomus ir įvykdomus sprendinius, išlaikoma populiacijos įvairovė, kuri leidžia išvengti lokalaus minimo iteruojant per sprendinius.

jeigu sugeneruojamas neįvykdomas sprendinys, algoritmas gali pabandyti jį sutaisyti ir, priklausomai nuo rezultatų, įtraukti į atitinkamą subpopuliaciją.
šis mechanizmas leidžia balansuoti tarp paieškos intensyvinimo (gerinti gerus sprendinius) ir diversifikacijos (neužstrigti lokaliuose minimumuose).

dar vienas svarbus elementas yra populiacijos valdymas.
tai individų iš įvykdomų ir neįvykdomų sprendinių subpopuliacijų mažiausią tinkamumą turintys individai (t. y. didžiausios kainos ir panašūs individai) pašalinami kas numatytą iteracijų skaičių pagal baudos parametrus, kurie patys yra tikslinami genetinio algoritmo eigos metu; tai palaiko įvairovę ir mažina sprendinių kainą @vidal2012A_Hybr, @vidal2022Hybrid.

#figure(
  caption: [hgs algoritmo pseudokodas @vidal2012A_Hybr]
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
        alg-line("1", [sugeneruoti pradinę populiaciją ir pagerinti ją vietine paieška]),
        alg-line("2", [*kol* iteracijų be pagerėjimo skaičius ir vykdymo laikas neviršija limitų:], bar: true),
        alg-line("3", [pasirinkti tėvinius individus (dvejetainis turnyras #angl[binary tournament])], indent: 1, bar: true),
        alg-line("4", [atlikti kryžminimą #angl[crossover]], indent: 1, bar: true),
        alg-line("5", [išmokyti naują individą (vietinė paieška)], indent: 1, bar: true),
        alg-line("6", [įterpti išmokytą individą į atitinkamą subpopuliaciją], indent: 1, bar: true),
        alg-line("7", [*jeigu* individas neįvykdomas:], indent: 1, bar: true),
        alg-line("8", [su 50% tikimybe bandyti sutaisyti individą ir įtraukti į atitinkamą subpopuliaciją], indent: 2, bar: true),
        alg-line("9", [*jeigu* pasiektas maksimalus aibės dydis:], indent: 1, bar: true),
        alg-line("10", [pašalinti blogiausius ir neįvairius individus iš populiacijos], indent: 2, bar: true),
        alg-line("11", [patikslinti baudos parametrus #angl[penalty parameters]], indent: 1, bar: true),
        alg-line("12", [grąžinti geriausią įvykdomą individą]),
      )
    ]
  ]
] <algo>

#pagebreak()
= literatūros analizė

== testų rinkiniai ir vertinimo metrikos

vertinimo praktikoje akcentuojama palyginamumo problema.
@uchoa2017 pasiūlė naują cvrp testų rinkinį su bks, o @jastrzab2024Standa rekomenduoja aiškiai apibrėžti laiko matavimą, paleidimų skaičių ir pateikti vidurkius kartu su geriausiais rezultatais.
tokia standartizacija leidžia prasmingai lyginti lygiagretintų ir nuoseklių algoritmų efektyvumą.

algoritmų lyginimui vrp literatūroje plačiai naudojami standartizuoti testų rinkiniai su geriausiais žinomais sprendiniais (bks).
vienas iš plačiausiai taikomų yra uchoa 2017 cvrp rinkinys @uchoa2017, kuriame pateiktos klientų koordinatės, paklausos ir talpos apribojimai, todėl galima lyginti sprendinių kokybę tarp skirtingų algoritmų ir platformų.
šiame rinkinyje instancijos apima platų klientų skaičiaus intervalą, todėl leidžia įvertinti algoritmo elgesį didėjant problemos dydžiui ir skirtingoms geografinėms struktūroms.

kadangi metaheuristikos yra stochastinės, rezultatų vertinimui paprastai naudojami vidurkiai ir geriausi pasiekti sprendiniai iš kelių paleidimų.
spraga nuo bks išlieka svarbiausia kokybės metrika, tačiau lyginant lygiagretintas ir nuoseklias versijas svarbu vertinti ne tik galutinę spragą, bet ir spragos kitimą per laiką: ankstyvuose etapuose algoritmai gali stipriai skirtis pagal tai, kaip greitai pasiekia „pakankamai gerą“ sprendinį.

rekomenduojama aiškiai apibrėžti laiko limitus, paleidimų skaičių ir aparatinę įrangą, nes šie veiksniai daro didelę įtaką rezultatų interpretacijai.
taip pat svarbu nurodyti, ar matuojamas realus (wall-clock) laikas, ar cpu laiko suma, nes lygiagretinime šios metrikos gali reikšmingai skirtis.

== lygiagretinimo kryptys

lygiagretinimo darbai vrp srityje dažniausiai skirstomi į dvi kryptis: gpu pagrįstą skaičiavimą ir daugiagijes cpu implementacijas.
gpu sprendimai leidžia masiškai lygiagretinti kaimynystes, tačiau dažnai reikalauja supaprastinti sprendinio reprezentaciją ir mažina operatorių įvairovę.
cpu daugiagijės schemos paprastai išlaiko originalų algoritmo rinkinį, bet jų greitėjimą riboja sinchronizacija ir nuoseklūs populiacijos valdymo etapai.

@abdelatti2020An_imp siūlo genetinį algoritmą, kuris pilnai vykdomas gpu (cuda): gpu branduoliai atlieka pradinę populiacijos generaciją, kaštų skaičiavimą, kryžminimą, mutaciją ir _2-opt_ vietinę paiešką.
sprendinių kokybei gerinti taikomos _2-opt_ ir artimiausio kaimyno heuristikos, o autoriai pateikia cpu ir gpu versijų palyginimą.

@yelmewad2021Parall pasitelkia gpu lygiagretinimui.
kiekvienam maršrutui skiriama atskira gpu gija, kuri vykdo vietinės paieškos žingsnį.
vietinė paieška apima _swap_ ir _relocate_ (tarp maršrutų) bei _2-opt_, _or-opt_, _3-opt_ (maršruto viduje) heuristikas, o pradinis sprendinys konstruojamas artimiausio kaimyno metodu.
tokie metodai ypač efektyvūs didelio masto instancijose, tačiau ne visada pasiekia tokį pat kokybės lygį kaip hgs.

@lei2025Speedi lygiagretinimui vietinės paieškos algoritmą išreiškia tenzorių operatoriais, tai leidžia hgs vykdymą perkelti ant gpu.
tačiau tokia sprendinių reprezentacija apsunkina pjovimo strategijų ir kaimynysčių redukcijos technikų įgyvendinimą, todėl sudėtingesni operatoriai, kaip _swap\*_, nėra trivialiai perkeliami.

@pandian2023Effect siūlo cpu lygiagretinimą, naudojant "openmp", ir rodo didelius greitėjimus, tačiau jų darbo tikslas -- greitai gauti priimtiną sprendinį, o ne maksimalios kokybės sprendinį.
tai parodo kompromisą tarp greičio ir sprendinių kokybės.

cpu pagrįsti lygiagretinimai dažniausiai remiasi užduočių lygmens paralelizavimu, kai vienu metu apdorojami keli palikuonys arba keli nepriklausomi hgs paleidimai.
tokie sprendimai riboti, nes populiacijos valdymas ir baudos parametrų reguliavimas išlieka nuoseklūs.

#figure(
  caption: [lygiagretintas hgs pagal @stadtler2023parallel],
  scale(50%, reflow: true, parallel_hgs)
)

@stadtler2023parallel hgs pritaiko cvrppd, perkelia tėvų pasirinkimo, kryžminimo ir taisymo žingsnius į atskiras gijas.
kiekviena gija papildomai atlieka vietinę paiešką (_2-opt_, _relocate_, _swap_) pasitelkiant gpu, tačiau nepasitelkia _swap\*_ heuristikos, kuri pagal @vidal2022Hybrid padeda surasti aukštesnės kokybės sprendinius.

#figure(
  caption: [hgs su salų modeliu @jamshidi2025A_Para],
  scale(50%, reflow: true, island_model)
) <hgs_island_model>

@jamshidi2025A_Para aprašo _phgs_ #angl[parallel hybrid genetic search], kur kombinuoja hgs su salų modeliu, aprašytu @rezaei2024Explor.
kiekviena gija vykdo tą patį hgs algoritmą, pridedamas individų migracijos žingsnis, kuris leidžia keistis sprendiniais tarp gijų.
tokia schema didina diversifikaciją ir gali pagerinti sprendinių kokybę per tą patį laiko limitą, tačiau reikalauja papildomų sprendinių apsikeitimo ir sinchronizacijos sprendimų.

@PyVRPwouda2024 pristato "pyvrp" paketą, kuris įgyvendina hgs algoritmą, o našumo kritines dalis realizuoja c++ kalba.
tai pabrėžia, kad našumą galima gerinti ir per efektyvią realizaciją bei duomenų struktūrų optimizavimą, net jei lygiagretinimas nėra pagrindinis tikslas.

nemaža dalis literatūros yra aprašiusi tik greitinimą ant gpu.
vis dėlto nemažos dalies pagreitinimų pritaikomumas hgs-cvrp (su _swap\*_ operatoriumi) išlieka atvira problema, todėl cpu lygiagretinimas, išlaikantis pilną operatorių rinkinį, yra patraukli alternatyva.

#pagebreak()
= HGS-CVRP lygiagretinimas

paimta @vidal2022Hybrid hgs-cvrp algoritmo implementacija #footnote[nuolatinė repozitorijos nuoroda https://github.com/vidalt/hgs-cvrp/tree/1a927955cd2861a29d978f0d359d6e647db9319c], kuri naudojama kaip pagrindas lygiagretinimui.

daugiausiai laiko užima vietinės paieškos žingsnis @jamshidi2025A_Para; autoriai parodo, kad vietinė paieška dažnai sudaro didžiausią vykdymo laiko dalį, todėl šį žingsnį labiausiai verta lygiagretinti.

hgs-cvrp (su _swap\*_ kaimynystę) pasiekia tą pačią sprendinių kokybę kaip hgs-2012 per dalį skaičiavimo laiko ir jį lenkia bet kuriame laiko taške.
_swap\*_ paieška sudaro iki 32% vietinės paieškos cpu laiko, bet duoda apie 15% visų patobulinimų, todėl lygiagretinant svarbu šią kaimynystę išlaikyti @vidal2022Hybrid.
dėl įgyvendinimo sudėtingumo ši kaimynystė dažnai praleidžiama @stadtler2023parallel @jamshidi2025A_Para, todėl šiame darbe pasirinkta ją išsaugoti.

lygiagretinimas realizuotas naudojant "openmp".
kiekvienoje iteracijoje nuosekliai veikiančioje algoritmo dalyje parenkami $2n$ tėviniai individai ir iš jų sugeneruojami $n$ palikuonių, o vietinė paieška vykdoma lygiagrečiai -- kiekviena gija apdoroja po vieną palikuonį.

kiekviena gija dirba su savo palikuoniu, o įrašai į bendrą populiaciją atliekami nuosekliai veikiančioje algoritmo dalyje.
toks lygiagretinimo būdas sumažina sinchronizacijos kaštus: kiekviena gija įrašo pakeitimus tik į savo individo kopiją.
bendra populiacija atnaujinama tik nuoseklioje sekcijoje, todėl į ją patenka tik jau įvertinti individai.

sinchronizacija vyksta pasitelkaint "openmp" barjerus: po lygiagrečios vietinės paieškos ir taisymo etapų visos nuoseklios algoritmo sekcijos vykdymas blokuojamas iki tol, kol visos gijos baigia mokymo etapą.
nauji individai nuosekliai įterpiami į bendrą populiaciją, tuomet vykdomas populiacijos valymas ir baudos parametrų tikslinimas.

#figure(
  caption: "bendros atminties rašymo etapai",
  scale(20%, reflow: true, image("img/parallel_memory.png"))
) <parallel_hgs_memory>

Greitaveiką riboja nuoseklūs žingsniai.
Kryžminimo, baudų parametrų tikslinimo bei populiacijos valdymo žingsniai atliekami nuosekliai, todėl dalį laiko visos gijos, išskyrus vieną, neatlieka jokių veiksmų.
Be to, prieš populiacijos valdymo žingsnį visos gijos privalo baigti vietinę paiešką, todėl lėtai veikianti gija gali užtęsti visos iteracijos vykdymo laiką.
Dėl šių priežasčių didėjant gijų skaičiui tikėtinas prisotinimas, kurį galima interpretuoti ir per amdahl dėsnį.

#figure(
  caption: [lygiagretinto hgs-cvrp pseudokodas (grįstas pagal @vidal2012A_Hybr)]
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
        alg-line("1", [sugeneruoti pradinę populiaciją ir pagerinti ją vietine paieška]),
        alg-line("2", [*kol* iteracijų be pagerėjimo skaičius ir vykdymo laikas neviršija limitų:], bar: true),
        alg-line("3", [pasirinkti $2n$#footnote[n -- gijų skaičius] tėvinius individus (dvejetainis turnyras #angl[binary tournament])], indent: 1, bar: true),
        alg-line("4", [atlikti kryžminimą #angl[crossover] n kartų], indent: 1, bar: true),
        alg-line("5", [(kiekvienoje gijoje) išmokyti naują individą (vietinė paieška)], indent: 1, bar: true),
        alg-line("6", [įterpti išmokytus individus į atitinkamas subpopuliacijas], indent: 1, bar: true),
        alg-line("7", [*jeigu* individas neįvykdomas:], indent: 1, bar: true),
        alg-line("8", [(kiekvienoje gijoje) su 50% tikimybe bandyti sutaisyti individą], indent: 2, bar: true),
        alg-line("9", [*jeigu* pasiektas maksimalus aibės dydis:], indent: 1, bar: true),
        alg-line("10", [pašalinti blogiausius ir neįvairius individus iš populiacijos], indent: 2, bar: true),
        alg-line("11", [patikslinti baudos parametrus #angl[penalty parameters]], indent: 1, bar: true),
        alg-line("12", [grąžinti geriausią įvykdomą individą]),
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

_hgs_ ir kiti iteratyvūs algoritmai sustoja pasiekus tam tikrą kriterijų.
hgs atveju tai iteracijų skaičius be pagerėjimo arba veikimo laikas.
parinkus per aukštas ribas, algoritmo vykdymo laikas gali būti neprograzuojamas ir užsitęsti ilgiau negu praktiška praktikoje.

dėl rezultatų palyginamumo pasirinkta naudoti @vidal2022Hybrid aprašytus duomenų rinkinius (@uchoa2017) ir metodiką:
#qi()[mes stebime kiekvieno algoritmo pažangą iki laiko ribos $𝑇_"max" = 𝑛 dot 240∕100$ sekundžių, kur $n$ reiškia klientų skaičių.
todėl mažiausias atvejis su 100 klientais vykdomas 4 minutes,
o didžiausias atvejis su 1000 klientų vykdomas 40
minučių. kiekvieno veikimo metu mes užregistruojame geriausią sprendimo vertę po
1%, 2%, 5%, 10%, 15%, 20%, 30%, 50%, 75% ir 100%
laiko ribos, kad galėtume įvertinti algoritmų našumą skirtinguose
paieškos etapuose @vidal2022Hybrid.][we monitor each algorithm’s progress up to a time limit of $𝑇_"max" = 𝑛 dot 240∕100$ seconds, where 𝑛 represents the number of customers.
therefore, the smallest instance with 100 clients is run for 4 minutes,
whereas the largest instance containing 1000 clients is run for 40
minutes. during each run, we record the best solution value after
1%, 2%, 5%, 10%, 15%, 20%, 30].

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
