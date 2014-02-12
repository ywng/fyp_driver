//
//  driverDetailViewController.h
//  TaxiBook
//
//  Created by ngyik wai on 10/11/13.
//  Copyright (c) 2013 ngyik wai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface driverDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
