class Day < ApplicationRecord

  extend Geocoder::Model::ActiveRecord

  belongs_to :route

  # reverse_geocoded_by :latitude, :longitude
  # after_validation :reverse_geocode
end
