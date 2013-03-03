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
    
    UISlider *slider = [[UISlider alloc] init];
    [slider setMaximumValue:20.0f];
    [slider setMinimumValue:0.0f];
    UIBarButtonItem *sliderView = [[UIBarButtonItem alloc] initWithCustomView:slider];
    [sliderView setWidth:200.0];

    
    self.toolbarItems = @[updateButton, sliderView];
    
    //set time
    _timer = [NSTimer scheduledTimerWithTimeInterval:30.0
                                              target:self
                                            selector:@selector(updateCarsWithLoadingHUD)
                                            userInfo:nil
                                             repeats:YES];
    NSLog(@"Called this one VDA");
    
    //set necessary settings
    //set radius per default to 1000 meters
    if(_radius == nil)
        _radius = [NSNumber numberWithInt:1000];
}

//set current location and display cars in the near
- (void) viewWillAppear:(BOOL)animated {
    
    NSLog(@"Called this one VWA");
    //set the timer
    if(_timer == nil) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:10.0
                                                  target:self
                                                selector:@selector(updateCarsWithoutHUD)
                                                userInfo:nil
                                                 repeats:YES];
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [_timer invalidate];
    _timer = nil;
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
    
    NSNumber *latitude = [NSNumber numberWithDouble:_currentLocation.coordinate.latitude];
    NSNumber *longitude = [NSNumber numberWithDouble:_currentLocation.coordinate.longitude];
    
    CLLocationCoordinate2D zoomLocation = CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue]);
    
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

- (void)updateCarsWithoutHUD {
    NSLog(@"Updating Cars");
    if(_currentCity == nil)
       [self identifyCity];
    
    [self updateCars];
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
    for(int i = 0; i < [_freeCars count]; i++) {
        FreeCar *buff = [_freeCars objectAtIndex:i];
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
    return YES;
}

- (BOOL) updateLocation {
    [_locationManager startUpdatingLocation];
    return YES;
}

- (void)addCarsToMap {
    for(CarLocation *carLoc in _freeCars) {

        CLLocation *currCarLocation = [[CLLocation alloc] initWithCoordinate: carLoc.coordinate altitude:1 horizontalAccuracy:1 verticalAccuracy:-1 timestamp:nil];
        
        if([self isLocationInRadius:_currentLocation location2:currCarLocation radius:_radius])
            [_mapView addAnnotation:carLoc];
    }
    
    _freeCars = nil;

    [self zoomToCurrLocation];
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
    //TODO add this to all labels of MKAnnotations
    return nil;
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
