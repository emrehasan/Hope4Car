//
//  com_appdy_smart2goAppDelegate.h
//  Smart2Go
//
//  Created by Hasan Gürcan on 13.01.13.
//  Copyright (c) 2013 Hasan Gürcan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface com_appdy_smart2goAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

//credentials c2g
@property (nonatomic, assign) NSString *usernameC2G;
@property (nonatomic, assign) NSString *passwordC2G;

//credentials dn
@property (nonatomic, assign) NSString *usernameDN;
@property (nonatomic, assign) NSString *passwordDN;

- (void)getUserDefaults;
- (void)setUserDefaults;


@end
