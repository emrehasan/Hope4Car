class Location < ActiveRecord::Base
  attr_accessible :address, :city, :latitude, :longitude

  belongs_to :car
end
