//
//  FreeCar.m
//  Smart2Go
//
//  Created by Hasan Gürcan on 22.01.13.
//  Copyright (c) 2013 Hasan Gürcan. All rights reserved.
//

#import "FreeCar.h"

@implementation FreeCar

- (CarLocation *)parseToCarLocation {
    NSString *carNameWithFuelState = [NSString stringWithFormat:@"%@ %d%%", self.carName, [self.fuel intValue]];
    CarLocation *carLocation = [[CarLocation alloc] initWithName:carNameWithFuelState address:self.address coordinate:CLLocationCoordinate2DMake([self.latitude doubleValue], [self.longitude doubleValue]) isCar2Go: self.isCar2Go fuelState:self.fuel];
    
    //NSLog(@"Carname:\t%@\nAddress:\t%@\nlatitude:\t%f\nlongitude:\t%f", self.carName, self.address, [self.latitude doubleValue], [self.longitude doubleValue]);
    
    return carLocation;
}

@end
