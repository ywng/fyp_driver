//
//  TabBarViewController.m
//  TaxiBook
//
//  Created by Yik Wai Ng Jason on 14/2/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import "TabBarViewController.h"
#import <NSUserDefaults+SecureAdditions.h>

@interface TabBarViewController ()

@end

@implementation TabBarViewController

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

-(void)viewDidAppear:(BOOL)animated{
    //check logged in or not
    //if not direct to login and register page
    
    BOOL loggedIn = [[NSUserDefaults standardUserDefaults] secretBoolForKey:TaxiBookInternalKeyLoggedIn];
    NSLog(@"Logged in? %d", loggedIn);
    if (!loggedIn) {
      [self performSegueWithIdentifier:@"welcomeModal" sender:self];
    }
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedLogoutNotification:) name:TaxiBookNotificationUserLoggedOut object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedLoginNotification:) name:TaxiBookNotificationUserLoggedIn object:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)receivedLoginNotification:(NSNotification *)notification
{
    [self setSelectedIndex:0];
}

- (void)receivedLogoutNotification:(NSNotification *)notification
{
    [self performSegueWithIdentifier:@"welcomeModal" sender:self];
}

@end
