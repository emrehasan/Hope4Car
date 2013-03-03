//
//  SettingsVCViewController.h
//  Smart2Go
//
//  Created by Hasan Gürcan on 23.02.13.
//  Copyright (c) 2013 Hasan Gürcan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsVCViewController : UITableViewController

@property (nonatomic, assign) BOOL supportC2G;
@property (nonatomic, assign) BOOL supportDriveNow;

@property (nonatomic, assign) IBOutlet UISlider *radiusSlider;
@property (nonatomic, assign) IBOutlet UISlider *fuelMin;
@property (nonatomic, assign) IBOutlet UISlider *fuelMax;

@property (nonatomic, assign) IBOutlet UILabel *radiusLabel;
@property (nonatomic, assign) IBOutlet UILabel *fuelMinLabel;
@property (nonatomic, assign) IBOutlet UILabel *fuelMaxLabel;


@end
