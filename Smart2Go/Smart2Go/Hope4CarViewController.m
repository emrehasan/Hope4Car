//
//  Hope4CarViewController.m
//  Smart2Go
//
//  Created by Hasan Gürcan on 21.04.13.
//  Copyright (c) 2013 Hasan Gürcan. All rights reserved.
//

#import "Hope4CarViewController.h"
#import "com_appdy_smart2goAppDelegate.h"
#import "RNBlurModalView.h"
#import "com_appdy_smart2goAppDelegate.h"
#import "CustomNavigationBar.h"
#import "GAI.h"
#import "GAITracker.h"

@interface Hope4CarViewController ()

@end

@implementation Hope4CarViewController

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
    
    //self.trackedViewName = @"HomeScreen";
    
    //disable the edit button of the more-controller
    UITabBarController *tc = (UITabBarController *)self.parentViewController;
    [tc setCustomizableViewControllers:nil];
    [tc.moreNavigationController.navigationBar setTranslucent:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    UINavigationController *navController = (UINavigationController *)self.parentViewController;
    navController.navigationItem.rightBarButtonItem = nil;
}

- (IBAction)showIntroduction:(id)sender {
    RNBlurModalView *modalView = [[RNBlurModalView alloc] initWithTitle:@"Hope4Car" message:NSLocalizedString(@"INTRODUCTION_FIRST_PAGE", nil)];
    [modalView show];
}

-(void)viewDidAppear:(BOOL)animated {
    com_appdy_smart2goAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    [delegate getUserDefaults];
    
    if(delegate.isFirstLaunch) {
       [self showIntroduction:self];
        delegate.isFirstLaunch = NO;
        [delegate setUserDefaults];
    }
    
    //add toolbarbutton
    UIButton* infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
	[infoButton addTarget:self action:@selector(showIntroduction:) forControlEvents:UIControlEventTouchUpInside];
    //[infoButton setImage:[UIImage imageNamed:@"infoBtn.png"] forState:UIControlStateNormal];
	UIBarButtonItem *modalButton = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    
    UINavigationController *navController = (UINavigationController *)self.parentViewController;
    navController.navigationItem.rightBarButtonItem = modalButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startBackgroundSearch:(id)sender {
    
    //send message to analytics
    /*id tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-41219625-1"];
    [tracker sendEventWithCategory:@"HomeScreen"
                        withAction:@"startBackgroundSearch"
                         withLabel:@"Hope Now"
                         withValue:[NSNumber numberWithInt:1]];*/
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"HOME_VIEW_START_BACKGROUND_SEARCH_TITLE", nil)
                                                             delegate:self
    cancelButtonTitle:NSLocalizedString(@"HOME_VIEW_START_BACKGROUND_SEARCH_OPTION_NO", nil)
    destructiveButtonTitle:NSLocalizedString(@"HOME_VIEW_START_BACKGROUND_SEARCH_OPTION_YES", nil)
                                                    otherButtonTitles:nil];
    [actionSheet showInView:self.tabBarController.view];
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet {
    //Do Nothing because cancelled
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {    
    //activate background search
    if(buttonIndex == 0) {
        com_appdy_smart2goAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        delegate.foundCar = NO;
        [delegate setUserDefaults];
        
        RNBlurModalView *modalView = [[RNBlurModalView alloc] initWithTitle:@"Hope4Car" message:NSLocalizedString(@"HOME_VIEW_START_BACKGROUND_STARTED_TEXT", nil)];
        [modalView show];
    }
}

@end
