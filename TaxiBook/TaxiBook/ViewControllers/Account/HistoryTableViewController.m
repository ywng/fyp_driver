//
//  HistoryTableViewController.m
//  TaxiBook
//
//  Created by Tony Tsang on 21/4/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import "HistoryTableViewController.h"
#import "TaxibookOrderSummaryCell.h"

@interface HistoryTableViewController ()
@property (strong, nonatomic) OrderModel *orderModel;

@end

@implementation HistoryTableViewController

- (OrderModel *)orderModel
{
    if (!_orderModel) {
        // lazy init
        _orderModel = [OrderModel newInstanceWithIdentifier:self.description delegate:self];
    }
    
    return _orderModel;
}

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedLoadOrderNotification:) name:TaxiBookNotificationUserLoadOrderData object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedLogoutNotification:) name:TaxiBookNotificationUserLoggedOut object:nil];
    
    [self.orderModel downloadInactiveOrders];
}

- (void)receivedLoadOrderNotification:(NSNotification *)notification
{
    NSLog(@"in load order data notification");
    //every time login refresh the order list, other occasions, use refresh by scrolling down or trigger by other notification
    [self.refreshControl beginRefreshing];
    [self.orderModel downloadInactiveOrders];
}

- (void)receivedLogoutNotification:(NSNotification *)notification
{
    NSLog(@"in logout notification");
    [self.orderModel clearData];
    [self.tableView reloadData];
    
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
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.orderModel count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"OrderCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    if ([cell isKindOfClass:[TaxibookOrderSummaryCell class]]) {
        TaxibookOrderSummaryCell *summaryCell = (TaxibookOrderSummaryCell *)cell;
        
        Order *order = [self.orderModel objectAtIndex:indexPath.row];
        [summaryCell.fromLabel setText:order.fromGPS.streetDescription];
        [summaryCell.toLabel setText:order.toGPS.streetDescription];
        [summaryCell.statusLabel setText:[NSString stringWithFormat:@"Status: %@", [Order orderStatusToString:order.orderStatus]]];
        
        return summaryCell;
        
    }
    return cell;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*Order *order = [self.orderModel objectAtIndex:indexPath.row];
     [self performSegueWithIdentifier:bookingDetailSegueIdentifer sender:order];*/
}

- (IBAction)pullToRefresh:(id)sender {
    [self.refreshControl beginRefreshing];
    [self.orderModel downloadInactiveOrders];
}

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
