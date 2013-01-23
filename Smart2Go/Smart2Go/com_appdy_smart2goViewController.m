//
//  com_appdy_smart2goViewController.m
//  Smart2Go
//
//  Created by Hasan Gürcan on 13.01.13.
//  Copyright (c) 2013 Hasan Gürcan. All rights reserved.
//

#import "com_appdy_smart2goViewController.h"
#import "CarLocation.h"
#import "FreeCar.h"
#import "WSClient.h"

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
    
    //add toolbarbutton
    UIBarButtonItem *updateButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(updateCarsWithLoadingHUD)];
    
    self.toolbarItems = @[updateButton];
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
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 500, 500);
    [_mapView setRegion:viewRegion animated:YES];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    _oldLocation = _currentLocation;
    _currentLocation = [locations objectAtIndex:0];
    
    if(_currentLocation != nil) {
        [self initialCallsAfterStart];
    }
    
    [_locationManager stopUpdatingLocation];
    [self zoomToCurrLocation];
}

- (void)initialCallsAfterStart {
    //identify current city
    //[self identifyCityWithLoadingHUD];
    //NSLog(@"Identified city:\t%@", _currentCity);
    //->isDone by loadingCars it will check before
    
    //retrieve cars here
    [self updateCarsWithLoadingHUD];
    
    NSLog(@"Loaded [%d] freeCars", [_freeCars count]);
}

- (void)identifyCityWithLoadingHUD {
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    hud.labelText = @"Identifying city";
    
    [hud showAnimated:YES whileExecutingBlock:^{
        [self identifyCity];
    } completionBlock:^{
        [hud removeFromSuperview];
    }];
}

- (void)updateCarsWithLoadingHUD {
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    hud.labelText = @"Loading Free Cars";
    
    [hud showAnimated:YES whileExecutingBlock:^{
        
        if(_currentCity == nil)
           [self identifyCity];
        
        [self updateCars];
    } completionBlock:^{
        [hud removeFromSuperview];
    }];
}

- (BOOL) updateCars {
    WSClient *wsClient = [[WSClient alloc] init];
    
    //reset freeCars
    _freeCars = [[NSMutableArray alloc] initWithCapacity:100];
    
    for(FreeCar *freeCar in [wsClient loadFreeCars:_currentCity]) {
        [_freeCars addObject:[freeCar parseToCarLocation]];
    }
    
    NSLog(@"FreeCars counted:\t%d", [_freeCars count]);
    
    [self addCarsToMap];
    
    return YES;
}

- (BOOL) identifyCity {
    WSClient *wsClient = [[WSClient alloc] init];
    _currentCity = [wsClient identifyCity:_currentLocation];
    return YES;
}

- (BOOL) updateLocation {
    [_locationManager startUpdatingLocation];
    return YES;
}

- (void)addCarsToMap {
    for(CarLocation *carLoc in _freeCars)
        [_mapView addAnnotation:carLoc];
    [self zoomToCurrLocation];
}

- (void)resetCarsFromMap {
    [_mapView removeAnnotations:[_mapView annotations]];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    //NSLog(@"Called this");
    
    if([annotation isKindOfClass:[CarLocation class]]){
        MKAnnotationView *annotationView = (MKAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:@"myidentifier"];
        if(annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myidentifier"];
            annotationView.enabled = YES;
            annotationView.canShowCallout = YES;
            annotationView.image = [UIImage imageNamed:@"c2g_logo.jpeg"];
        }
        
        else
            annotationView.annotation = annotation;
        
        return annotationView;
    }
    
    return nil;
}

@end
