require 'json'
require 'open-uri'

class CountryMesh
  def initialize
    data = JSON.parse(open('https://raw.githubusercontent.com/datasets/geo-countries/master/data/countries.geojson').read)

    @countries = {}
    data["features"].each do |feature|
      coordinates = feature["geometry"]["coordinates"]
      country = feature["properties"]["ISO_A2"]
      land = coordinates[0][0][0]

      # Only consider countries around Europe/North Africa/Asia
      if land[0] > -25 && land[0] < 135 && land[1] > 20 && land[1] < 72
        @countries[country] = coordinates
      end
    end
  end

  # http://www.eecs.umich.edu/courses/eecs380/HANDOUTS/PROJ2/InsidePoly.html
  def contains?(points, lat, lng)
    last_point = points[-1]
    odd_nodes = false
    y = lat
    x = lng
    points.each do |p|
      xi = p[0]
      yi = p[1]
      xj = last_point[0]
      yj = last_point[1]
      if yi <= y && y < yj || yj <= y && y < yi
        if x < (xj - xi) * (y - yi) / (yj - yi) + xi
          odd_nodes = !odd_nodes
        end
      end
      last_point = p
    end

    odd_nodes
  end

  def get_country(lat, lng)
    @countries.each do |code, country|
      country.each do |land|
        land.each do |subland|
          if contains?(subland, lat, lng)
            return code
          end
        end
      end
    end
  end
end
