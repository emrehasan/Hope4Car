class FreeCar 

	include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  include Geokit::Geocoders
	attr_accessor :address,
								:coordinates,
								:engineType,
								:exterior,
								:fuel,
								:interior,
								:name,
								:vin,
								:latitude, 
								:longitude



	# geocoder_options

	def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end
  
  def persisted?
    false
  end
    # @loc_a = Geokit::LatLng.new(32.918593,-96.958444)
    # @loc_e = Geokit::LatLng.new(32.969527,-96.990159)
    # @point = Geokit::LatLng.new(@loc_a.lat, @loc_a.lng)
  def isInRadius?(point,rad)  	
  	if self.distance_to(point) < rad
  		true
  	else
  		false
  	end

  end

  def distance_to(dst_point)
  	own_point=Geokit::LatLng.new(self.latitude, self.longitude)
  	dist = own_point.distance_to(dst_point)*1000
  	dist
  end
end
