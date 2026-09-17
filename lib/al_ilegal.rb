require_relative "al_ilegal/data"
require "fileutils"
require "haversine"

module AlIlegal
  COLLAPSIBLE_ASSESSMENTS = [
    "provável estabelecimento com anúncios múltiplos",
    "licença repetida na mesma localização"
  ].freeze

  def self.parse_al_license(string)
    value = string.to_s.strip

    if value =~ /\A0*(\d+)(\/|\s|_|-|\\|&)*al\.?\z/i
      return $1.to_i.to_s
    end

    if value =~ /\Aal(\/|\s|_|-|\\|&)*0*(\d+)\z/i
      return $2.to_i.to_s
    end

    return value.to_i.to_s if /\A0*\d+\z/.match?(value)

    if value =~ /\A0*(\d+)\s*\/\s*20[12]\d\z/
      return $1.to_i.to_s
    end

    nil
  end

  def self.parse_lat_long(string)
    coordinates = string.to_s.split(/\s*;\s*/)
    raise ArgumentError, "Invalid LatLong value: #{string.inspect}" unless coordinates.size == 2

    coordinates.map { |coordinate| Float(coordinate.tr(",", ".")) }
  end

  def self.spatial_clusters(listings, threshold_km: 0.5)
    clusters = []

    listings.each do |listing|
      coordinates = [listing[:lat].to_f, listing[:lng].to_f]
      matching_clusters = clusters.each_index.select do |index|
        clusters[index].any? do |member|
          Haversine.distance(
            coordinates[0], coordinates[1], member[:lat].to_f, member[:lng].to_f
          ).to_km <= threshold_km
        end
      end

      if matching_clusters.empty?
        clusters << [listing]
      else
        target = matching_clusters.first
        clusters[target] << listing
        matching_clusters.drop(1).reverse_each do |index|
          clusters[target].concat(clusters.delete_at(index))
        end
      end
    end

    clusters
  end

  def self.license_group_assessment(listings, official_record)
    return "sem licença identificável" if listings.first[:licensa].to_s.empty?
    return "licença oficial fora de Lisboa" if official_record && official_record["Concelho"] != "Lisboa"
    return "licença única em Lisboa" if listings.size == 1
    return "licença repetida em várias localizações" if spatial_clusters(listings).size > 1

    room_like = listings.count do |listing|
      [listing[:nome], listing[:room_type], listing[:property_type]].join(" ").match?(
        /room|bed|suite|quarto|dorm|hostel|guesthouse|guest house|hotel|studio|apartment|flat|residenc|residencial/i
      )
    end
    official_lodging = official_record && official_record["Modalidade"].to_s.match?(/Hospedagem|Hostel|Quartos/i)

    if official_lodging || room_like >= listings.size * 0.5
      "provável estabelecimento com anúncios múltiplos"
    else
      "licença repetida na mesma localização"
    end
  end

  def self.establishment_estimate(listings)
    collapsed_rows = listings.group_by { |listing| listing[:licensa] }.sum do |license, group|
      next 0 if license.to_s.empty?
      next 0 unless COLLAPSIBLE_ASSESSMENTS.include?(group.first[:license_group_assessment])

      group.size - 1
    end

    listings.size - collapsed_rows
  end

  def self.licensed_als(source_path = "data_sources/Estabelecimentos_de_Alojamento_Local.csv")
    cache_path = "tmp/licensed_als-#{File.basename(source_path, ".csv")}.json"
    @licensed_als ||= if File.exist?(cache_path)
      JSON.parse(File.read(cache_path))
    else
      valid_licenses = {}
      CSV.foreach(source_path, headers: true) do |row|
        license = row["NrRNAL"]
        valid_licenses[license] = row.to_h
      end
      FileUtils.mkdir_p("tmp")
      File.write(cache_path, JSON.pretty_generate(valid_licenses))

      valid_licenses
    end
  end

  def self.stats(data, header = "", include_establishment_estimate: false)
    puts "#{data.size} listagens de AirBnb"
    if include_establishment_estimate
      puts "#{establishment_estimate(data)} ALs/estabelecimentos prováveis após deduplicação (estimativa)"
    end

    missing_license_type = {
      nil: data.count { |l| l[:licensa_raw].nil? },
      exempt: data.count { |l| l[:licensa_raw] =~ /Exempt/i },
      others: data.count { |l| l[:license_status] =~ /sem licença/ && !(l[:licensa_raw].nil? || l[:licensa_raw] =~ /Exempt/i) }
    }
    missing_license_summary = [
      "#{missing_license_type[:nil]} sem licença",
      "#{missing_license_type[:exempt]} isentos(?)",
      "#{missing_license_type[:others]} não reconhecidos"
    ].join(", ")

    puts "#{data.count { |l| l[:license_status].blank? }} com licença AL válida"
    puts "#{data.count { |l| l[:license_status] =~ /sem licença/ }} com licença não reconhecida (#{missing_license_summary})"
    distinct_location_count = data.count { |listing| listing[:spatial_cluster_count].to_i > 1 }
    puts "#{distinct_location_count} em que o mesmo número de licença aparece em locais distintos"
    puts "#{data.count { |l| l[:license_status] =~ /distancia/ }} em que a licença AL é numa outra localidade"
  end

  def self.dates(data)
  end
end
