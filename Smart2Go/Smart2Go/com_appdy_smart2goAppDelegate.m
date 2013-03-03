//
//  com_appdy_smart2goAppDelegate.m
//  Smart2Go
//
//  Created by Hasan Gürcan on 13.01.13.
//  Copyright (c) 2013 Hasan Gürcan. All rights reserved.
//

#import "com_appdy_smart2goAppDelegate.h"
#import "DemoMenuController.h"
#import "com_appdy_smart2goViewController.h"
#import "SettingsVCViewController.h"

@implementation com_appdy_smart2goAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _menuController = [[DemoMenuController alloc] initWithMenuWidth:250.0 numberOfFolds:3];
    [_menuController setDelegate:self];
    [self.window setRootViewController:_menuController];
    
    NSMutableArray *viewControllers = [NSMutableArray array];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
                                                             bundle: nil];
    UINavigationController *rootNavController;// = [mainStoryboard instantiateViewControllerWithIdentifier:@"MainNavController"];
    
    for (int i=0; i<2; i++)
    {
        if(i == 0) {
            com_appdy_smart2goViewController *rootViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"Hope4CarVC"];
            [rootViewController setTitle:[NSString stringWithFormat:@"Hope4Car"]];
            
            rootNavController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
            [viewControllers addObject:rootNavController];
        }
        
        else if(i == 1) {
            SettingsVCViewController *rootViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"SettingsVC"];
            [rootViewController setTitle:[NSString stringWithFormat:@"Settings"]];
            
            rootNavController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
            [viewControllers addObject:rootNavController];
        }
        
        else {
            //DO NOTHING
        }
    }
    [viewControllers addObject:rootNavController];

    
    
    [_menuController setViewControllers:viewControllers];
    // Override point for customization after application launch.
    return YES;
}

- (void)paperFoldMenuController:(PaperFoldMenuController *)paperFoldMenuController didSelectViewController:(UIViewController *)viewController
{
    
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
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

@end
