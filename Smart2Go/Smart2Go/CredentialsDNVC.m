//
//  OptionViewController.m
//  TradeMirrorApp2
//
//  Created by Hasan Gürcan on 08.03.12.
//  Copyright (c) 2012 FU-Berlin. All rights reserved.
//

#import "CredentialsDNVC.h"

@implementation CredentialsDNVC


- (IBAction) saveUserSettings:(id)sender {
    NSLog(@"In Method SaveSettings");
    com_appdy_smart2goAppDelegate *delegate;
	delegate = (com_appdy_smart2goAppDelegate *)[UIApplication sharedApplication].delegate;
    
    delegate.usernameDN = _usernameTextfield.text;
    delegate.passwordDN = _passwordTextfield.text;
    
    username = delegate.usernameDN;
    password = delegate.passwordDN;
    
    [self.navigationItem setPrompt:@"Saved data"];
    
    //save user credentials
    [delegate setUserDefaults];
}

- (BOOL)containsSubstring:(NSString *)string subString:(NSString *)subString {
    NSRange textRange;
    textRange =[[string lowercaseString] rangeOfString:[subString lowercaseString]];
    
    if(textRange.location != NSNotFound)
        return YES;
    else
        return NO;
    
}

- (IBAction)textFieldDoneEditing:(id)sender{
	[sender resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"Called return");
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    com_appdy_smart2goAppDelegate *delegate;
	delegate = (com_appdy_smart2goAppDelegate *)[UIApplication sharedApplication].delegate;
    
    username = delegate.usernameDN;
    password = delegate.passwordDN;
    
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated {
    //add toolbarbutton
    UINavigationController *navController = (UINavigationController *)self.parentViewController;
    navController.navigationItem.rightBarButtonItem = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

#pragma mark - table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0)
        return @"Anmeldedaten";
    else
        return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int numberOfRows;
    
    if(section == 0)
        numberOfRows = 2;
    else
        numberOfRows = 1;
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Reuse out of visible range cell if available
    static NSString *CELL_ID = @"optionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID];
    UITextField *inputField;
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_ID];
    
    if(indexPath.section == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        inputField = [[UITextField alloc] initWithFrame:CGRectMake(120,12,185,30)];
        inputField.adjustsFontSizeToFitWidth = YES;
        inputField.textColor = [self deepBlueColor];
        [inputField setDelegate:self];
        [cell addSubview:inputField];
        
        switch([indexPath row])
        {
            case 0:
                cell.textLabel.text = @"Email";
                inputField.text = username;
                inputField.keyboardType = UIKeyboardTypeEmailAddress;
                _usernameTextfield = inputField;
                _usernameTextfield.delegate = self;
                break;
            case 1:
                cell.textLabel.text = @"Password";
                inputField.text = password;
                inputField.keyboardType = UIKeyboardTypeDefault;
                inputField.secureTextEntry = YES;
                _passwordTextfield = inputField;
                _passwordTextfield.delegate = self;
                break;
                
            default:
                break;
        }
    }
    
    else {
        //DO NOTHING YET BUT you could test login and show in prompt
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 1) {
        //first resign first responder
        [self resignFirstResponder];
        
        //now try to save and update statusbar
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [activityIndicator setHidesWhenStopped:YES];
        
        UIBarButtonItem *activityButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
        [activityIndicator startAnimating];
        
        [self.navigationItem setRightBarButtonItem:activityButton];
        
        [self.navigationItem setPrompt:@"Connecting..."];
        
        [NSThread detachNewThreadSelector:@selector(saveUserSettings:) toTarget:self withObject:self];
        
    }
    
    //else
    //do nothing
}

- (UIColor *) deepBlueColor
{
    return [UIColor colorWithRed:51.0f/255.0f green:102.0f/255.0f blue:153.0f/255.0f alpha:1];
}

-(void)backToMenu {
    [self performSegueWithIdentifier:@"backToMenu" sender:self];
}

/*
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 if([[segue identifier] isEqualToString:@"backToMenu"]) {
 NSLog(@"WIll prepare backtomenu-segue ");
 }
 }*/





@end
