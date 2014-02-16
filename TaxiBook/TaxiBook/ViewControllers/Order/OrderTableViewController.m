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
    [self.refreshControl beginRefreshing];
    [self.orderModel downloadActiveOrders];
    
    TaxiBookConnectionManager *manager = [TaxiBookConnectionManager sharedManager];
    [manager getUrl:[NSString stringWithFormat:@"/driver/get_avail"] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"successfully get driver availability");
        
        NSString *avail = [responseObject objectForKey:@"avail"];
         [[NSUserDefaults standardUserDefaults] setSecretObject:avail forKey:TaxiBookInternalKeyAvailability];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"fail to get driver availability %@", error);
        
    } loginIfNeed:YES];

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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
 
    // Return the number of rows in the section.
    return [self.orderModel count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"OrderCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    Order *order = [self.orderModel objectAtIndex:indexPath.row];
    
    cell.textLabel.text = order.toGPS.streetDescription;
    cell.detailTextLabel.text = [Order orderStatusToString:order.orderStatus];
    
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
        OrderDetailViewController *bookingVC = (OrderDetailViewController *)segue.destinationViewController;
        
        //bookingVC.displayOrder = sender;
        
    }
    
}


@end
