//
//  Hope4CarViewController.h
//  Smart2Go
//
//  Created by Hasan Gürcan on 21.04.13.
//  Copyright (c) 2013 Hasan Gürcan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@interface Hope4CarViewController : GAITrackedViewController<UIActionSheetDelegate>

- (IBAction)startBackgroundSearch:(id)sender;
- (IBAction)showIntroduction:(id)sender;


@end
