#!/usr/bin/env ruby
require_relative "lib/al_ilegal"

airbnb_path, official_path = AlIlegal::Data.prepare!
result = AlIlegal::Analysis.run(
  airbnb_path: airbnb_path,
  official_path: official_path,
  generate_pdf: ENV["GENERATE_PDF"] == "1"
)

puts "Run #{result[:run_id]} criado em #{result[:path]}"
puts JSON.pretty_generate(result[:summary])
