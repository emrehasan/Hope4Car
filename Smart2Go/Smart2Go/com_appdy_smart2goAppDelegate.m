//
//  com_appdy_smart2goAppDelegate.m
//  Smart2Go
//
//  Created by Hasan Gürcan on 13.01.13.
//  Copyright (c) 2013 Hasan Gürcan. All rights reserved.
//

#import "com_appdy_smart2goAppDelegate.h"
#import "WSClient.h"
#import "FreeCar.h"
#import "CarLocation.h"

@implementation com_appdy_smart2goAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    //show network activity
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    //Check if our iOS version supports multitasking I.E iOS 4
    if ([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)]) {
        
        //Check if device supports mulitasking
        if ([[UIDevice currentDevice] isMultitaskingSupported]) {
            
            //Get the shared application instance
            UIApplication *application = [UIApplication sharedApplication];
            
            //Create a task object
            __block UIBackgroundTaskIdentifier background_task;
            background_task = [application beginBackgroundTaskWithExpirationHandler: ^ {
                
                //Tell the system that we are done with the tasks
                [application endBackgroundTask: background_task];
                
                //Set the task to be invalid
                background_task = UIBackgroundTaskInvalid;
                
                //System will be shutting down the app at any point in time now
            }];
            //Background tasks require you to use asynchronous tasks
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                //Perform your tasks that your application requires
                NSLog(@"\n\nRunning in the background!\n\n");
                
                NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(loadAndCheckForCars) userInfo:nil repeats:YES];
                
                while(true) {
                    [timer fire];
                    sleep(60);
                }
                
                //End the task so the system knows that you are done with what you need to perform
                [application endBackgroundTask: background_task];
                
                background_task = UIBackgroundTaskInvalid; //Invalidate the background_task
            });
        }
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)loadAndCheckForCars {
    WSClient *wsClient = [[WSClient alloc] init];
    
    NSMutableArray *freeCars = [[NSMutableArray alloc] initWithCapacity:500];
        
    for(FreeCar *freeCar in [wsClient loadFreeCars:_locCity])
        [freeCars addObject:[freeCar parseToCarLocation]];
    
    for(CarLocation *carLoc in freeCars) {
        
        CLLocation *currCarLocation = [[CLLocation alloc] initWithCoordinate: carLoc.coordinate altitude:1 horizontalAccuracy:1 verticalAccuracy:-1 timestamp:nil];
        
        if([self isLocationInRadius:_lastLoc location2:currCarLocation radius:_radius]) {
            
            if(!_fuelMin)
                _fuelMin = [NSNumber numberWithInt:0];
            
            NSLog(@"FuelMin:\t%d", [_fuelMin intValue]);
            
            if([carLoc.fuelState intValue] >= [_fuelMin intValue])
                [self notifyUser];
        }
    }
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

- (void)notifyUser {
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    [notification setAlertBody:@"Auto in ihrer Nähe gefunden"];
    [notification setRepeatInterval:0];
    
    UIApplication *app = [UIApplication sharedApplication];
    [app presentLocalNotificationNow:notification];
}

#pragma mark OWN_METHODS

- (void)getUserDefaults {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    //save if not done yet
    [prefs synchronize];
    
    _usernameC2G = [prefs stringForKey:USERNAME_C2G_KEY];
    _passwordC2G = [prefs stringForKey:PASSWORD_C2G_KEY];
    _usernameDN = [prefs stringForKey:USERNAME_DN_KEY];
    _passwordDN = [prefs stringForKey:PASSWORD_DN_KEY];
    _radius = [prefs objectForKey:RADIUS_KEY];
    _fuelMin = [prefs objectForKey:FUEL_MIN_KEY];
    _fuelMax = [prefs objectForKey:FUEL_MAX_KEY];
    _searchC2G = [prefs boolForKey:SEARCH_C2G_KEY];
    _searchDN = [prefs boolForKey:SEARCH_DN_KEY];
}

- (void)setUserDefaults {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [prefs setObject:_usernameC2G forKey:USERNAME_C2G_KEY];
    [prefs setObject:_passwordC2G forKey:PASSWORD_C2G_KEY];
    [prefs setObject:_usernameDN forKey:USERNAME_DN_KEY];
    [prefs setObject:_passwordDN forKey:PASSWORD_DN_KEY];
    [prefs setObject:_radius forKey:RADIUS_KEY];
    [prefs setObject:_fuelMin forKey:FUEL_MIN_KEY];
    [prefs setObject:_fuelMax forKey:FUEL_MAX_KEY];
    [prefs setBool:_searchC2G forKey:SEARCH_C2G_KEY];
    [prefs setBool:_searchDN forKey:SEARCH_DN_KEY];
    
    //save now
    [prefs synchronize];
}

@end
