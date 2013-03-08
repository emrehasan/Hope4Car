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

@property (nonatomic, assign) BOOL isCar2Go;

@property (nonatomic, copy) NSString *carName;
@property (nonatomic, copy) NSString *engineType;
@property (nonatomic, copy) NSString *exterior;
@property (nonatomic, copy) NSString *interior;
@property (nonatomic, copy) NSString *vin;
@property (nonatomic, copy) NSString *address;

@property (nonatomic, retain) NSNumber *carID;
@property (nonatomic, retain) NSNumber *lastRefresh;
@property (nonatomic, retain) NSNumber *fuel;
@property (nonatomic, retain) NSNumber *distanceTo;
@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSNumber *longitude;

- (CarLocation *)parseToCarLocation;

@end
