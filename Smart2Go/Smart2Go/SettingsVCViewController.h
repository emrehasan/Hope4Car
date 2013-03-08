//
//  SettingsVCViewController.h
//  Smart2Go
//
//  Created by Hasan Gürcan on 23.02.13.
//  Copyright (c) 2013 Hasan Gürcan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsVCViewController : UIViewController

@property (nonatomic, assign) BOOL supportC2G;
@property (nonatomic, assign) BOOL supportDriveNow;

@property (nonatomic, assign) IBOutlet UISwitch *car2GoSwitch;
@property (nonatomic, assign) IBOutlet UISwitch *driveNowSwitch;

@property (nonatomic, assign) IBOutlet UISwitch *fuelMinSwitch;

@property (nonatomic, assign) IBOutlet UISwitch *fuelMaxSwitch;



@property (nonatomic, assign) IBOutlet UISlider *radiusSlider;
@property (nonatomic, assign) IBOutlet UISlider *fuelMin;
@property (nonatomic, assign) IBOutlet UISlider *fuelMax;

@property (nonatomic, assign) IBOutlet UILabel *radiusLabel;
@property (nonatomic, assign) IBOutlet UILabel *fuelMinLabel;
@property (nonatomic, assign) IBOutlet UILabel *fuelMaxLabel;

- (IBAction)radiusValueChanged:(UISlider *)sender;
- (IBAction)fuelMinValueChanged:(UISlider *)sender;
- (IBAction)fuelMaxValueChanged:(UISlider *)sender;

- (IBAction)switchedFuelMin:(UISwitch *)sender;
- (IBAction)switchedFuelMax:(UISwitch *)sender;


@end
