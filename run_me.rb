require "csv"
require "json"
require "active_support/core_ext/object/blank"
require "haversine"
require_relative "lib/al_ilegal"

AlIlegal::Data.prepare!

license_counts = Hash.new(0)
CSV.foreach("data_sources/listings.csv", headers: true) do |row|
  license = AlIlegal.parse_al_license(row["license"])
  license_counts[license] += 1
end

data = CSV.foreach("data_sources/listings.csv", headers: true).map do |row|
  next if !row["neighbourhood_group_cleansed"].blank? && row["neighbourhood_group_cleansed"] != "Lisboa"

  license = AlIlegal.parse_al_license(row["license"])
  official_record = AlIlegal.licensed_als[license]

  license_status = if official_record.nil?
    "sem licença"
  elsif official_record.present?
    official_lat, official_lng = official_record["LatLong"].tr(",", ".").split(" ; ")
    distance_km = Haversine.distance(
      official_lat.to_f, official_lng.to_f,
      row["latitude"].to_f, row["longitude"].to_f
    ).to_km

    status = []
    status << "licença invalida (distancia #{distance_km})" if distance_km > 1
    status << "licença reutilizada #{license_counts[license]}" if license_counts[license] > 1

    status.join(";")
  end

  {
    fonte: "airbnb",
    licensa: license,
    licensa_raw: row["license"],
    license_status: license_status,
    url: row["listing_url"],
    bairro: row["neighbourhood_cleansed"],
    lat: row["latitude"],
    lng: row["longitude"],
    quartos: row["bedrooms"],
    host_id: row["host_id"],
    airbnb_date: Date.parse(row["last_scraped"]),
    official_date: official_record ? Date.parse(official_record["DataRegisto"]) : nil
  }
end
data.compact!

dates = {
  airbnb: data.map { |h| h[:airbnb_date] }.max.to_s,
  turismo_portugal: data.map { |h| h[:official_date] }.compact.max.to_s
}

# Basic stats
puts "\n\n"
puts "Ultimas actualizações:"
pp dates
puts "\n\n"

AlIlegal.stats(data)
puts "\n\n"

neighbourhoods = Set.new
data.each { |l| neighbourhoods << l[:bairro] }

neighbourhoods.sort.each do |neighbourhood|
  puts "**** #{neighbourhood}"
  AlIlegal.stats(data.select { |l| l[:bairro] == neighbourhood })
  puts "\n"
end

# Write CSV
headers = data.first.keys
CSV.open("data_sources/data_transformed/result.csv", "w", write_headers: true, headers: headers) do |csv|
  data.each do |row|
    csv << row.values_at(*headers)
  end
end
