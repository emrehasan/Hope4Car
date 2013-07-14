//
//  CostViewController.m
//  Smart2Go
//
//  Created by Hasan Gürcan on 23.06.13.
//  Copyright (c) 2013 Hasan Gürcan. All rights reserved.
//

#import "CostViewController.h"
#import "com_appdy_smart2goAppDelegate.h"
#import "MBProgressHUD.h"


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
    
    //set delegate
    _delegate = (com_appdy_smart2goAppDelegate *)[UIApplication sharedApplication].delegate;
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
    NSLog(@"Button-Index:\t%d", buttonIndex);
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
                                NSLocalizedString(@"COST_CONTROLLER_ACTIONSHEET_DN_SPECIAL_CARS1", nil),
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
        else if(buttonIndex == 2){
            [self stopCalculation];
        }
        
        else {
            //DO NOTHING
        }
    }
    
    else {
        //do nothing
    }
}

- (void)startCalculation {
    if(!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(calculatePrice) userInfo:nil repeats:YES];
    }
    
    //set right-navigation-button as action button for setting driving/parking-state and end calculcation
    UIBarButtonItem *button = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                               target:self
                               action:@selector(selectState)];
    UINavigationController *navController = (UINavigationController *)self.parentViewController;
    [navController.navigationItem setRightBarButtonItem:button animated:YES];
    
    [_timer fire];
    
    //set calculating in appdelegate
    _delegate.isCalculating = YES;
}

- (void)stopCalculation {
    [_timer invalidate];
    _timer = nil;
    
    //reset right-navigation-button
    UINavigationController *navController = (UINavigationController *)self.parentViewController;
    [navController.navigationItem setRightBarButtonItem:nil animated:YES];
    
    //add here the calculated price to database
    [self saveCostsToDB];
    
    //set calculation-end in appdelegate
    _delegate.isCalculating = NO;
    _delegate.lastCalcDate = nil;
    
    _currentPrice = [[NSNumber alloc] initWithDouble:0.0];
    _costLabel.text = NSLocalizedString(@"COST_CONTROLLER_DEFAULT_BUTTON_LABEL", nil);
}

- (void)saveCostsToDB {
    com_appdy_smart2goAppDelegate *delegate
        = (com_appdy_smart2goAppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = delegate.managedObjectContext;
    
    // Neues Managed Objekt erstellen
    NSManagedObject *newCost = [NSEntityDescription insertNewObjectForEntityForName:@"CostEntity"
                                                                inManagedObjectContext:context];
    
    NSDate *currDate = [NSDate date];
    
    [newCost setValue:_currentPrice forKey:@"cost"];
    [newCost setValue:currDate forKey:@"entrydate"];
    
    // Speichern
    NSError *error;
    if (![context save:&error])
    {
        NSLog(@"Konnte nicht speichern: %@", [error localizedDescription]);
    }
    
    [self showConcurrentSavedMessage];
}

- (void)showConcurrentSavedMessage {
    UINavigationController *navController = (UINavigationController *)self.parentViewController;

    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:navController.view];
    hud.delegate = self;
    hud.mode = MBProgressHUDModeText;
    hud.labelText = NSLocalizedString(@"COST_CONTROLLER_SAVED_MESSAGE", nil);
    
    [navController.view addSubview:hud];
    [hud showWhileExecuting:@selector(showWhileWaiting) onTarget:self withObject:nil animated:YES];
}

- (void)showWhileWaiting {
    sleep(1);
}

- (void)calculatePrice {
    
    //check if currentdate and lastupdateddate in delegate is greater than one
    NSTimeInterval timeInterval = 1;
    
    if(_delegate.isCalculating && _delegate.lastCalcDate != nil) {
        timeInterval = 60;
        timeInterval = [_delegate.lastCalcDate timeIntervalSinceNow] * -1;
        timeInterval = timeInterval / 60;
    }
    
    _delegate.lastCalcDate = [NSDate date];
    
    NSLog(@"In Calculate price");
    if(current_state == DRIVING_STATE) {
        _currentPrice = [NSNumber numberWithDouble:( (timeInterval * [_calcPrice doubleValue]) + [_currentPrice doubleValue])];
    }
    
    else if(current_state == PARKING_STATE) {
        _currentPrice = [NSNumber numberWithDouble:( (timeInterval *[_parkPrice doubleValue]) + [_currentPrice doubleValue])];
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
