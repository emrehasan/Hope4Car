//
//  CostViewController.m
//  Smart2Go
//
//  Created by Hasan Gürcan on 23.06.13.
//  Copyright (c) 2013 Hasan Gürcan. All rights reserved.
//

#import "CostViewController.h"

@interface CostViewController ()

@end

@implementation CostViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startCalculationClicked:(id)sender {
    
    //if calculation is running then stop it with this
    if(_timer != nil && [_timer isValid]) {
        [self selectState];
        return;
    }
    
    current_mode = CHOOSE_COMPANY;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                        initWithTitle:NSLocalizedString(@"COST_CONTROLLER_ACTIONSHEET_COMPANY_TITLE", nil)
                        delegate:self
                        cancelButtonTitle:NSLocalizedString(@"COST_CONTROLLER_ACTIONSHEET_ABORT", nil)
                        destructiveButtonTitle:nil
                        otherButtonTitles:@"Car2Go", @"DriveNow" , nil];
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

/**
 *  Will end all calculations and should add the calculation
 *  with the value to the database
 */
- (IBAction)stopCalculationClicked:(id)sender {
    [self stopCalculation];
}

/**
 *  Activates the parking mode so the parking costs can be calculated
 */
- (IBAction)activateParkingMode:(id)sender {
    current_state = PARKING_STATE;
}

/**
 *  Deactivates the parking mode so the driving costs can be calculated
 */
- (IBAction)deactivateParkingMode:(id)sender {
    current_state = DRIVING_STATE;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"In Action-Delegate");
    //company was choosen 
    if(current_mode == CHOOSE_COMPANY){
        
        //Car2Go chosen so dont do anything start calculation
        if(buttonIndex == 0) {
            _calcPrice = [NSNumber numberWithDouble: (double) C2G_DRIVE_COSTS];
            _parkPrice = [NSNumber numberWithDouble: (double) C2G_PARK_COSTS];
            
            //reset action-sheet mode
            current_mode = -1;
            
            //set state initially to driving state
            current_state = DRIVING_STATE;
            
            //begin calculation
            [self startCalculation];
        }
        
        //DriveNow chosen so query if car is x1 or mini-cabrio
        else if(buttonIndex == 1) {
            current_mode = CHOOSE_DN_CAR;
            
            UIActionSheet *actionSheet = [[UIActionSheet alloc]
                            initWithTitle:NSLocalizedString(@"COST_CONTROLLER_ACTIONSHEET_CAR_TITLE", nil)
                            delegate:self
                            cancelButtonTitle:NSLocalizedString(@"COST_CONTROLLER_ACTIONSHEET_ABORT", nil)
                            destructiveButtonTitle:nil
                            otherButtonTitles:    NSLocalizedString(@"COST_CONTROLLER_ACTIONSHEET_DN_NORMAL_CARS", nil),
                                NSLocalizedString(@"COST_CONTROLLER_ACTIONSHEET_DN_SPECIAL_CARS", nil),
                                NSLocalizedString(@"COST_CONTROLLER_ACTIONSHEET_DN_SPECIAL_CARS2", nil),
                                nil];
            
            [actionSheet showFromTabBar:self.tabBarController.tabBar];
        }
        
        else {
            return;
        }
    }
    
    else if(current_mode == CHOOSE_DN_CAR) {
        
        if(buttonIndex >= 0 && buttonIndex < 2) {
            //normal dn-car was chosen
            if(buttonIndex == 0) {
                _calcPrice = [NSNumber numberWithDouble:DN_DRIVE_COSTS];
            }
            
            //special dn-car was chosen
            else {
                _calcPrice = [NSNumber numberWithDouble:DN_DRIVE_COSTS_SPECIAL];
            }
            
            //park-costs are identical in both cases
            _parkPrice = [NSNumber numberWithDouble:DN_PARK_COSTS];
            
            //reset action-sheet mode
            current_mode = -1;
            
            //set state initially to driving state
            current_state = DRIVING_STATE;
            
            //start calculation now
            [self startCalculation];
        }
        
        else
            return;
    }
    
    else if(current_mode == CHOOSE_STATE) {
        //first reset mode
        current_mode = -1;
        
        //select driving state
        if(buttonIndex == 0) {
            current_state = DRIVING_STATE;
        }
        
        //select parking state
        else if(buttonIndex == 1) {
            current_state = PARKING_STATE;
        }
        
        //select end calculcation
        else {
            [self stopCalculation];
        }
    }
    
    else {
        
    }
}

- (void)startCalculation {
    if(!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(calculatePrice) userInfo:nil repeats:YES];
    }
    
    //set right-navigation-button as action button for setting driving/parking-state and end calculcation
    UIBarButtonItem *button = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                               target:self
                               action:@selector(selectState)];
    UINavigationController *navController = (UINavigationController *)self.parentViewController;
    [navController.navigationItem setRightBarButtonItem:button animated:YES];
    
    [_timer fire];
}

- (void)stopCalculation {
    [_timer invalidate];
    _timer = nil;
    
    //reset right-navigation-button
    UINavigationController *navController = (UINavigationController *)self.parentViewController;
    [navController.navigationItem setRightBarButtonItem:nil animated:YES];
    
    //TODO add here the calculated price to database
}

- (void)calculatePrice {
    NSLog(@"In Calculate price");
    if(current_state == DRIVING_STATE) {
        _currentPrice = [NSNumber numberWithDouble:([_calcPrice doubleValue] + [_currentPrice doubleValue])];
    }
    
    else if(current_state == PARKING_STATE) {
        _currentPrice = [NSNumber numberWithDouble:([_parkPrice doubleValue] + [_currentPrice doubleValue])];
    }
    
    else {
        //DO NOTHING
    }
    
    NSLog(@"Current-Price:%.2f", [_currentPrice floatValue]);
    //update label
    _costLabel.text = [NSString stringWithFormat:@"%.2f €", [_currentPrice floatValue]];
}

- (void)selectState {
    current_mode = CHOOSE_STATE;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                initWithTitle:NSLocalizedString(@"COST_CONTROLLER_ACTIONSHEET_METHOD_TITLE", nil)
                delegate:self
                cancelButtonTitle:NSLocalizedString(@"COST_CONTROLLER_ACTIONSHEET_ABORT", nil)
                destructiveButtonTitle:nil
                otherButtonTitles:
                                  NSLocalizedString(@"COST_CONTROLLER_METHOD_DRIVING", nil),
                                  NSLocalizedString(@"COST_CONTROLLER_METHOD_PARKING", nil),
                                  NSLocalizedString(@"COST_CONTROLLER_METHOD_END", nil),
                                  nil];
    
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}



@end
