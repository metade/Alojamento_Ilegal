require 'uri'
require 'zlib'
require 'open-uri'

module AlIlegal
  module Data
    def self.prepare!
      prepare_airbnb!
      prepare_alojamentos_locais!
    end

    def self.prepare_alojamentos_locais!
      return if File.exist?("data_sources/Estabelecimentos_de_Alojamento_Local.csv")

      url = "https://hub.arcgis.com/api/download/v1/items/4e62eb1977564991bd01e61d7aa8266f/csv?redirect=false&layers=6"
      download_data = URI.open(url) do |remote_file|
        JSON.parse(remote_file.read)
      end
      csv_url = download_data["resultUrl"]

      URI.open(csv_url) do |remote_file|
        File.write("data_sources/Estabelecimentos_de_Alojamento_Local.csv", remote_file.read)
      end
    end

    def self.prepare_airbnb!
      return if File.exist?("data_sources/listings.csv")
      airbnb_data_url = "https://data.insideairbnb.com/portugal/lisbon/lisbon/2025-03-08/data/listings.csv.gz"

      URI.open(airbnb_data_url) do |remote_file|
        Zlib::GzipReader.wrap(remote_file) do |gz|
          File.write("data_sources/listings.csv", gz.read)
        end
      end
    end
  end
end
