<?php

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 * Description of FreeCar
 *
 * @author Hasan
 */
class FreeCar extends AppModel{
    
    private $currDate;
    private $identifier;
    private $longitude;
    private $latitude;
    private $address;
    private $fuelState;
    private $insideClean;
    private $outsideClean;
    private $city;
    
    /**
     * Check if {@link FreeCar this} car is in a given radius
     * <p>
     * @param lontitude2 - longitude of to calculating point
     * @param latitude2 - latitude of to calculating point
     * @param radius - value that we use for checking if distance is smaller 
     * <p>
     * @return {@link Boolean} if distance is smaller than the radius
     */
    public function isInRadius($longitude2, $latitude2, $radius) {
        //calculate distance
        $distance = calcDistance($longitude2, $latitude2);
        
        //if smaller return true
        if($distance <= $radius)
            return true;
        
        //else false
        return false;
    }
    
    /**
     * Calculates the distance of {@link FreeCar this} car
     * to a given geodata
     * <p>
     * We'll use this method to filter cars in a certain radius
     * <p>
     * @param lontitude2 - longitude of to calculating point
     * @param latitude2 - latitude of to calculating point
     * <p>
     * @return double - the distance bettween {@link FreeCar this} and 
     *                  the given geodata
     */
    public function calcDistance($longitude2, $latitude2) {
        //setting the unit to meter
        $unit = 'm';
        
        //calculating the actual distance
        $theta = $longitude1 - $longitude2;
        $distance = (sin(deg2rad($latitude1)) * sin(deg2rad($latitude2))) + (cos(deg2rad($latitude1)) * cos(deg2rad($latitude2)) * cos(deg2rad($theta)));
        $distance = acos($distance);
        $distance = rad2deg($distance);
        $distance = $distance * 60 * 1.1515;
        
        //reconsider unit
        switch ($unit) {
            case 'Mi': break;
            case 'Km' :
                $distance = $distance * 1.609344;
                break;
            case 'm' :
                $distance = $distance * 1.609344 * 1000;
                break;
        } 
        //return with rounding to 2 decimals
        return (round($distance, 2));
    }
  
}

?>