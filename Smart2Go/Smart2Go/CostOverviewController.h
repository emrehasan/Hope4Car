//
//  CostOverviewController.h
//  Smart2Go
//
//  Created by Hasan Gürcan on 13.07.13.
//  Copyright (c) 2013 Hasan Gürcan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CostOverviewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

/**
 *  Load the dates in this array
 */
@property (strong, nonatomic) NSMutableArray *dates;

@property (strong, nonatomic) NSMutableArray *dbobjects;

@property (strong, nonatomic) NSNumber *totalCosts;
/**
 *  Load the mappings date - costs in this dictionary
 */
@property (strong, nonatomic) NSMutableDictionary *costs;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
