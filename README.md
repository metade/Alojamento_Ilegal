# Alojamento Ilegal

Análise investigativa de snapshots de anúncios Airbnb em Lisboa comparados com o registo oficial português de alojamento local. Os resultados são indicadores para verificação oficial, não conclusões jurídicas.

## Execução

```bash
bundle install
bundle exec ruby run_me.rb
```

O script descarrega as fontes públicas em falta e cria um run imutável em:

```text
data/snapshots/<airbnb-snapshot-date>__<official-download-date>/
```

Cada run contém:

- `metadata.json` — URLs, datas, hashes SHA-256, commit Git e versões;
- `summary.json` — métricas, classificações e comparações históricas;
- `listings.csv` — contagens agregadas por freguesia e classificação;
- `licence_groups.csv` — contagens agregadas por classificação e categorias oficiais;
- `freguesias.csv` — métricas por freguesia;
- `report.html` — relatório autónomo em português.

O histórico append-only está em `data/history/summary.csv`. Runs existentes nunca são sobrescritos. Para gerar também um PDF derivado, instale `wkhtmltopdf` ou `weasyprint` e execute:

```bash
GENERATE_PDF=1 bundle exec ruby run_me.rb
```

## Testes

```bash
ruby -Itest test/al_ilegal_test.rb
ruby -Itest test/spatial_clusters_test.rb
ruby -Itest test/versioned_analysis_test.rb
```

## GitHub Actions

`.github/workflows/quarterly-analysis.yml` permite execução trimestral e manual. O workflow executa os testes, descarrega as fontes, gera os relatórios, publica os outputs versionados no repositório e guarda artefactos temporários para debugging.

Os artefactos do GitHub Actions têm retenção limitada; os snapshots commitados em `data/snapshots/` e o histórico em `data/history/` são a fonte permanente do projeto. Datasets brutos em `data_sources/`, resultados detalhados em `data/private/` e caches em `tmp/` continuam fora do Git por defeito. Os CSVs dos snapshots são agregados e não contêm identificadores de anúncios, anfitriões, nomes, endereços, coordenadas ou valores de licença individuais.

## Dados e método

As fontes são o arquivo público [Inside Airbnb](https://insideairbnb.com/get-the-data/) e o registo oficial disponibilizado pelo Turismo de Portugal. Em cada execução, o downloader descobre na página do Inside Airbnb o snapshot mais recente disponível para Lisboa; `last_scraped` é uma data ao nível do anúncio e pode abranger vários dias.

As licenças são normalizadas de forma conservadora. O analisador distingue, entre outras categorias:

- licença/listagem única;
- provável estabelecimento com múltiplos quartos ou unidades;
- licença repetida na mesma localização;
- mesma licença em várias localizações;
- licença oficial fora de Lisboa;
- ausência de licença identificável.

`host_id` pode ser usado apenas durante a análise local como metadado, nunca como critério de agrupamento; não é escrito nos outputs públicos. A estimativa de estabelecimentos colapsa apenas categorias de menor risco e mantém casos de reutilização suspeita separados.

Para instruções de manutenção e interpretação, consulte [`AGENTS.md`](AGENTS.md).
