//
//  OrderTableViewController.m
//  TaxiBook
//
//  Created by Yik Wai Ng Jason on 14/2/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import "OrderTableViewController.h"
#import "OrderDetailViewController.h"
#import "SSKeychain/SSKeychain.h"
#import "NSUserDefaults+SecureAdditions.h"
#import "TaxibookOrderSummaryCell.h"

@interface OrderTableViewController ()
@property (strong, nonatomic) OrderModel *orderModel;

@end

static NSString *OrderDetailSegueIdentifer = @"viewOrderDetail";

@implementation OrderTableViewController

- (OrderModel *)orderModel
{
    if (!_orderModel) {
        // lazy init
        _orderModel = [OrderModel newInstanceWithIdentifier:self.description delegate:self];
    }
    
    return _orderModel;
}


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
    //[self.refreshControl beginRefreshing];
   // [self.orderModel downloadActiveOrders];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedLoadOrderNotification:) name:TaxiBookNotificationUserLoadOrderData object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedLogoutNotification:) name:TaxiBookNotificationUserLoggedOut object:nil];
    

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)receivedLoadOrderNotification:(NSNotification *)notification
{
    NSLog(@"in load order data notification");
    //every time login refresh the order list, other occasions, use refresh by scrolling down or trigger by other notification
    [self.refreshControl beginRefreshing];
    [self.orderModel downloadActiveOrders];
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
        UILabel *fromLabel = summaryCell.fromLabel, *toLabel = summaryCell.toLabel, *pickupTimeLabel = summaryCell.pickupTimeLabel, *statusLabel = summaryCell.statusLabel;
        [fromLabel setText:order.fromGPS.streetDescription];
        [toLabel setText:order.toGPS.streetDescription];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterFullStyle];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        
        [pickupTimeLabel setText:[NSString stringWithFormat:@"Pickup at: %@", [dateFormatter stringFromDate:order.orderTime]]];
        [statusLabel setText:[NSString stringWithFormat:@"Status: %@", [Order orderStatusToString:order.orderStatus]]];
        
        return summaryCell;
        
    }
    
    
    
    return cell;
    
    return cell;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Order *order = [self.orderModel objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:OrderDetailSegueIdentifer sender:order];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */
- (IBAction)pullToRefresh:(id)sender {
    [self.refreshControl beginRefreshing];
    [self.orderModel downloadActiveOrders];
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


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([OrderDetailSegueIdentifer isEqualToString:segue.identifier]) {
        
        // sender is the order
        OrderDetailViewController *detailVC = (OrderDetailViewController *)segue.destinationViewController;
        
        //bookingVC.displayOrder = sender;
        detailVC.displayOrder = sender;
        
    }
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
}


@end
