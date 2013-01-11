module FreeCarsHelper

		# /**
  #    * Check if {@link FreeCar this car is in a given radius
  #    * <p>
  #    * @param lontitude2 - longitude of to calculating point
  #    * @param latitude2 - latitude of to calculating point
  #    * @param radius - value that we use for checking if distance is smaller 
  #    * <p>
  # #    * @return {@link Boolean if distance is smaller than the radius
  # #    */
	 def isInRadius(longitude2, latitude2, radius) 
        #calculate distance
        distance = calcDistance(longitude2, latitude2)        
        #if smaller return true
        distance <= radius
    end
    
    # /**
    #  * Calculates the distance of {@link FreeCar this car
    #  * to a given geodata
    #  * <p>
    #  * We'll use this method to filter cars in a certain radius
    #  * <p>
    #  * @param lontitude2 - longitude of to calculating point
    #  * @param latitude2 - latitude of to calculating point
    #  * <p>
    #  * @return double - the distance bettween {@link FreeCar this and 
    #  *                  the given geodata
    #  */
    def calcDistance(longitude2, latitude2)
        #setting the unit to meter
        unit = 'm'
        
        #calculating the actual distance
        theta = longitude1 - longitude2
        distance = (sin(deg2rad(latitude1)) * sin(deg2rad(latitude2))) + (cos(deg2rad(latitude1)) * cos(deg2rad(latitude2)) * cos(deg2rad(theta)))
        distance = acos(distance)
        distance = rad2deg(distance)
        distance = distance * 60 * 1.1515
        
        #reconsider unit
        case unit
            when 'Mi'
            when 'km'  
              distance = distance * 1.609344           
            when 'm' 
              distance = distance * 1.609344 * 1000
        end
                
         
        #return with rounding to 2 decimals
         (round(distance, 2))
       end
    
end
