//
//  OptionViewController.h
//  TradeMirrorApp2
//
//  Created by Hasan Gürcan on 08.03.12.
//  Copyright (c) 2012 FU-Berlin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <dispatch/dispatch.h>
#import "com_appdy_smart2goAppDelegate.h"

@interface CredentialsC2GVC: UITableViewController<UITableViewDelegate,
        UITableViewDataSource, UITextFieldDelegate>
{
    NSString *username;
	NSString *password;
    
}

@property (assign, nonatomic) NSString *username;
@property (assign, nonatomic) NSString *password;
@property (retain, nonatomic) UITextField *usernameTextfield;
@property (retain, nonatomic) UITextField *passwordTextfield;

- (IBAction) saveUserSettings:(id)sender;
- (IBAction) textFieldDoneEditing:(id)sender;

@end
