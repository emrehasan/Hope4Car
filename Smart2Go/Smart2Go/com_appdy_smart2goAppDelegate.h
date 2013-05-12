//
//  com_appdy_smart2goAppDelegate.h
//  Smart2Go
//
//  Created by Hasan Gürcan on 13.01.13.
//  Copyright (c) 2013 Hasan Gürcan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#define USERNAME_C2G_KEY    @"com.appdy.hope4car_username_c2g"
#define PASSWORD_C2G_KEY    @"com.appdy.hope4car_username_c2g"

#define USERNAME_DN_KEY     @"com.appdy.hope4car_username_dn"
#define PASSWORD_DN_KEY     @"com.appdy.hope4car_password_dn"

#define RADIUS_KEY          @"com.appdy.hope4car_radius"
#define FUEL_MIN_KEY        @"com.appdy.hope4car_fuel_min"
#define FUEL_MAX_KEY        @"com.appdy.hope4car_fuel_max"

#define SEARCH_C2G_KEY      @"com.appdy.hope4car_search_c2g"
#define SEARCH_DN_KEY       @"com.appdy.hope4car_search_dn"

#define LOAD_ALL_CARS       @"com.appdy.hope4car_load_all_cars"

@interface com_appdy_smart2goAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

//credentials c2g
@property (nonatomic, assign) NSString *usernameC2G;
@property (nonatomic, assign) NSString *passwordC2G;

//credentials dn
@property (nonatomic, assign) NSString *usernameDN;
@property (nonatomic, assign) NSString *passwordDN;

//settings
@property (nonatomic, retain) NSNumber *radius;
@property (nonatomic, retain) NSNumber *fuelMin;
@property (nonatomic, retain) NSNumber *fuelMax;

@property (nonatomic, assign) BOOL searchC2G;
@property (nonatomic, assign) BOOL searchDN;

@property (nonatomic, assign) NSString *locCity;
@property (nonatomic, assign) CLLocation *lastLoc;

//for background task
@property (nonatomic, assign) BOOL foundCar;

- (void)getUserDefaults;
- (void)setUserDefaults;


@end
