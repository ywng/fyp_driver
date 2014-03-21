//
//  CustomNavigationController.m
//  TaxiBook
//
//  Created by Yik Wai Ng Jason on 14/2/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import "CustomNavigationController.h"

@interface CustomNavigationController ()

@end

@implementation CustomNavigationController

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
    UIColor *barColor=[UIColor colorWithRed:48.0f/255.0f green:81.0f/255.0f blue:148.0f/255.0f alpha:1.0f];
    self.navigationBar.barTintColor = barColor;
    self.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    self.navigationBar.translucent = NO;
    
    // *barTintColor* sets the background color
    // *tintColor* sets the buttons color
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
