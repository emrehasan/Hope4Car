class FreeCarsController < ApplicationController
  require 'open-uri'
	require 'json'
  def index
		# Rails.cache.clear
  	if 	Rails.cache.exist? 'response'
  		logger.debug "IF+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
		  @response = Rails.cache.read 'response'
		else
			logger.debug "ELSE+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
			@response = open("https://www.car2go.com/api/v2.1/vehicles?loc=Berlin&format=json&oauth_consumer_key=JohannesRuth").read
		 	Rails.cache.write('response', @response, :expires_in => 60.seconds,:raw=>true)
		end
		@parsed_response = JSON.parse @response
# @point_a=Geokit::Geocoders::GoogleGeocoder.geocode '789 Geary St, San Francisco, CA'
	  @loc_a=Geokit::Geocoders::GoogleGeocoder.geocode 'Glasower Str. 54, Berlin, 12051'
	  @point_a = Geokit::LatLng.new(@loc_a.lat, @loc_a.lng)
		@cars = []
		@parsed_response["placemarks"].each do |car|	
			
			freecar = FreeCar.new
			freecar.address = car["address"]
			freecar.coordinates = car["coordinates"]
			freecar.engineType = car["engineType"]
			freecar.exterior = car["exterior"]
			freecar.fuel = car["fuel"]
			freecar.interior = car["interior"]
			freecar.name = car["name"]
			freecar.vin = car["vin"]
			freecar.latitude = car["coordinates"][1]
			freecar.longitude = car["coordinates"][0]			
			# @point_b=Geokit::LatLng.new(freecar.latitude, freecar.longitude)
			# @distance = @point_a.distance_to(@point_b)

		  @cars << freecar 
	  end

	   # @point_b=Geokit::Geocoders::GoogleGeocoder.geocode '789 Geary St, San Francisco, CA'
	
		# @cars = FreeCar.

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @cars }
    end
  end
end
