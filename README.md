# Alojamento Ilegal

An analysis of Lisbon Airbnb listings against Portugal’s official local-accommodation register.

The project compares listing licence values, official registration records, and approximate locations. It also distinguishes likely multi-room or multi-unit establishments from possible reuse of the same licence across distinct locations.

## Quick start

```bash
bundle install
bundle exec ruby run_me.rb
```

Cada execução cria um diretório imutável `data/snapshots/<airbnb-date>__<official-download-date>/` com `metadata.json`, `summary.json`, `listings.csv`, `licence_groups.csv`, `freguesias.csv` e `report.html`. O histórico append-only fica em `data/history/summary.csv`. O PDF é opcional: `GENERATE_PDF=1 bundle exec ruby run_me.rb` (requer `wkhtmltopdf` ou `weasyprint`).

O ID usa a data real máxima de `last_scraped` do snapshot Airbnb e a data do download do registo oficial. Runs existentes nunca são sobrescritos. `metadata.json` guarda URLs, datas, SHA-256, commit Git e versões da análise, metodologia e schema.

Run the tests with:

```bash
ruby -Itest test/al_ilegal_test.rb
ruby -Itest test/spatial_clusters_test.rb
ruby -Itest test/versioned_analysis_test.rb
```

For project-specific working instructions and interpretation notes, see [`AGENTS.md`](AGENTS.md).

## Dados

- data/listings.csv - Listagens de Airbnb a partir de https://insideairbnb.com/get-the-data/ (Lisboa - `Detailed Listings data`)
- data/Estabelecimentos_de_Alojamento_Local.csv - Download de "Estabelecimentos de Alojamento Local" a partir de https://sigtur.turismodeportugal.pt/

(Nota: dados não incuidos no repo)

## Run me

