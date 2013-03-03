//
//  WSClient.h
//  Smart2Go
//
//  Created by Hasan Gürcan on 21.01.13.
//  Copyright (c) 2013 Hasan Gürcan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

#define CONSUMER_KEY    @"smart2go"

@interface WSClient : NSObject

@property (nonatomic, retain) NSMutableArray *freeCars;

/**
 *  Will identify the city where you currently are
 */
- (NSString *)identifyCity:(CLLocation *)location;

/**
 *  Will load all free cars for the identified city {identified by this#identifyCity}
 *  <p>
 *  Will save them in an array
 *  <p>
 *  @return NSArray - free cars see model {@link FreeCar}
 */
- (NSArray *)loadFreeCars:(NSString *)city;

@end
