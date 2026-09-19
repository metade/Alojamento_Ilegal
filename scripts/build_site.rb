#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"

ROOT = File.expand_path("..", __dir__)
SNAPSHOTS_DIR = File.join(ROOT, "data", "snapshots")
SITE_DIR = File.join(ROOT, "site")

PUBLIC_FILES = %w[
  metadata.json
  summary.json
  listings.csv
  licence_groups.csv
  freguesias.csv
  report.html
].freeze

def html_escape(value)
  value.to_s.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;").gsub('"', "&quot;")
end

snapshot_dirs = Dir.children(SNAPSHOTS_DIR)
  .map { |name| File.join(SNAPSHOTS_DIR, name) }
  .select { |path| File.directory?(path) }
  .sort.reverse

abort "Não existem snapshots públicos em #{SNAPSHOTS_DIR}." if snapshot_dirs.empty?

FileUtils.rm_rf(SITE_DIR)
FileUtils.mkdir_p(File.join(SITE_DIR, "runs"))

snapshot_dirs.each do |source_dir|
  run_id = File.basename(source_dir)
  destination_dir = File.join(SITE_DIR, "runs", run_id)
  FileUtils.mkdir_p(destination_dir)

  PUBLIC_FILES.each do |filename|
    source = File.join(source_dir, filename)
    abort "Ficheiro público em falta: #{source}" unless File.file?(source)

    FileUtils.cp(source, File.join(destination_dir, filename))
  end
end

latest_id = File.basename(snapshot_dirs.first)
latest_metadata = JSON.parse(File.read(File.join(SITE_DIR, "runs", latest_id, "metadata.json")))
run_links = snapshot_dirs.map do |source_dir|
  run_id = File.basename(source_dir)
  metadata = JSON.parse(File.read(File.join(SITE_DIR, "runs", run_id, "metadata.json")))
  <<~HTML
    <li><a href="runs/#{html_escape(run_id)}/report.html">#{html_escape(run_id)}</a>
      <span>(Airbnb: #{html_escape(metadata.fetch("source_dates").fetch("airbnb_snapshot_date"))}; registo descarregado em #{html_escape(metadata.fetch("source_dates").fetch("official_register_download_date"))})</span></li>
  HTML
end.join

index = <<~HTML
  <!doctype html>
  <html lang="pt">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Alojamento Local em Lisboa — indicadores para verificação</title>
    <style>
      :root { color-scheme: light; --ink: #243447; --muted: #526579; --blue: #123b5d; --pale: #edf4f8; }
      body { font: 1rem/1.6 system-ui, sans-serif; max-width: 900px; margin: auto; padding: 1rem; color: var(--ink); }
      header { background: var(--blue); color: white; padding: 2rem; border-radius: 14px; }
      h1 { margin-top: 0; line-height: 1.15; }
      section { margin: 2rem 0; }
      .notice { border-left: 5px solid #d38b22; background: #fff7e8; padding: 1rem 1.25rem; }
      .meta { color: var(--muted); }
      a { color: #075a91; }
      li { margin: .65rem 0; }
      footer { border-top: 1px solid #d9e2e8; padding-top: 1rem; color: var(--muted); font-size: .9rem; }
    </style>
  </head>
  <body>
    <header>
      <h1>Alojamento Local em Lisboa</h1>
      <p>Comparação de snapshots públicos para identificar indicadores que requerem verificação.</p>
      <p>Último run: <a href="runs/#{html_escape(latest_id)}/report.html" style="color:#fff">#{html_escape(latest_id)}</a></p>
    </header>

    <section class="notice">
      <strong>Importante:</strong> os resultados são indicadores analíticos, não conclusões de ilegalidade, culpa ou incumprimento. Qualquer divergência deve ser confirmada junto das fontes oficiais.
    </section>

    <section>
      <h2>Objetivo</h2>
      <p>O projeto compara snapshots de anúncios do Inside Airbnb em Lisboa com o registo oficial português de alojamento local. Publica contagens agregadas por freguesia e classificação, preservando a possibilidade de revisão metodológica sem divulgar anúncios individuais.</p>
    </section>

    <section>
      <h2>Fontes e atribuição</h2>
      <p>Os dados de anúncios provêm do <a href="https://insideairbnb.com/get-the-data/">Inside Airbnb</a>. O registo oficial é disponibilizado pelo <a href="https://www.turismodeportugal.pt/">Turismo de Portugal</a>. Cada run conserva URLs, datas e hashes das fontes no seu ficheiro <code>metadata.json</code>.</p>
    </section>

    <section>
      <h2>Como ler os resultados</h2>
      <p>A normalização de licenças é conservadora. As classificações distinguem, entre outros sinais, licenças únicas, possíveis anúncios múltiplos do mesmo estabelecimento, repetições na mesma localização, repetições em localizações distintas, registos oficiais fora de Lisboa e ausência de licença identificável.</p>
      <p>Os dados publicados são agregados. Não incluem IDs de anúncios ou anfitriões, URLs de anúncios, nomes, endereços, coordenadas exatas, valores de licença originais ou texto arbitrário das fontes. A metodologia e exemplos sintéticos estão no relatório de cada run.</p>
    </section>

    <section>
      <h2>Runs publicados</h2>
      <ul>#{run_links}</ul>
    </section>

    <section>
      <h2>Limitações e correções</h2>
      <p>Snapshots têm datas e coberturas diferentes; <code>last_scraped</code> é uma data ao nível do anúncio e pode abranger vários dias. Diferenças de formato, localização ou cobertura não demonstram uma infração. Para sugerir uma correção ou esclarecer um resultado, use os <a href="https://github.com/metade/Alojamento_Ilegal/issues">issues do projeto</a>.</p>
      <p>O código de análise e os dados de origem detalhados podem permanecer privados; este site contém apenas os outputs sanitizados destinados a publicação.</p>
    </section>

    <footer>
      <p>Último run publicado: #{html_escape(latest_metadata.fetch("run_id"))}. Versão da metodologia: #{html_escape(latest_metadata.fetch("methodology_version"))}.</p>
      <p><a href="LICENSE">Licença do código</a> · <a href="NOTICE">Atribuição e avisos</a></p>
    </footer>
  </body>
  </html>
HTML

File.write(File.join(SITE_DIR, "index.html"), index)
FileUtils.cp(File.join(ROOT, "LICENSE"), File.join(SITE_DIR, "LICENSE"))
FileUtils.cp(File.join(ROOT, "NOTICE"), File.join(SITE_DIR, "NOTICE"))
puts "Site público criado em #{SITE_DIR} (#{snapshot_dirs.length} run(s))."
