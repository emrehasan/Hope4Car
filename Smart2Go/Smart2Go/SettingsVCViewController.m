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
}

- (void)viewWillAppear:(BOOL)animated {
    //set delegate
    _delegate = [[UIApplication sharedApplication] delegate];
    [_delegate getUserDefaults];
    
    if(_delegate.radius == nil) {
        _radiusLabel.text = @"500 m";
        [_radiusSlider setValue:500.0f];
    }
    else {
        [_radiusLabel setText:[NSString stringWithFormat:@"%d m", [_delegate.radius intValue]]];
        [_radiusSlider setValue:(float)[_delegate.radius intValue]];
    }
    
    _fuelMinLabel.text = @"";
    
    if (!_fuelMinSwitch.on)
        _fuelMin.userInteractionEnabled = NO;
    
    if(_delegate.searchC2G)
        [_car2GoSwitch setOn:YES animated:YES];
    else
        [_car2GoSwitch setOn:NO animated:NO];
    
    if(_delegate.searchDN)
        [_driveNowSwitch setOn:YES animated:YES];
    else
        [_driveNowSwitch setOn:NO animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    //add toolbarbutton
    UIButton* infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
	[infoButton addTarget:self action:@selector(showHelp) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *modalButton = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
       
    UINavigationController *navController = (UINavigationController *)self.parentViewController;
    navController.navigationItem.rightBarButtonItem = modalButton;
}

- (void)showHelp {
    RNBlurModalView *modal = [[RNBlurModalView alloc] initWithViewController:self title:@"How to use it?" message:@"1. Set the radius for retrieve cars in your near.\n\n 2. Set fuel min if you need a car with a minimum fuel stand because you're planning to drive a long way.\n\n 3. Set fuel max if you want to find cars that you can refuel and use it afterwards costless."];
    [modal show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)radiusValueChanged:(UISlider *)sender {
    _radiusLabel.text = [NSString stringWithFormat:@"%.0f m", [sender value]];
    _delegate.radius = [NSNumber numberWithInt:(int)[sender value]];
    
    //save
    [_delegate setUserDefaults];
}

- (IBAction)fuelMinValueChanged:(UISlider *)sender {
    _fuelMinLabel.text = [NSString stringWithFormat:@"%.0f %%", [sender value]];
    _delegate.fuelMin = [NSNumber numberWithInt:(int)[sender value]];
    
    //save
    [_delegate setUserDefaults];
}

/*- (IBAction)fuelMaxValueChanged:(UISlider *)sender {
    _fuelMaxLabel.text = [NSString stringWithFormat:@"%.0f %%", [sender value]];
}*/

- (IBAction)switchedSearchC2G:(UISwitch *)sender {
    if(_car2GoSwitch.on)
        _delegate.searchC2G = YES;
    else
        _delegate.searchC2G = NO;
    
    //save
    [_delegate setUserDefaults];
}

- (IBAction)switchedSearchDN:(UISwitch *)sender {
    if(_driveNowSwitch.on)
        _delegate.searchDN = YES;
    else
        _delegate.searchDN = NO;
    
    //save
    [_delegate setUserDefaults];
}


- (IBAction)switchedFuelMin:(UISwitch *)sender {
    if(_fuelMinSwitch.on)
        _fuelMin.userInteractionEnabled = YES;
    else
        _fuelMin.userInteractionEnabled = NO;
}


@end
