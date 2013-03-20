//
//  com_appdy_smart2goViewController.h
//  Smart2Go
//
//  Created by Hasan Gürcan on 13.01.13.
//  Copyright (c) 2013 Hasan Gürcan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MBProgressHUD.h"
#import "com_appdy_smart2goAppDelegate.h"

@interface com_appdy_smart2goViewController : UIViewController<CLLocationManagerDelegate, MKMapViewDelegate, MBProgressHUDDelegate> {
    BOOL isInitialLoad;
}

@property (atomic, assign) com_appdy_smart2goAppDelegate *delegate;

@property(nonatomic, retain) IBOutlet MKMapView *mapView;

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation *currentLocation;
@property (nonatomic, retain) CLLocation *oldLocation;

@property (nonatomic, copy) NSString *currentCity;
@property (atomic, retain) NSMutableArray *freeCars;

@property (nonatomic, retain) NSTimer *timer;

@property (nonatomic, retain) NSNumber *radius;

@end
