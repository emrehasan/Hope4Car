//
//  WSClient.m
//  Smart2Go
//
//  Created by Hasan Gürcan on 21.01.13.
//  Copyright (c) 2013 Hasan Gürcan. All rights reserved.
//

#import "WSClient.h"
#import "SMXMLDocument.h"
#import "JSONKit.h"
#import "FreeCar.h"

@implementation WSClient

- (NSString *)identifyCity:(CLLocation *)location {
    NSString *latitude = [[NSNumber numberWithDouble:location.coordinate.latitude] stringValue];
    NSString *longitude = [[NSNumber numberWithDouble:location.coordinate.longitude] stringValue];
    
    //create api-url
    NSString *urlPattern = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/xml?latlng=%@,%@&sensor=true", latitude, longitude];
        
    //call google-api
    NSData *xmlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlPattern ]];
    NSError *error;
    
    //create xml document
    SMXMLDocument *xmlDoc = [[SMXMLDocument alloc] initWithData:xmlData error:&error];
    
    //check if xml could be created
    if(error != nil)
        NSLog(@"Error Occured:%@", [error description]);
    
    //parse xml now
    else {
        SMXMLElement *root = xmlDoc.root;
        
        SMXMLElement *status = [root childNamed:@"status"];
        if(![[status value] isEqualToString:@"OK"])
            return nil;
        
        //get interesting fields now
        NSArray *addressComponents = [[root childNamed:@"result"] childrenNamed:@"address_component"];
        for(SMXMLElement *addressComponent in addressComponents) {
            NSArray *types = [addressComponent childrenNamed:@"type"];
            if( !( [[(SMXMLElement *)[types objectAtIndex:0] value] isEqualToString:@"locality"]
                  /*||    [[(SMXMLElement *)[types objectAtIndex:1] value] isEqualToString:@"locality"]*/)) {
                continue;
            }
            
            //else
            NSString *cityLabel = [[addressComponent childNamed:@"short_name"] value];
            NSLog(@"City-Label:\t%@", cityLabel);
            return cityLabel;
        }
    }
    
    return nil;
}

- (NSArray *)loadFreeCars:(NSString *)city {
    NSMutableArray *freeCars = [[NSMutableArray alloc] initWithCapacity:2000];
    
    [freeCars addObjectsFromArray:[self loadFreeCarsDN:city]];
    [freeCars addObjectsFromArray:[self loadFreeCarsC2G:city]];
    
    return freeCars;
}

/**
 *  Will request all free cars for all cities at the drivenow-api
 *  <p>
 *  @return {@link NSMutableArray} with {@link FreeCar objects}
 */
- (NSArray *)loadFreeCarsDN:(NSString *)city {
    NSLog(@"Calling DriveNow FreeCars loading");
    NSMutableArray *freeCars = [[NSMutableArray alloc] initWithCapacity:1100];
    
    //retrieve
    NSString *cityID = [self getCityIDForDriveNow:city];
    
    //create api-url
    NSString *urlPattern = [NSString stringWithFormat:@"https://www.drive-now.com/php/metropolis/json.vehicle_filter?cit=%@", cityID];
    
    //call server-api
    NSError *error;
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlPattern]];
    NSURLResponse *response;
    NSData *jsonData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    //check if xml could be created
    if(error != nil)
        NSLog(@"Error Occured:%@", [error description]);
    
    else {
        //create json document
        NSDictionary *jsonResp = (NSDictionary *)[jsonData objectFromJSONData];
        NSDictionary *recDict = (NSDictionary *)[jsonResp objectForKey:@"rec"];
        NSDictionary *vehiclesDict = (NSDictionary *)[recDict objectForKey:@"vehicles"];
        
        NSArray *vehiclesArr = (NSArray *)[vehiclesDict objectForKey:@"vehicles"];
        
        if(vehiclesArr == nil)
            return freeCars;
        
        //else
        NSLog(@"Size of DriveNow-Arr:\t%d", [vehiclesArr count]);
        FreeCar *buffCar;
        for(NSDictionary *carDict in vehiclesArr) {
            buffCar = [[FreeCar alloc] init];
            
            NSDictionary *positionDict = (NSDictionary *)[carDict objectForKey:@"position"];
            
            NSNumber *latitude = [NSNumber numberWithDouble:[[positionDict objectForKey:@"latitude"] doubleValue]];
            NSNumber *longitude = [NSNumber numberWithDouble:[[positionDict objectForKey:@"longitude"] doubleValue]];
            NSString *address = [positionDict objectForKey:@"address"];
            NSNumber *fuel = [NSNumber numberWithInt:[[carDict objectForKey:@"fuelState"] intValue]];
            NSString *vin = [carDict objectForKey:@"vin"];
            NSString *carName = [carDict objectForKey:@"personalName"];
            NSString *engineType = [carDict objectForKey:@"fuelType"];
            NSString *interior = [carDict objectForKey:@"innerCleanliness"];
            
            //set freecar members now
            buffCar.isCar2Go = NO;
            buffCar.latitude = latitude;
            buffCar.longitude = longitude;
            buffCar.address = address;
            buffCar.fuel = fuel;
            buffCar.engineType = engineType;
            buffCar.interior = interior;
            buffCar.carName = carName;
            buffCar.vin = vin;
            
            [freeCars addObject:buffCar];
        }
    }
    
    return freeCars;
}

