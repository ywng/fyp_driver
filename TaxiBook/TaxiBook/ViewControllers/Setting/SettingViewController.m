//
//  SettingViewController.m
//  TaxiBook
//
//  Created by Yik Wai Ng Jason on 9/1/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import "SettingViewController.h"
#import "TaxiBookConnectionManager.h"
#import "SubView.h"
#import "SSKeychain/SSKeychain.h"
#import "NSUserDefaults+SecureAdditions.h"

@interface SettingViewController ()

@end



@implementation SettingViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 2;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    if(section==0){
//        return 4;
//    }else if(section==1){
//        return 1;
//    }else{
//        return 0;
//    }
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    
//    // Configure the cell...
//    
//    return cell;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"did select %@", indexPath);
    if(indexPath.section==0){
        
    }else if(indexPath.section==1){
        
    }else if(indexPath.section==2){
        [SubView loadingView:nil];
        
        [[TaxiBookConnectionManager sharedManager] logoutDriverWithCompletionHandler:^(id responseObject) {
            [SubView dismissAlert];
            [[NSNotificationCenter defaultCenter] postNotificationName:TaxiBookNotificationUserLoggedOut object:nil];
        }];

    }
}

@end
