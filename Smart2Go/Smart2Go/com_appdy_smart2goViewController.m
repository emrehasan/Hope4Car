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
    
    self.trackedViewName = @"MapView";
    
    //set delegate
    _delegate = [[UIApplication sharedApplication] delegate];
    [_delegate getUserDefaults];
    
    _delegate.fuelMin = [NSNumber numberWithInt:0];
    [_delegate setUserDefaults];
    
    isInitialLoad = YES;
    
    //start location manager
    if(_locationManager == nil) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        _locationManager.delegate = self;
    }
    
    //ios does the checking if serviceEnabled for location itself and prompt it to the user for reenabling if deactivated :)
    
    [self startUpdatingLocation];
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"Called VWA-RootView");
    [_delegate getUserDefaults];
    
    //set necessary settings
    //set radius per default to 500 meters
    _radius = _delegate.radius;
    if(_radius == nil)
        _radius = [NSNumber numberWithInt:500];
    else
        NSLog(@"Set radius to %d m", [_radius intValue]);    
}

- (void)viewDidAppear:(BOOL)animated {
    //add updatebutton
    UIBarButtonItem *updateButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(startUpdatingLocation)];
    
    UINavigationController *navController = (UINavigationController *)self.parentViewController;
    navController.navigationItem.rightBarButtonItem = updateButton;
}

- (void) viewWillDisappear:(BOOL)animated {
    UINavigationController *navController = (UINavigationController *)self.parentViewController;
    navController.navigationItem.rightBarButtonItem = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark DELEGATE LOCATION_MANAGER METHODS

- (void)startUpdatingLocation {
    
    UINavigationController *navController = (UINavigationController *)self.parentViewController;
    [navController.navigationItem setPrompt:NSLocalizedString(@"MAP_VIEW_ALERT_LOADING_FREE_CARS", nil)];
    
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityView.hidesWhenStopped = YES;
    [activityView startAnimating];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:activityView];
    
    navController.navigationItem.leftBarButtonItem = barButton;
    
    [_locationManager startUpdatingLocation];
}

- (void)zoomToCurrLocation {
    //remove old overlay
    [_mapView removeOverlays:[_mapView overlays]];
    
    NSNumber *latitude = [NSNumber numberWithDouble:_currentLocation.coordinate.latitude];
    NSNumber *longitude = [NSNumber numberWithDouble:_currentLocation.coordinate.longitude];
    
    CLLocationCoordinate2D zoomLocation = CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue]);
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 800, 800);
    [_mapView setRegion:viewRegion animated:YES];
    
    //draw circle with radius
    if(_currentLocation != nil) {
        MKCircle *circle = [MKCircle circleWithCenterCoordinate:_currentLocation.coordinate radius:[_radius doubleValue]];
        [_mapView addOverlay:circle];
        //[_mapView addOverlay:circle level:MKOverlayLevelAboveRoads];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [_locationManager stopUpdatingLocation];
    
    _oldLocation = _currentLocation;
    _currentLocation = nil;
    _currentLocation = [locations objectAtIndex:0];
    
    if(_currentLocation != nil) {
        [self initialCallsAfterStart];
    }
    
    [_locationManager stopUpdatingLocation];
    //[self zoomToCurrLocation];
    
    if(isInitialLoad) {
        isInitialLoad = NO;
    }
    
    //set location to appdelegate
    _delegate.lastLoc = _currentLocation;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Updated Location with error:\t%@", [error description]);
}

- (void)initialCallsAfterStart {
    
    //identify city if not done yet
    //if(_currentCity == nil)
       [self identifyCity];
    
    //retrieve cars here
    [self updateCarsWithLoadingHUD];
    
    NSLog(@"Loaded [%d] freeCars", [_freeCars count]);
}

- (void)identifyCityWithLoadingHUD {
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    hud.labelText = NSLocalizedString(@"MAP_VIEW_ALERT_IDENTIFYING_CITY", nil);
    
    [hud showAnimated:YES whileExecutingBlock:^{
        [self identifyCity];
    } completionBlock:^{
        [hud removeFromSuperview];
    }];
}

- (void)updateCarsWithoutHUD {
    NSLog(@"Updating Cars");
    if(_currentCity == nil)
       [self identifyCity];
    
    [self updateCars];
}

- (void)updateCarsWithLoadingHUD {
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self updateCars];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            UINavigationController *navController = (UINavigationController *)self.parentViewController;
            [navController.navigationItem setPrompt:nil];
            [navController.navigationItem setLeftBarButtonItem:nil];
            
            UIBarButtonItem *updateButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(startUpdatingLocation)];
            [navController.navigationItem setRightBarButtonItem:updateButton];
            
            [self zoomToCurrLocation];
        });
    });
   
}

- (BOOL) updateCars {
    WSClient *wsClient = [[WSClient alloc] init];
    
    //reset freeCars
    for(int i = 0; i < [_freeCars count]; i++) {
        FreeCar *buff = [_freeCars objectAtIndex:i];
        [_mapView removeAnnotations:_freeCars];
        buff = nil;
    }
    
    _freeCars = nil;
    _freeCars = [[NSMutableArray alloc] initWithCapacity:100];
    
    for(FreeCar *freeCar in [wsClient loadFreeCars:_currentCity])
        [_freeCars addObject:[freeCar parseToCarLocation]];
    
    NSLog(@"FreeCars counted:\t%d", [_freeCars count]);
    
    [self addCarsToMap];
    return YES;
}

