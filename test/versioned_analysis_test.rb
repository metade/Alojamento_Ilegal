require "minitest/autorun"
require "tmpdir"
require_relative "../lib/al_ilegal"

class VersionedAnalysisTest < Minitest::Test
  HEADERS = %w[neighbourhood_group_cleansed license listing_url neighbourhood_cleansed name latitude longitude room_type property_type bedrooms host_id last_scraped]

  def test_creates_immutable_versioned_outputs_and_history
    Dir.mktmpdir do |dir|
      airbnb = File.join(dir, "listings.csv")
      official = File.join(dir, "official-2026-09-17.csv")
      CSV.open(airbnb, "w", write_headers: true, headers: HEADERS) do |csv|
        csv << ["Lisboa", "00123/AL", "https://example/1", "Alfama", "Apartment", "38.71", "-9.14", "Entire home/apt", "Apartment", "1", "1", "2026-06-23"]
        csv << ["Lisboa", nil, "https://example/2", "Alfama", "No licence", "38.72", "-9.14", "Entire home/apt", "Apartment", "1", "2", "2026-06-23"]
      end
      CSV.open(official, "w", write_headers: true, headers: %w[NrRNAL LatLong DataRegisto Denominacao Endereco Concelho Modalidade NrUtentes]) do |csv|
        csv << ["123", "38.71;-9.14", "2020-01-01", "Casa", "Rua", "Lisboa", "Apartamento", "2"]
      end

      result = AlIlegal::Analysis.run(airbnb_path: airbnb, official_path: official, output_root: File.join(dir, "snapshots"), history_path: File.join(dir, "history", "summary.csv"))
      run_dir = result[:path]
      assert_equal "2026-06-23__2026-09-17", result[:run_id]
      assert_equal %w[metadata.json report.html summary.json listings.csv licence_groups.csv freguesias.csv].sort, Dir.children(run_dir).sort
      assert_equal 2, CSV.read(File.join(run_dir, "listings.csv"), headers: true).length
      assert_equal "1.0.0", JSON.parse(File.read(File.join(run_dir, "metadata.json"))) ["output_schema_version"]
      assert_raises(RuntimeError) { AlIlegal::Analysis.run(airbnb_path: airbnb, official_path: official, output_root: File.join(dir, "snapshots"), history_path: File.join(dir, "history", "summary.csv")) }
    end
  end
end
