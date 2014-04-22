//
//  OrderTableViewController.h
//  TaxiBook
//
//  Created by Yik Wai Ng Jason on 14/2/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderModel.h"

@interface OrderTableViewController : UIViewController <OrderModelDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *onHoldImageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
