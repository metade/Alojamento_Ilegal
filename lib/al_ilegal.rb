require_relative "al_ilegal/data"
require "fileutils"

module AlIlegal
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

  def self.stats(data, header = "")
    puts "#{data.size} listagens de AirBnb"

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
    puts "#{data.count { |l| l[:license_status] =~ /reutilizada/ }} em que a licença AL foi reutilizada"
    puts "#{data.count { |l| l[:license_status] =~ /distancia/ }} em que a licença AL é numa outra localidade"
  end

  def self.dates(data)
  end
end
