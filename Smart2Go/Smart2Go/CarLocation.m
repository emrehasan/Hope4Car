//
//  CarLocation.m
//  Smart2Go
//
//  Created by Hasan Gürcan on 15.01.13.
//  Copyright (c) 2013 Hasan Gürcan. All rights reserved.
//

#import "CarLocation.h"
#import <AddressBook/AddressBook.h>

@implementation CarLocation

- (id) initWithName: (NSString *)name address:(NSString *)address coordinate:(CLLocationCoordinate2D)coordinate {
    if(self = [super init]) {
        if([name isKindOfClass:[NSString class]])
            _name = name;
        else
            _name = @"B-GO-XXXX";
        
        _address = address;
        _coordinate = coordinate;
    }
    
    return self;
}

- (NSString *)title {
    return _name;
}

- (NSString *)subtitle {
    return _address;
}

- (MKMapItem *)mapItem {
    NSDictionary *addressDict = @{ (NSString *)kABPersonAddressStreetKey : _address};
    
    MKPlacemark *placemark = [[MKPlacemark alloc]
                              initWithCoordinate:_coordinate
                              addressDictionary:addressDict];
    
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    mapItem.name = _name;
    
    return mapItem;
}

@end
