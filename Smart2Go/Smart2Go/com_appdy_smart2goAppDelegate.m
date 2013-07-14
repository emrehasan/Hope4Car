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
#import "GAI.h"
#import "GAITracker.h"

@implementation com_appdy_smart2goAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //initialize google analytics
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    // Optional: set debug to YES for extra debugging information.
    [GAI sharedInstance].debug = YES;
    // Create tracker instance.
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-41219625-1"];

    
    // Override point for customization after application launch.
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], FIRST_LAUNCH_KEY,nil]];
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], SEARCH_C2G_KEY,nil]];
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], SEARCH_DN_KEY,nil]];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    
    //show network activity
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    _foundCar = YES;
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    //_foundCar = YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if(!_foundCar) {
        NSLog(@"In Searchmode");
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
                    
                    while(!_foundCar) {
                        NSLog(@"Timer Fired");
                        [timer fire];
                        sleep(10*2);
                    }
                    
                    [_locationManager stopUpdatingLocation];
                    
                    //End the task so the system knows that you are done with what you need to perform
                    [application endBackgroundTask: background_task];
                    
                    background_task = UIBackgroundTaskInvalid; //Invalidate the background_task
                });
            }
        }
    }
    
    else
        NSLog(@"Not searching");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    _foundCar = YES;
    //[[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
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

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"Called didUpdateLocations");
    _lastLoc = [locations objectAtIndex:0];
    [_locationManager stopUpdatingLocation];
}

- (void)loadAndCheckForCars {
    [_locationManager startUpdatingLocation];
    
    WSClient *wsClient = [[WSClient alloc] init];
    
    //wait for next turn if no location is available
    if(_lastLoc == nil) {
        NSLog(@"Waiting for location update");
        return;
    }
    
    //identify city if not available yet
    if(_locCity == nil && _lastLoc != nil)
        _locCity = [wsClient identifyCity:_lastLoc];
    
    NSMutableArray *freeCars = [[NSMutableArray alloc] initWithCapacity:2000];
        
    for(FreeCar *freeCar in [wsClient loadFreeCars:_locCity])
        [freeCars addObject:[freeCar parseToCarLocation]];
    
    for(CarLocation *carLoc in freeCars) {
        
        CLLocation *currCarLocation = [[CLLocation alloc] initWithCoordinate: carLoc.coordinate altitude:1 horizontalAccuracy:1 verticalAccuracy:-1 timestamp:nil];
        
        if([self isLocationInRadius:_lastLoc location2:currCarLocation radius:_radius]) {
            
            if(!_fuelMin)
                _fuelMin = [NSNumber numberWithInt:0];
            
            if(!_fuelMax)
                _fuelMax = [NSNumber numberWithInt:100];
                        
            if([carLoc.fuelState intValue] >= [_fuelMin intValue] &&
               [carLoc.fuelState intValue] <= [_fuelMax intValue]) {
                NSString *message = [NSString stringWithFormat:@"[%@%% Benzin]", carLoc.name ];
                [self notifyUser: message];
                _foundCar = YES;
                return;
            }
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

- (void)notifyUser:(NSString *)message {
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    [notification setAlertBody:[NSString stringWithFormat:@"%@:\t%@", NSLocalizedString(@"APP_DELEGATE_FOUND_CAR_TEXT", nil), message]];
    [notification setRepeatInterval:0];
    //[notification setApplicationIconBadgeNumber:1];
    [notification setSoundName:UILocalNotificationDefaultSoundName];
    
    UIApplication *app = [UIApplication sharedApplication];
    [app presentLocalNotificationNow:notification];
}

#pragma mark OWN_METHODS

- (void)getUserDefaults {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    //save if not done yet
    [prefs synchronize];
    
    _isFirstLaunch = [prefs boolForKey:FIRST_LAUNCH_KEY];
    _usernameC2G = [prefs stringForKey:USERNAME_C2G_KEY];
    _passwordC2G = [prefs stringForKey:PASSWORD_C2G_KEY];
    _usernameDN = [prefs stringForKey:USERNAME_DN_KEY];
    _passwordDN = [prefs stringForKey:PASSWORD_DN_KEY];
    _radius = [prefs objectForKey:RADIUS_KEY];
    _fuelMin = [prefs objectForKey:FUEL_MIN_KEY];
    _fuelMax = [prefs objectForKey:FUEL_MAX_KEY];
    _searchC2G = [prefs boolForKey:SEARCH_C2G_KEY];
    _searchDN = [prefs boolForKey:SEARCH_DN_KEY];
    
    if(_radius == nil)
        _radius = [NSNumber numberWithInt:500];
    if(_fuelMin == nil)
        _fuelMin = [NSNumber numberWithInt:0];
    if(_fuelMax == nil)
        _fuelMax = [NSNumber numberWithInt:100];
}

- (void)setUserDefaults {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [prefs setBool:_isFirstLaunch forKey:FIRST_LAUNCH_KEY];
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

#pragma mark - Core Data stack

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CoreDataProject.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
