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

@interface com_appdy_smart2goViewController : UIViewController<CLLocationManagerDelegate, MKMapViewDelegate>

@property(nonatomic, retain) IBOutlet MKMapView *mapView;

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation *currentLocation;
@property (nonatomic, retain) CLLocation *oldLocation;

@end
