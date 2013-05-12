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
}

- (void)viewDidDisappear:(BOOL)animated {
    UINavigationController *navController = (UINavigationController *)self.parentViewController;
    navController.navigationItem.rightBarButtonItem = nil;
}

-(void)viewDidAppear:(BOOL)animated {
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startBackgroundSearch:(id)sender {
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
    NSLog(@"Button-Index:\t%d", buttonIndex);
    //there is just one button, so activate background search
    if(buttonIndex == 0) {
        com_appdy_smart2goAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        delegate.foundCar = NO;
        
        RNBlurModalView *modalView = [[RNBlurModalView alloc] initWithTitle:@"Hope4Car" message:NSLocalizedString(@"HOME_VIEW_START_BACKGROUND_STARTED_TEXT", nil)];
        [modalView show];
    }
}

@end
