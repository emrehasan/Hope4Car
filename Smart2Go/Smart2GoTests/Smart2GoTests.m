//
//  Smart2GoTests.m
//  Smart2GoTests
//
//  Created by Hasan Gürcan on 13.01.13.
//  Copyright (c) 2013 Hasan Gürcan. All rights reserved.
//

#import "Smart2GoTests.h"
#import "WSClient.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@implementation Smart2GoTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testWSClientIdentifyCity
{
    
    WSClient *wsClient = [[WSClient alloc] init];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:52.5061443443 longitude:13.41149556666];
    
    NSString *identifiedCity = [wsClient identifyCity:location];
    STAssertNotNil(identifiedCity, @"City should not be nil");
    STAssertTrue( [identifiedCity isEqualToString:@"Berlin"] , @"Should be Berlin");
}

@end
