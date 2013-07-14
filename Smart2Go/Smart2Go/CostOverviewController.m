//
//  CostOverviewController.m
//  Smart2Go
//
//  Created by Hasan Gürcan on 13.07.13.
//  Copyright (c) 2013 Hasan Gürcan. All rights reserved.
//

#import "CostOverviewController.h"
#import "com_appdy_smart2goAppDelegate.h"

@interface CostOverviewController ()

@end

@implementation CostOverviewController

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
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}


- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"View Appeared");
    [self loadDB];
}

- (void)loadDB {
    //reset datasources
    _dates = [[NSMutableArray alloc] init];
    _costs = [[NSMutableDictionary alloc] init];
    
    //load db-entries
    [self readCostsDB];
    
    //refresh tableview
    [self.tableView reloadData];
}

- (void)readCostsDB {
    
    com_appdy_smart2goAppDelegate *delegate
        = (com_appdy_smart2goAppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = delegate.managedObjectContext;
    
    // Wir erstellen ein FetchRequest
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Dann holen wir uns die Beschreibung für eine Anrede
    NSEntityDescription *costEntity = [NSEntityDescription entityForName:@"CostEntity"
                                                    inManagedObjectContext:context];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"entrydate" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Setzen die Entity für den FetchRequest
    fetchRequest.entity = costEntity;
    
    // FetchRequest "absenden"
    NSError *error;
    _dbobjects = (NSMutableArray *)[context executeFetchRequest:fetchRequest error:&error];
    
    if(error != nil) {
        NSLog(@"Error:\t%@", [error localizedDescription]);
        return;
    }

    for(NSEntityDescription *costEnt in _dbobjects) {
        NSDate *date = [costEnt valueForKey:@"entrydate"];
        NSNumber *cost = [costEnt valueForKey:@"cost"];
        
        _totalCosts = [NSNumber numberWithDouble:([_totalCosts doubleValue] + [cost doubleValue]) ];
        
        NSLog(@"Values-Date:\t%@\n Values-Cost:\t%@", date, cost);
        
        //format date
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat: @"HH:mm dd.MM.yyyy"];
        NSString *formattedDate = [dateFormat stringFromDate: date];
        
        [_dates addObject:formattedDate];
        [_costs setValue:cost forKey:formattedDate];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"CostCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
    if(indexPath.section == 0) {
        [cell.textLabel setText:[NSString stringWithFormat:@"%.2f €", [_totalCosts floatValue]] ];
        [cell.detailTextLabel setText:@"Gesamtkosten"];
    }
    
    else {
        NSString *date = [_dates objectAtIndex:indexPath.row];
        NSString *price = [NSString stringWithFormat:@"%.2f €", [(NSNumber *)[_costs objectForKey:date] floatValue] ];
        
        [cell.textLabel setText:price];
        [cell.detailTextLabel setText:date];
    }
    
    return cell;

}

// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteEntryFromDB:indexPath.row];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0)
        return 1;
    
    else {
        return [_dates count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0)
        return @"";
        //return NSLocalizedString(@"COST_OVERVIEW_SECTION_TOTAL", nil);
    else
        return NSLocalizedString(@"COST_OVERVIEW_SECTION_ENTRY", nil);
}

- (void)deleteEntryFromDB:(int)row {

    // Das  zu löschende Objekt holen
    NSManagedObject *deleteObj = [_dbobjects objectAtIndex:row];
    
    // Das Managed Objekt löschen, zuerst aber wieder den Context holen
    com_appdy_smart2goAppDelegate *delegate = (com_appdy_smart2goAppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = delegate.managedObjectContext;
    
    // Objekt aus Context löschen
    [context deleteObject:deleteObj];
    
    // In Datenbank speichern
    NSError *error;
    if (![context save:&error])
    {
        NSLog(@"Could not delete: %@", [error localizedDescription]);
    }
    else
    {
        [self loadDB];
        [self.tableView reloadData];
    }
}

@end