```
bundle
bundle exec ruby run_me.rb

Ultimas actualizações:
{:airbnb=>"2025-10-08", :turismo_portugal=>"2025-08-26"}


17428 listagens de AirBnb
6661 com licença AL válida
5750 com licença não reconhecida (669 sem licença, 3698 isentos(?), 1383 não reconhecidos)
4645 em que a licença AL foi reutilizada
1121 em que a licença AL é numa outra localidade


**** Ajuda
241 listagens de AirBnb
110 com licença AL válida
59 com licença não reconhecida (7 sem licença, 38 isentos(?), 14 não reconhecidos)
62 em que a licença AL foi reutilizada
16 em que a licença AL é numa outra localidade

**** Alcntara
320 listagens de AirBnb
127 com licença AL válida
107 com licença não reconhecida (12 sem licença, 83 isentos(?), 12 não reconhecidos)
76 em que a licença AL foi reutilizada
25 em que a licença AL é numa outra localidade

**** Alvalade
360 listagens de AirBnb
63 com licença AL válida
213 com licença não reconhecida (20 sem licença, 153 isentos(?), 40 não reconhecidos)
77 em que a licença AL foi reutilizada
35 em que a licença AL é numa outra localidade

**** Areeiro
447 listagens de AirBnb
58 com licença AL válida
189 com licença não reconhecida (8 sem licença, 142 isentos(?), 39 não reconhecidos)
192 em que a licença AL foi reutilizada
42 em que a licença AL é numa outra localidade

**** Arroios
2234 listagens de AirBnb
616 com licença AL válida
734 com licença não reconhecida (107 sem licença, 430 isentos(?), 197 não reconhecidos)
831 em que a licença AL foi reutilizada
172 em que a licença AL é numa outra localidade

**** Avenidas Novas
884 listagens de AirBnb
145 com licença AL válida
416 com licença não reconhecida (24 sem licença, 329 isentos(?), 63 não reconhecidos)
306 em que a licença AL foi reutilizada
50 em que a licença AL é numa outra localidade

**** Beato
134 listagens de AirBnb
48 com licença AL válida
41 com licença não reconhecida (4 sem licença, 33 isentos(?), 4 não reconhecidos)
38 em que a licença AL foi reutilizada
10 em que a licença AL é numa outra localidade

**** Belm
293 listagens de AirBnb
118 com licença AL válida
99 com licença não reconhecida (18 sem licença, 63 isentos(?), 18 não reconhecidos)
70 em que a licença AL foi reutilizada
11 em que a licença AL é numa outra localidade

**** Benfica
101 listagens de AirBnb
23 com licença AL válida
60 com licença não reconhecida (2 sem licença, 49 isentos(?), 9 não reconhecidos)
13 em que a licença AL foi reutilizada
10 em que a licença AL é numa outra localidade

**** Campo de Ourique
467 listagens de AirBnb
160 com licença AL válida
203 com licença não reconhecida (26 sem licença, 152 isentos(?), 25 não reconhecidos)
98 em que a licença AL foi reutilizada
31 em que a licença AL é numa outra localidade

**** Campolide
299 listagens de AirBnb
61 com licença AL válida
116 com licença não reconhecida (6 sem licença, 68 isentos(?), 42 não reconhecidos)
112 em que a licença AL foi reutilizada
18 em que a licença AL é numa outra localidade

**** Carnide
35 listagens de AirBnb
20 com licença AL válida
11 com licença não reconhecida (0 sem licença, 6 isentos(?), 5 não reconhecidos)
4 em que a licença AL foi reutilizada
0 em que a licença AL é numa outra localidade

**** Estrela
1027 listagens de AirBnb
437 com licença AL válida
337 com licença não reconhecida (29 sem licença, 192 isentos(?), 116 não reconhecidos)
228 em que a licença AL foi reutilizada
53 em que a licença AL é numa outra localidade

**** Lumiar
140 listagens de AirBnb
43 com licença AL válida
77 com licença não reconhecida (8 sem licença, 57 isentos(?), 12 não reconhecidos)
18 em que a licença AL foi reutilizada
9 em que a licença AL é numa outra localidade

**** Marvila
140 listagens de AirBnb
40 com licença AL válida
66 com licença não reconhecida (5 sem licença, 50 isentos(?), 11 não reconhecidos)
24 em que a licença AL foi reutilizada
14 em que a licença AL é numa outra localidade

**** Misericrdia
2630 listagens de AirBnb
1247 com licença AL válida
690 com licença não reconhecida (125 sem licença, 357 isentos(?), 208 não reconhecidos)
654 em que a licença AL foi reutilizada
144 em que a licença AL é numa outra localidade

**** Olivais
221 listagens de AirBnb
56 com licença AL válida
113 com licença não reconhecida (10 sem licença, 85 isentos(?), 18 não reconhecidos)
49 em que a licença AL foi reutilizada
9 em que a licença AL é numa outra localidade

**** Parque das Naes
338 listagens de AirBnb
109 com licença AL válida
176 com licença não reconhecida (20 sem licença, 123 isentos(?), 33 não reconhecidos)
40 em que a licença AL foi reutilizada
30 em que a licença AL é numa outra localidade

**** Penha de Frana
618 listagens de AirBnb
173 com licença AL válida
240 com licença não reconhecida (20 sem licença, 160 isentos(?), 60 não reconhecidos)
186 em que a licença AL foi reutilizada
60 em que a licença AL é numa outra localidade

**** Santa Clara
37 listagens de AirBnb
3 com licença AL válida
30 com licença não reconhecida (2 sem licença, 26 isentos(?), 2 não reconhecidos)
3 em que a licença AL foi reutilizada
4 em que a licença AL é numa outra localidade

**** Santa Maria Maior
3482 listagens de AirBnb
1835 com licença AL válida
708 com licença não reconhecida (118 sem licença, 401 isentos(?), 189 não reconhecidos)
876 em que a licença AL foi reutilizada
180 em que a licença AL é numa outra localidade

**** Santo Antnio
1545 listagens de AirBnb
505 com licença AL válida
608 com licença não reconhecida (47 sem licença, 424 isentos(?), 137 não reconhecidos)
409 em que a licença AL foi reutilizada
122 em que a licença AL é numa outra localidade

**** So Domingos de Benfica
172 listagens de AirBnb
52 com licença AL válida
93 com licença não reconhecida (9 sem licença, 61 isentos(?), 23 não reconhecidos)
24 em que a licença AL foi reutilizada
10 em que a licença AL é numa outra localidade

**** So Vicente
1263 listagens de AirBnb
612 com licença AL válida
364 com licença não reconhecida (42 sem licença, 216 isentos(?), 106 não reconhecidos)
255 em que a licença AL foi reutilizada
66 em que a licença AL é numa outra localidade
```

Dados postos em:
```
=> data_sources/data_transformed/result.csv
```
