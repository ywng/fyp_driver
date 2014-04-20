//
//  HistoryTableViewController.m
//  TaxiBook
//
//  Created by Tony Tsang on 21/4/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import "HistoryTableViewController.h"

@interface HistoryTableViewController ()
@property (strong, nonatomic) OrderModel *orderModel;

@end

@implementation HistoryTableViewController

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - OrderModelDelegate

- (void)finishDownloadOrders:(OrderModel *)orderModel
{
    self.orderModel = orderModel;
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (void)failDownloadOrders:(OrderModel *)orderModel
{
    [self.refreshControl endRefreshing];
}

@end
