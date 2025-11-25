require_relative "al_ilegal/data"
require "fileutils"

module AlIlegal
  def self.parse_al_license(string)
    return $1 if string =~ /(\d+)(\/| |_|-|\\|&)*al/i
    return $2 if string =~ /al(\/| |_|-|\\|&)*(\d+)/i
    return string if /\A\d+\z/.match?(string)
    string if /(\d+)\/20[12]\d/.match?(string)
  end

  def self.licensed_als
    @licensed_als ||= if File.exist?("tmp/licensed_als.json")
      JSON.parse(File.read("tmp/licensed_als.json"))
    else
      valid_licenses = {}
      CSV.foreach("data_sources/Estabelecimentos_de_Alojamento_Local.csv", headers: true) do |row|
        license = row["NrRNAL"]
        valid_licenses[license] = row.to_h
      end
      FileUtils.mkdir_p("tmp")
      File.write("tmp/licensed_als.json", JSON.pretty_generate(valid_licenses))

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
