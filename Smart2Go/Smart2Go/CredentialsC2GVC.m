//
//  OptionViewController.m
//  TradeMirrorApp2
//
//  Created by Hasan Gürcan on 08.03.12.
//  Copyright (c) 2012 FU-Berlin. All rights reserved.
//

#import "CredentialsC2GVC.h"

@implementation CredentialsC2GVC


- (IBAction) saveUserSettings:(id)sender {
    com_appdy_smart2goAppDelegate *delegate;
	delegate = (com_appdy_smart2goAppDelegate *)[UIApplication sharedApplication].delegate;
    
    delegate.usernameDN = _usernameTextfield.text;
    delegate.passwordDN = _passwordTextfield.text;
    
    _username = delegate.usernameDN;
    _password = delegate.passwordDN;
    
    UINavigationController *navController = (UINavigationController *)self.parentViewController;
    [navController.navigationItem setPrompt:NSLocalizedString(@"CAR2GO_VIEW_PROMPT_MESSAGE", nil)];
        
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
    
    _username = delegate.usernameDN;
    _password = delegate.passwordDN;
    
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"CAR2GO_VIEW_BAR_BUTTON_SAVE", nil) style:UIBarButtonSystemItemAction target:self action:@selector(saveUserSettings:)];
    
    UINavigationController *navController = (UINavigationController *)self.parentViewController;
    navController.navigationItem.rightBarButtonItem = saveButton;
}

- (void)viewDidDisappear:(BOOL)animated {
    UINavigationController *navController = (UINavigationController *)self.parentViewController;
    navController.navigationItem.rightBarButtonItem = nil;
    
    [navController.navigationItem setPrompt:nil];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

#pragma mark - table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return NSLocalizedString(@"CAR2GO_VIEW_SECTION_TITLE", nil);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int numberOfRows = 2;
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
                inputField.text = _username;
                inputField.keyboardType = UIKeyboardTypeEmailAddress;
                _usernameTextfield = inputField;
                _usernameTextfield.delegate = self;
                break;
            case 1:
                cell.textLabel.text = @"Password";
                inputField.text = _password;
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
    // DO NOTHING
}

- (UIColor *) deepBlueColor
{
    return [UIColor colorWithRed:51.0f/255.0f green:102.0f/255.0f blue:153.0f/255.0f alpha:1];
}

-(void)backToMenu {
    [self performSegueWithIdentifier:@"backToMenu" sender:self];
}


@end
