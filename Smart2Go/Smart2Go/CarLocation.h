//
//  CarLocation.h
//  Smart2Go
//
//  Created by Hasan Gürcan on 15.01.13.
//  Copyright (c) 2013 Hasan Gürcan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CarLocation : NSObject <MKAnnotation>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSNumber *fuelState;
@property (nonatomic, assign) BOOL isC2G;

/**
 *  Create a CarLocation instance
 *  <p>
 *  @param name - the name that will be shown for this CarLocation
 *                  We'll use the Car-Names like "B-GO-xxxx"
 *  @param address - the address where the car will be located at
 *  @param coordinate - the GPS-Coordinates that are necessary for draw the location
 *  <p>
 *  @return {@link CarLocation} the created instance 
 */
- (id) initWithName: (NSString *)name address:(NSString *)address coordinate:(CLLocationCoordinate2D)coordinate isCar2Go:(BOOL)isC2G;

/**
 *  Create a CarLocation instance
 *  <p>
 *  @param name - the name that will be shown for this CarLocation
 *                  We'll use the Car-Names like "B-GO-xxxx"
 *  @param address - the address where the car will be located at
 *  @param coordinate - the GPS-Coordinates that are necessary for draw the location
 *  <p>
 *  @return {@link CarLocation} the created instance
 */
- (id) initWithName: (NSString *)name address:(NSString *)address coordinate:(CLLocationCoordinate2D)coordinate isCar2Go:(BOOL)isC2G fuelState:(NSNumber *)fuelState;

/**
 *  Call this method to get a {@link MKMapItem} that you need 
 *  for drawing {@link CarLocation this} location on your maps
 *  <p>
 *  @return {@link MKMapItem}
 */
- (MKMapItem *)mapItem;

@end
