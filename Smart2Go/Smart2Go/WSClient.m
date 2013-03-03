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
    NSString *urlPattern = [NSString stringWithFormat:@"https://www.car2go.com/api/v2.1/vehicles?loc=%@&oauth_consumer_key=%@&format=json", city, CONSUMER_KEY];
    
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
        NSDictionary *jsonResp = (NSDictionary *)[jsonData objectFromJSONData];
        NSArray *jsonArr = (NSArray *)[jsonResp objectForKey:@"placemarks"];
        if(jsonArr == nil)
            return freeCarsArr;
        
        for(NSDictionary *carDict in jsonArr) {
            FreeCar *buffCar = [[FreeCar alloc] init];
            
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
