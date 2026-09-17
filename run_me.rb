require "csv"
require "json"
require "active_support/core_ext/object/blank"
require "haversine"
require_relative "lib/al_ilegal"

airbnb_path, official_path = AlIlegal::Data.prepare!
licensed_als = AlIlegal.licensed_als(official_path)

license_counts = Hash.new(0)
CSV.foreach(airbnb_path, headers: true) do |row|
  license = AlIlegal.parse_al_license(row["license"])
  license_counts[license] += 1
end

data = CSV.foreach(airbnb_path, headers: true).map do |row|
  next if !row["neighbourhood_group_cleansed"].blank? && row["neighbourhood_group_cleansed"] != "Lisboa"

  license = AlIlegal.parse_al_license(row["license"])
  official_record = licensed_als[license]

  license_status = if official_record.nil?
    "sem licença"
  elsif official_record.present?
    official_lat, official_lng = AlIlegal.parse_lat_long(official_record["LatLong"])
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
    nome: row["name"],
    lat: row["latitude"],
    lng: row["longitude"],
    room_type: row["room_type"],
    property_type: row["property_type"],
    quartos: row["bedrooms"],
    host_id: row["host_id"],
    airbnb_date: Date.parse(row["last_scraped"]),
    official_date: official_record ? Date.parse(official_record["DataRegisto"]) : nil,
    official_name: official_record && official_record["Denominacao"],
    official_address: official_record && official_record["Endereco"],
    official_concelho: official_record && official_record["Concelho"],
    official_modalidade: official_record && official_record["Modalidade"],
    official_capacity: official_record && official_record["NrUtentes"]
  }
end
data.compact!

# Classify repeated licence numbers without collapsing the original listings.
data.group_by { |listing| listing[:licensa] }.each do |license, listings|
  next if license.to_s.empty?

  clusters = AlIlegal.spatial_clusters(listings)
  assessment = AlIlegal.license_group_assessment(listings, licensed_als[license])
  listings.each do |listing|
    listing[:spatial_cluster_count] = clusters.size
    listing[:license_group_assessment] = assessment
  end
end

data.each do |listing|
  listing[:spatial_cluster_count] ||= 1
  listing[:license_group_assessment] ||= "sem licença identificável"
end

puts "\n\nClassificação dos grupos de licenças:"
data.group_by { |listing| listing[:license_group_assessment] }.sort_by { |assessment, _| assessment }.each do |assessment, listings|
  groups = listings.map { |listing| listing[:licensa] }.reject { |license| license.to_s.empty? }.uniq.size
  puts "#{assessment}: #{listings.size} anúncios (#{groups} licenças)"
end

dates = {
  airbnb: data.map { |h| h[:airbnb_date] }.max.to_s,
  turismo_portugal: data.map { |h| h[:official_date] }.compact.max.to_s
}

# Basic stats
puts "\n\n"
puts "Ultimas actualizações:"
pp dates
puts "\n\n"

AlIlegal.stats(data, include_establishment_estimate: true)
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
