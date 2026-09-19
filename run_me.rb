#!/usr/bin/env ruby
require_relative "lib/al_ilegal"

mode = AlIlegal::CLI.mode!(ARGV)
force = AlIlegal::CLI.force?(ARGV)
reuse_existing = AlIlegal::CLI.reuse_existing?(ARGV)
abort "--reuse-existing is only supported in public mode" if reuse_existing && mode != "public"
airbnb_path, official_path = AlIlegal::Data.prepare!
if reuse_existing
  existing = AlIlegal::Analysis.existing_public_run(airbnb_path: airbnb_path, official_path: official_path)
  if existing
    puts "Run #{existing[:run_id]} já existe; a análise pública será reutilizada sem reescrever o snapshot."
    exit 0
  end
end
result = AlIlegal::Analysis.run(
  airbnb_path: airbnb_path,
  official_path: official_path,
  generate_pdf: ENV["GENERATE_PDF"] == "1",
  mode: mode,
  force: force
)

puts "Run #{result[:run_id]} criado em #{result[:path]}"
puts JSON.pretty_generate(result[:summary])
