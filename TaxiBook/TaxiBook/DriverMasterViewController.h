//
//  driverMasterViewController.h
//  TaxiBook
//
//  Created by ngyik wai on 10/11/13.
//  Copyright (c) 2013 ngyik wai. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>

@interface driverMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
