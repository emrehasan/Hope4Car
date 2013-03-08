//
//  SettingsVCViewController.m
//  Smart2Go
//
//  Created by Hasan Gürcan on 23.02.13.
//  Copyright (c) 2013 Hasan Gürcan. All rights reserved.
//

#import "SettingsVCViewController.h"

@interface SettingsVCViewController ()

@end

@implementation SettingsVCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _radiusLabel.text = @"";
    _fuelMinLabel.text = @"";
    _fuelMaxLabel.text = @"";
    
    if (!_fuelMinSwitch.on)
        _fuelMin.userInteractionEnabled = NO;
    
    if (!_fuelMaxSwitch.on)
        _fuelMax.userInteractionEnabled = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)radiusValueChanged:(UISlider *)sender {
    _radiusLabel.text = [NSString stringWithFormat:@"%.0f", [sender value]];
}

- (IBAction)fuelMinValueChanged:(UISlider *)sender {
    _fuelMinLabel.text = [NSString stringWithFormat:@"%.0f %%", [sender value]];
}

- (IBAction)fuelMaxValueChanged:(UISlider *)sender {
    _fuelMaxLabel.text = [NSString stringWithFormat:@"%.0f %%", [sender value]];
}

- (IBAction)switchedFuelMin:(UISwitch *)sender {
    if(sender.on)
        _fuelMin.userInteractionEnabled = YES;
    else
        _fuelMin.userInteractionEnabled = NO;
}

- (IBAction)switchedFuelMax:(UISwitch *)sender {
    if(sender.on)
        _fuelMax.userInteractionEnabled = YES;
    else
        _fuelMax.userInteractionEnabled = NO;
}


@end
