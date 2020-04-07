require "geocoder"
require "json"
require "offline_geocoder"
require "pry"

class GeocoderService
  def initialize
    @offline_geocoder = OfflineGeocoder.new
    @online_geocoder = Geocoder
    @online_geocoder.config[:timeout] = 10
    load_api_cache
  end

  def offline_geocoder(lat, lon)
    @offline_geocoder.search(lat, lon)[:cc]
  end

  def online_geocoder(name)
    @cache[name] || fetch_geocode_from_api(name)
  end

  def save_api_cache
    File.open(CACHE_FILE, 'w') { |file| file.write(JSON.pretty_generate(@cache)) }
  end

  private

  CACHE_FILE = 'data/geocoder.json'.freeze

  def load_api_cache
    @cache = JSON.parse(File.read(CACHE_FILE))
  end

  def fetch_geocode_from_api(name)
    @cache[name] = @online_geocoder.search(name).compact.map do |result|
      result.data['address']['country_code']&.upcase if result
    end.compact.uniq

    @cache[name]
  end

end