- (NSString *)getCityIDForDriveNow:(NSString *)city {
    if([city isEqualToString:@"Berlin"])
        return @"6099";
    else if([city isEqualToString:@"Düsseldorf"])
        return @"";
    else if([city isEqualToString:@"Düsseldorf"])
        return @"";
    else if([city isEqualToString:@"Düsseldorf"])
        return @"";
    else
        return @"-1";
}

/**
 *  Return the correct identifier for the car2go-API
 *  <p>
 *  In this case all cities that are responded by google 
 *  are the same as awaited from the car2go-API except for
 *  Düsseldorf that is awaited as Duesseldorf
 *  <p>
 *  @param city - the city that was retrieved by the Google-API
 *  <p>
 *  @return the correct identifier as awaited by the Car2Go-API
 */
- (NSString *)getCityForCar2Go:(NSString *)city {
    if([city isEqualToString:@"Düsseldor"])
        return @"Duesseldorf";
    else
        return city;
}

- (NSArray *)loadFreeCarsC2G:(NSString *)city {
    
    NSMutableArray *freeCarsArr = [[NSMutableArray alloc] initWithCapacity:950];
    
    //identify cityID
    NSString *cityID = [self getCityForCar2Go:city];
    
    //create api-url
    NSString *urlPattern = [NSString stringWithFormat:@"https://www.car2go.com/api/v2.1/vehicles?loc=%@&oauth_consumer_key=%@&format=json", cityID, CONSUMER_KEY];
        
    //call server-api
    NSError *error;
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlPattern]];
    NSURLResponse *response;
    NSData *jsonData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    //check if xml could be created
    if(error != nil)
        NSLog(@"Error Occured:%@", [error description]);
    
    else {
        //create json document
        NSDictionary *jsonResp = (NSDictionary *)[jsonData objectFromJSONData];
        NSArray *jsonArr = (NSArray *)[jsonResp objectForKey:@"placemarks"];
        if(jsonArr == nil)
            return freeCarsArr;
        
        FreeCar *buffCar;
        for(NSDictionary *carDict in jsonArr) {
            buffCar = [[FreeCar alloc] init];
            
            NSNumber *fuel = [NSNumber numberWithInt:[[carDict objectForKey:@"fuel"] intValue]];
            NSArray *coordinates = (NSArray *)[carDict objectForKey:@"coordinates"];
            NSNumber *longitude = [NSNumber numberWithDouble:[[coordinates objectAtIndex:0] doubleValue]];
            NSNumber *latitude = [NSNumber numberWithDouble:[[coordinates objectAtIndex:1] doubleValue]];
            
            NSString *carName = [carDict objectForKey:@"name"];
            NSString *engineType = [carDict objectForKey:@"engineType"];
            NSString *exterior = [carDict objectForKey:@"exterior"];
            NSString *interior = [carDict objectForKey:@"interior"];
            NSString *vin = [carDict objectForKey:@"vin"];
            NSString *address = [carDict objectForKey:@"address"];
            
            //check if one of the values were nil
            if(fuel == nil ||
               longitude == nil || latitude == nil || carName == nil || engineType == nil ||
               exterior == nil || interior == nil || vin == nil || address == nil) {
                /*
                if(longitude == nil)
                    NSLog(@"Longitude value was nil");
                if(latitude == nil)
                    NSLog(@"Latitude value was nil");
                if(carName == nil)
                    NSLog(@"CarName value was nil");
                if(engineType == nil)
                    NSLog(@"EngineType value was nil");
                if(exterior == nil)
                    NSLog(@"exterior value was nil");
                if(interior == nil)
                    NSLog(@"interior value was nil");
                if(vin == nil)
                    NSLog(@"vin value was nil");
                if(address == nil)
                    NSLog(@"address value was nil");
                 */
                NSLog(@"An essential member was nil");
                continue;
            }
            
            //else
            buffCar.isCar2Go = YES;
            buffCar.fuel = fuel;
            buffCar.longitude = longitude;
            buffCar.latitude = latitude;
            buffCar.carName = carName;
            buffCar.engineType = engineType;
            buffCar.exterior = exterior;
            buffCar.interior = interior;
            buffCar.vin = vin;
            buffCar.address = address;
            
            //add to array
            [freeCarsArr addObject:buffCar];
        }
    }
    

    return freeCarsArr;
}

@end
