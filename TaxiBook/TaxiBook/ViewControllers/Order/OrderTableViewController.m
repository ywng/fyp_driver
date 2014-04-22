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
@property (strong, nonatomic) OrderModel *activeOrderModel;
@property (strong, nonatomic) OrderModel *assignedOrderModel;


@end

static NSString *OrderDetailSegueIdentifer = @"viewOrderDetail";

@implementation OrderTableViewController {
    BOOL isLoadingActiveOrder;
    BOOL isLoadingAssignedOrder;
}

- (NSString *)activeOrderModelIdentifier
{
    return [self.description stringByAppendingString:@"-active"];
}

- (NSString *)assignedOrderModelIdentifier
{
    return [self.description stringByAppendingString:@"-assigned"];
}

- (OrderModel *)activeOrderModel
{
    if (!_activeOrderModel) {
        // lazy init
        _activeOrderModel = [OrderModel newInstanceWithIdentifier:[self activeOrderModelIdentifier] delegate:self];
    }
    
    return _activeOrderModel;
}

- (OrderModel *)assignedOrderModel
{
    if (!_assignedOrderModel) {
        // lazy init
        _assignedOrderModel = [OrderModel newInstanceWithIdentifier:[self assignedOrderModelIdentifier] delegate:self];
    }
    
    return _assignedOrderModel;
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedLoginNotification:) name:TaxiBookNotificationUserLoggedIn object:nil];
    
    
    BOOL memberStatus = [[NSUserDefaults standardUserDefaults] secretBoolForKey:TaxiBookInternalKeyMemberStatus];
    
    if (!memberStatus) {
        self.onHoldImageView.frame = CGRectMake(self.onHoldImageView.frame.origin.x,
                                                self.onHoldImageView.frame.origin.y, 320, 458);
    }
    else {
        self.onHoldImageView.frame = CGRectMake(self.onHoldImageView.frame.origin.x,
                                                self.onHoldImageView.frame.origin.y, 320, 0);
    }
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated {
    BOOL memberStatus = [[NSUserDefaults standardUserDefaults] secretBoolForKey:TaxiBookInternalKeyMemberStatus];
    
    if (!memberStatus) {
        self.onHoldImageView.frame = CGRectMake(self.onHoldImageView.frame.origin.x,
                                                self.onHoldImageView.frame.origin.y, 320, 458);
    }
    else {
        self.onHoldImageView.frame = CGRectMake(self.onHoldImageView.frame.origin.x,
                                                self.onHoldImageView.frame.origin.y, 320, 0);
    }
}

- (void)receivedLoadOrderNotification:(NSNotification *)notification
{
    NSLog(@"in load order data notification");
    //every time login refresh the order list, other occasions, use refresh by scrolling down or trigger by other notification
    [self.refreshControl beginRefreshing];
    [self.activeOrderModel downloadActiveOrders];
    [self.assignedOrderModel downloadAssignedOrders];
}

- (void)receivedLoginNotification:(NSNotification *)notification{
    NSLog(@"in login notification");
    BOOL memberStatus = [[NSUserDefaults standardUserDefaults] secretBoolForKey:TaxiBookInternalKeyMemberStatus];
    
    if (!memberStatus) {
        self.onHoldImageView.frame = CGRectMake(self.onHoldImageView.frame.origin.x,
                                                self.onHoldImageView.frame.origin.y, 320, 458);
    }
    else {
        self.onHoldImageView.frame = CGRectMake(self.onHoldImageView.frame.origin.x,
                                                self.onHoldImageView.frame.origin.y, 320, 0);
    }
}

- (void)receivedLogoutNotification:(NSNotification *)notification
{
    NSLog(@"in logout notification");
    [self.activeOrderModel clearData];
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    if (section == 0) {
        return [self.assignedOrderModel count];
    } else if (section == 1) {
        return [self.activeOrderModel count];
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"OrderCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    if ([cell isKindOfClass:[TaxibookOrderSummaryCell class]]) {
        TaxibookOrderSummaryCell *summaryCell = (TaxibookOrderSummaryCell *)cell;
        
        Order *order = nil;
        if (indexPath.section == 0) {
            order = [self.assignedOrderModel objectAtIndex:indexPath.row];
        } else if (indexPath.section == 1) {
            order = [self.activeOrderModel objectAtIndex:indexPath.row];
        } else {
            return cell;
        }
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
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Order *order = nil;
    if (indexPath.section == 0) {
        order = [self.assignedOrderModel objectAtIndex:indexPath.row];
    } else if (indexPath.section == 1) {
        order = [self.activeOrderModel objectAtIndex:indexPath.row];
    }
    if (order) {
        [self performSegueWithIdentifier:OrderDetailSegueIdentifer sender:order];
    }
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
    isLoadingActiveOrder = YES;
    isLoadingAssignedOrder = YES;
    [self.activeOrderModel downloadActiveOrders];
    [self.assignedOrderModel downloadAssignedOrders];
}

#pragma mark - OrderModelDelegate

- (void)finishDownloadOrders:(OrderModel *)orderModel
{
    if ([orderModel.identifier isEqualToString:[self activeOrderModelIdentifier]]) {
        self.activeOrderModel = orderModel;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
        isLoadingActiveOrder = NO;
    } else if ([orderModel.identifier isEqualToString:[self assignedOrderModelIdentifier]]) {
        self.assignedOrderModel = orderModel;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        isLoadingAssignedOrder = NO;
    }
    if (!isLoadingAssignedOrder && !isLoadingActiveOrder) {
        [self.refreshControl endRefreshing];
    }
}

- (void)failDownloadOrders:(OrderModel *)orderModel
{
    if ([orderModel.identifier isEqualToString:[self activeOrderModelIdentifier]]) {
        isLoadingActiveOrder = NO;
    } else if ([orderModel.identifier isEqualToString:[self assignedOrderModelIdentifier]]) {
        isLoadingAssignedOrder = NO;
    }
    if (!isLoadingAssignedOrder && !isLoadingActiveOrder) {
        [self.refreshControl endRefreshing];
    }
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
