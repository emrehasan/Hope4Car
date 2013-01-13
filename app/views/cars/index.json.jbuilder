json.array!(@cars) do |car|
  	json.id car.id
  	json.updated_at (Time.now - car.updated_at.to_time).round
  	json.name car.name
		json.fuel car.fuel 
		json.distance_to car.distance_to(@point) 
		json.engine_type car.engine_type 
		json.exterior car.exterior 
		json.interior car.interior 
		json.vin car.vin 
		json.latitude car.latitude 
		json.longitude car.longitude 
		json.address car.location.address 
  
end