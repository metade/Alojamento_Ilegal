module AlIlegal
  def self.parse_al_license(string)
    return $1 if string =~ /(\d+)(\/| |_|-|\\|&)*al/i
    return $2 if string =~ /al(\/| |_|-|\\|&)*(\d+)/i
    return string if string =~ /\A\d+\z/
    return string if string =~ /(\d+)\/20[12]\d/
  end

  def self.licensed_als
    @licensed_als ||= begin
      if File.exist?("tmp/licensed_als.json")
        JSON.parse(File.read("tmp/licensed_als.json"))
      else
        valid_licenses = {}
        CSV.foreach("data/Estabelecimentos_de_Alojamento_Local.csv", headers: true) do |row|
          license = row["NrRNAL"]
          valid_licenses[license] = row.to_h
        end
        File.write("tmp/licensed_als.json", JSON.pretty_generate(valid_licenses))

        valid_licenses
      end
    end
  end

  def self.stats(data, header = "")
    puts "#{data.size} listagens de AirBnb"
    puts "#{data.count { |l| l[:license_status].blank? }} com licença AL válida"
    puts "#{data.count { |l| l[:license_status] =~ /sem licença/ }} sem licença"
    puts "#{data.count { |l| l[:license_status] =~ /reutilizada/ }} em que a licença AL foi reutilizada"
    puts "#{data.count { |l| l[:license_status] =~ /distancia/ }} em que a licença AL é numa outra localidade"
  end
end
