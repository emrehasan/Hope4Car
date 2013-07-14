//
//  CostViewController.h
//  Smart2Go
//
//  Created by Hasan Gürcan on 23.06.13.
//  Copyright (c) 2013 Hasan Gürcan. All rights reserved.
//

#define DN_DRIVE_COSTS          0.31
#define DN_DRIVE_COSTS_SPECIAL  0.34
#define DN_PARK_COSTS           0.10

#define C2G_DRIVE_COSTS         0.29
#define C2G_PARK_COSTS          0.19

#define CHOOSE_COMPANY          100
#define CHOOSE_DN_CAR           101
#define CHOOSE_STATE            102

#define DRIVING_STATE           200
#define PARKING_STATE           201

#import <UIKit/UIKit.h>
#import "com_appdy_smart2goAppDelegate.h"
#import "MBProgressHUD.h"

@interface CostViewController : UIViewController<UIActionSheetDelegate, UIAlertViewDelegate, MBProgressHUDDelegate> {
    int current_mode;
    int current_state;
}

@property(atomic, assign) com_appdy_smart2goAppDelegate *delegate;

/**
 *  This is the price we will calculate with the
 *  costs. It depends on the selection of the user.
 */
@property(atomic, retain) NSNumber *calcPrice;

/**
 *  This is the price we will calculate the park costs.
 *  It depends on the selection of the user.
 */
@property(atomic, retain) NSNumber *parkPrice;

/**
 *  Saves the current price 
 */
@property(atomic, retain) NSNumber *currentPrice;

/**
 *  Timer object that fires every minute to calculate the price.
 */
@property(atomic, assign) NSTimer *timer;

/**
 *  This is the label we will show the current price
 */
@property IBOutlet UILabel *costLabel;


/**
 *  Button that will start and end the calculation
 */
@property IBOutlet UIButton *calcButton;

/**
 *  Button for calculation was clicked.
 *  We will filter with actionsheets what kind of car 
 *  will be driven to set the correct calculation prices
 */
- (IBAction)startCalculationClicked:(id)sender;

/**
 *  Will end all calculations and should add the calculation
 *  with the value to the database
 */
- (IBAction)stopCalculationClicked:(id)sender;

/**
 *  Activates the parking mode so the parking costs can be calculated
 */
- (IBAction)activateParkingMode:(id)sender;

/**
 *  Deactivates the parking mode so the driving costs can be calculated
 */
- (IBAction)deactivateParkingMode:(id)sender;

- (void)startCalculation;

@end
