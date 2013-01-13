class Car < ActiveRecord::Base
	include GeoKit
  require 'open-uri'
  require 'json'
  attr_accessible  :engine_type, :exterior, :interior, :name, :vin, :fuel, :free, :latitude, :longitude,:location_attributes
  has_one :location
  accepts_nested_attributes_for :location
	# before_create :build_default_location

	 validates :vin, uniqueness: true
	 # validates :vin, :uniqueness => {:scope => :name}

  def is_in_radius?(dst_point,rad)  	
  	distance_to(dst_point) < rad
  end

  def distance_to(dst_point)
  	(position.distance_to(dst_point)*1000).round
  end

	def position
  	LatLng.new(latitude, longitude)
  end

  def latitude
  	location.latitude
  end

  def latitude=(lat)
  	location.latitude = lat
  end

  def longitude
  	location.longitude
  end

  def longitude=(lng)
  	location.longitude = lng
  end

  def self.update_free_status
    self.update_all(:free => false)
  end
  private
		def build_default_location
		  # build default profile instance. Will use default params.
		  # The foreign key to the owning User model is set automatically
		  build_location
		  true # Always return true in callbacks as the normal 'continue' state
		       # Assumes that the default_profile can **always** be created.
		       # or
		       # Check the validation of the profile. If it is not valid, then
		       # return false from the callback. Best to use a before_validation 
		       # if doing this. View code should check the errors of the child.
		       # Or add the child's errors to the User model's error array of the :base
		       # error item
		end



    def self.free_cars_json_from_request_if_cache_has_expired(req_location)
      logger.warn "FROM REQUEST+++++++++++++++++++++++++++++++++++++++++++++++++++++++"
      parsed_response = JSON.parse open("https://www.car2go.com/api/v2.1/vehicles?loc=#{req_location}&format=json&oauth_consumer_key=#{APP_CONFIG[:car2go_consumer_key]}").read
      [parsed_response, true]
      # if  Rails.cache.exist? "no_value_is_cached_#{req_location}"
      #   logger.warn "FROM CACHE++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
      #   # parsed_response = Rails.cache.read "no_value_is_cached_#{req_location}"
      #   [nil, false]
      # else
      #   logger.warn "FROM REQUEST+++++++++++++++++++++++++++++++++++++++++++++++++++++++"
      #   parsed_response = JSON.parse open("https://www.car2go.com/api/v2.1/vehicles?loc=#{req_location}&format=json&oauth_consumer_key=#{APP_CONFIG[:car2go_consumer_key]}").read
      #   Rails.cache.write("no_value_is_cached_#{req_location}", "", :expires_in => 30.seconds,:raw=>true) 
      #   [parsed_response, true]
      # end
    end

    def self.parse_or_load_cars_and_update_db(req_location)

      free_cars_json, cache_has_expired = free_cars_json_from_request_if_cache_has_expired(req_location)

      update_db_with_new_json_response(free_cars_json, req_location) if cache_has_expired
      
     
    
    end

    def self.update_db_with_new_json_response(free_cars_json, req_location)       
  

 
            # Car.update_all(:free => false)
            car_vins=[]

            # free_cars_json["placemarks"].take(10).each do |car|  #take just n cars for testing purposes        
            free_cars_json["placemarks"].each do |car|  
              car_vins << car["vin"]
              loc_attr, car_and_loc_attr = extract_car_and_location_attributes(car,req_location)

              if c = Car.find_by_vin(car["vin"]) #takes always 0.5ms
                unless loc_attr[:latitude] == c.latitude && loc_attr[:longitude] == c.longitude
                  c.location(loc_attr)
                end
                # c.free = true
                # c.save
              else
                c = Car.create(car_and_loc_attr[:car]) #about 30ms
              end

            end
             Car.where{vin << car_vins}.update_all(:free => true)
             Car.where{vin >> car_vins}.update_all(:free => false)
   

    end

    def self.extract_car_and_location_attributes(car, req_location)

    loc_attr =    
    {

      :city => req_location,
      :address => car["address"],
      :latitude => car["coordinates"][1],
      :longitude => car["coordinates"][0]   
        
      
    }
    # car_and_loc_attr = car_attr.merge! loc_attr
    car_and_loc_attr= 
    {
      :car => 
      {
              :engine_type => car["engineType"],
              :exterior => car["exterior"],
              :fuel => car["fuel"],
              :interior => car["interior"],
              :name => car["name"],
              :vin => car["vin"],
              :free => true,
        :location_attributes =>    
        {
              :city => req_location,
              :address => car["address"],
              :latitude => car["coordinates"][1],
              :longitude => car["coordinates"][0]   
        }
      }
    }

    [loc_attr, car_and_loc_attr] 
    end


end
