//
//  com_appdy_smart2goViewController.m
//  Smart2Go
//
//  Created by Hasan Gürcan on 13.01.13.
//  Copyright (c) 2013 Hasan Gürcan. All rights reserved.
//

#import "com_appdy_smart2goViewController.h"

@interface com_appdy_smart2goViewController ()

@end

@implementation com_appdy_smart2goViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //start location manager
    if(_locationManager == nil) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        _locationManager.delegate = self;
    }
    
    [_locationManager startUpdatingLocation];
}

//set current location and display cars in the near
- (void) viewWillAppear:(BOOL)animated {
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark DELEGATE LOCATION_MANAGER METHODS

- (void)startUpdatingLocation {
    [_locationManager startUpdatingLocation];
}

- (void)zoomToCurrLocation {
    /*NSString *latitudeStr = [[NSNumber numberWithDouble:_currentLocation.coordinate.latitude] stringValue];
    NSString *longitudeStr = [[NSNumber numberWithDouble:_currentLocation.coordinate.longitude] stringValue];*/
    
    NSNumber *latitude = [NSNumber numberWithDouble:_currentLocation.coordinate.latitude];
    NSNumber *longitude = [NSNumber numberWithDouble:_currentLocation.coordinate.longitude];
    
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = [latitude doubleValue];
    zoomLocation.longitude = [longitude doubleValue];
    
    //NSLog(@"Latitude:\t%@\nLongitude:\t%@", latitudeStr, longitudeStr);
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 10, 10);
    [_mapView setRegion:viewRegion animated:YES];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    _oldLocation = _currentLocation;
    _currentLocation = [locations objectAtIndex:0];
    
    [_locationManager stopUpdatingLocation];
    [self zoomToCurrLocation];
}

@end