- (BOOL) identifyCity {
    WSClient *wsClient = [[WSClient alloc] init];
    _currentCity = [wsClient identifyCity:_currentLocation];
    
    _delegate.locCity = _currentCity;
    
    return YES;
}

- (BOOL) updateLocation {
    [_locationManager startUpdatingLocation];
    return YES;
}

- (void)addCarsToMap {
    [_delegate getUserDefaults];
    [self zoomToCurrLocation];
    
    NSMutableArray *copyFreeCars;
    @synchronized(_freeCars) {
        copyFreeCars = [[NSMutableArray alloc] initWithArray:_freeCars];
    }
    
    for(CarLocation *carLoc in copyFreeCars) {

        CLLocation *currCarLocation = [[CLLocation alloc] initWithCoordinate: carLoc.coordinate altitude:1 horizontalAccuracy:1 verticalAccuracy:-1 timestamp:nil];
        
        if([self isLocationInRadius:_currentLocation location2:currCarLocation radius:_radius]) {
            
            if(!_delegate.fuelMin)
                _delegate.fuelMin = [NSNumber numberWithInt:0];
            
            if(!_delegate.fuelMax)
                _delegate.fuelMax = [NSNumber numberWithInt:100];
            
            //NSLog(@"FuelMin:\t%d", [_delegate.fuelMin intValue]);
            //NSLog(@"FuelMax:\t%d", [_delegate.fuelMax intValue]);
            
            if([carLoc.fuelState intValue] >= [_delegate.fuelMin intValue]
               && [carLoc.fuelState intValue] <= [_delegate.fuelMax intValue])
                [_mapView addAnnotation:carLoc];
            
        }
    }
    copyFreeCars = nil;
    //[_mapView reloadInputViews];
}

- (void)resetCarsFromMap {
    NSArray *oldAnnotations = [_mapView annotations];
    [_mapView removeAnnotations:oldAnnotations];
    
    for(int i = 0; i < [oldAnnotations count]; i++) {
        CarLocation *carLoc = [oldAnnotations objectAtIndex:i];
        carLoc = nil;
    }
    
    oldAnnotations = nil;
}

/**
 *  Calculates the distance between two coordinates and checks if the distance is
 *  smaller-equals to a certain radius
 *  <p>
 *  @param location1 - {@link CLLocation} first distance which is used for the calculation
 *  @param location2 - {@link CLLocation} second distance which is used for the calculation
 *  @param radius - {@link NSInteger} the radius the
 */
- (BOOL) isLocationInRadius:(CLLocation *)location1 location2:(CLLocation *) location2 radius:(NSNumber *)radius {
    CLLocationDistance distance = [location1 distanceFromLocation:location2];
    if(distance <= [radius intValue])
        return YES;
    else
        return NO;
}

/**
 *  Calculates a distance and returns it as string
 *  <p>
 *  @param location1 - {@link CLLocation} first distance which is used for the calculation
 *  @param location2 - {@link CLLocation} second distance which is used for the calculation
 *  <p>
 *  @return calculated distance as string
 *
 */
- (NSString *) getDistanceAsString:(CLLocation *)location1 location2:(CLLocation *) location2 {
    CLLocationDistance distance = [location1 distanceFromLocation:location2];
    NSString *retValue = [NSString stringWithFormat:@"%.2f", distance ];
    return retValue;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    MKCircleView *circleView = [[MKCircleView alloc] initWithCircle:overlay];
    circleView.fillColor = [UIColor blueColor];
    circleView.alpha = 0.2;
    
    return circleView;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if([annotation isKindOfClass:[CarLocation class]]){
        CarLocation *buffCarLoc = annotation;
        MKAnnotationView *annotationView = (MKAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:@"myidentifier"];
        if(annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myidentifier"];
            annotationView.enabled = YES;
            annotationView.canShowCallout = YES;
            
            if(buffCarLoc.isC2G)
                annotationView.image = [UIImage imageNamed:@"c2gFlag.png"];
            else
                annotationView.image = [UIImage imageNamed:@"dnFlag.png"];
        }
        
        else
            annotationView.annotation = annotation;
        
        // Add to mapView:viewForAnnotation: after setting the image on the annotation view
        //annotationView.canShowCallout = YES;
        //annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        return annotationView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    for (MKAnnotationView *annView in views)
    {
        CGRect endFrame = annView.frame;
        annView.frame = CGRectOffset(endFrame, 0, -500);
        [UIView animateWithDuration:1.5
                         animations:^{ annView.frame = endFrame; }];
    }
}

/*
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    NSLog(@"Tapped");
    CarLocation *location = (CarLocation*)view.annotation;
    
    UIAlertView *testAlert = [[UIAlertView alloc] initWithTitle:@"We will reserver" message:@"RESERVe?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    [testAlert show];

}*/


@end
