//
//  FreeCar.h
//  Smart2Go
//
//  Created by Hasan Gürcan on 22.01.13.
//  Copyright (c) 2013 Hasan Gürcan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CarLocation.h"

@interface FreeCar : NSObject 

@property (nonatomic, assign) NSString *carName;
@property (nonatomic, assign) NSString *engineType;
@property (nonatomic, assign) NSString *exterior;
@property (nonatomic, assign) NSString *interior;
@property (nonatomic, assign) NSString *vin;
@property (nonatomic, assign) NSString *address;

@property (nonatomic, retain) NSNumber *carID;
@property (nonatomic, retain) NSNumber *lastRefresh;
@property (nonatomic, retain) NSNumber *fuel;
@property (nonatomic, retain) NSNumber *distanceTo;
@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSNumber *longitude;

- (CarLocation *)parseToCarLocation;

@end
