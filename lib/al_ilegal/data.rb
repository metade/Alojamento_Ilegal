require "uri"
require "zlib"
require "open-uri"

module AlIlegal
  module Data
    def self.prepare!
      [prepare_airbnb!, prepare_alojamentos_locais!]
    end

    def self.prepare_alojamentos_locais!
      date = Date.today
      path = "data_sources/Estabelecimentos_de_Alojamento_Local-#{date}.csv"
      return path if File.exist?(path)

      url = "https://hub.arcgis.com/api/download/v1/items/4e62eb1977564991bd01e61d7aa8266f/csv?redirect=false&layers=6"
      download_data = URI.open(url) do |remote_file|
        JSON.parse(remote_file.read)
      end
      csv_url = download_data["resultUrl"]

      URI.open(csv_url) do |remote_file|
        File.write(path, remote_file.read)
      end

      path
    end

    def self.prepare_airbnb!
      date = "2026-06-23"
      path = "data_sources/listings-#{date}.csv"
      puts "Using Airbnb date from #{date} - check if there's a more up to date version here: https://insideairbnb.com/get-the-data/"
      return path if File.exist?(path)
      puts "  ... downloading airbnb data"

      airbnb_data_url = "https://data.insideairbnb.com/portugal/lisbon/lisbon/#{date}/data/listings.csv.gz"

      URI.open(airbnb_data_url) do |remote_file|
        Zlib::GzipReader.wrap(remote_file) do |gz|
          File.write(path, gz.read)
        end
      end

      path
    end
  end
end
