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
    
    NSLog(@"URLPattern:\t%@",urlPattern );
    
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
            return cityLabel;
        }
    }
    
    return nil;
}

- (NSArray *)loadFreeCars:(NSString *)city {
    
    NSMutableArray *freeCarsArr = [[NSMutableArray alloc] initWithCapacity:400];
    
    //create api-url
    NSString *urlPattern = [NSString stringWithFormat:@"http://car4now.herokuapp.com/cars.json?city=%@&radius=20000", city];
    
    NSLog(@"URL-Pattern FreeCars:\t%@", urlPattern);
    
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
        NSArray *jsonArr = (NSArray *)[jsonData objectFromJSONData];
        if(jsonArr == nil)
            return freeCarsArr;
        
        for(NSDictionary *carDict in jsonArr) {
            FreeCar *buffCar = [[FreeCar alloc] init];
            
            NSNumber *carID = [NSNumber numberWithInt:[[carDict objectForKey:@"id"] intValue]];
            NSNumber *lastRefresh = [NSNumber numberWithInt:[[carDict objectForKey:@"last_refresh"] intValue]];
            NSNumber *fuel = [NSNumber numberWithInt:[[carDict objectForKey:@"fuel"] intValue]];
            NSNumber *distanceTo = [NSNumber numberWithInt:[[carDict objectForKey:@"distance_to"] intValue]];
            NSNumber *longitude = [NSNumber numberWithDouble:[[carDict objectForKey:@"longitude"] doubleValue]];
            NSNumber *latitude = [NSNumber numberWithDouble:[[carDict objectForKey:@"latitude"] doubleValue]];
            
            NSString *carName = [carDict objectForKey:@"name"];
            NSString *engineType = [carDict objectForKey:@"engine_type"];
            NSString *exterior = [carDict objectForKey:@"exterior"];
            NSString *interior = [carDict objectForKey:@"interior"];
            NSString *vin = [carDict objectForKey:@"vin"];
            NSString *address = [carDict objectForKey:@"address"];
            
            //check if one of the values were nil
            if(carID == nil|| lastRefresh == nil || fuel == nil || distanceTo == nil ||
               longitude == nil || latitude == nil || carName == nil || engineType == nil ||
               exterior == nil || interior == nil || vin == nil || address == nil) {
                NSLog(@"An essential value was nil");
                continue;
            }
            
            //else
            buffCar.carID = carID;
            buffCar.lastRefresh = lastRefresh;
            buffCar.fuel = fuel;
            buffCar.distanceTo = distanceTo;
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
