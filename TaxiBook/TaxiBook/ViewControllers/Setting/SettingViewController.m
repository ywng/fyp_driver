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
- (IBAction)update_avail:(id)sender {
    NSString *avail;
    if([self.availSwitch isOn]){
        avail=@"1";
    }else {
         avail=@"0";
    }
    
    TaxiBookConnectionManager *connection=[TaxiBookConnectionManager sharedManager];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
                            avail, @"avail", nil];
    
    [connection postToUrl:@"/driver/set_avail/" withParameters:params
                          success:^(AFHTTPRequestOperation *operation, id responseObject){
                              [[NSUserDefaults standardUserDefaults] setSecretObject:avail forKey:TaxiBookInternalKeyAvailability];
                              [SubView dismissAlert];
                          }
                            failure:^(AFHTTPRequestOperation *operation, NSError *error){
                                [SubView dismissAlert];
                              
                                [SubView showError:@"Fail to update availability, try again!" withTitle:@"Update Availability"];
                                
                                return;
                          } loginIfNeed:YES];
    [SubView loadingView:nil];
    
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
    
    NSString *avail = [[NSUserDefaults standardUserDefaults] secretStringForKey:TaxiBookInternalKeyAvailability];
    
    if([avail isEqualToString:@"1"]){
           [self.availSwitch setOn:YES animated:NO];
    }else if ([avail isEqualToString:@"0"]){
           [self.availSwitch setOn:NO animated:NO];
    }
    


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
        
    }else if(indexPath.section==3){
        [[TaxiBookConnectionManager sharedManager] logoutDriverWithCompletionHandler:^(id responseObject) {
            [SubView dismissAlert];
        }];
        [SubView loadingView:nil];
        
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

@end
