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

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *bestLocation;

@end

@implementation TabBarViewController

- (CLLocationManager *)locationManager
{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    
    return _locationManager;
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
    
}

-(void)viewDidAppear:(BOOL)animated{
    //check logged in or not
    //if not direct to login and register page
    
    BOOL loggedIn = [[NSUserDefaults standardUserDefaults] secretBoolForKey:TaxiBookInternalKeyLoggedIn];
    NSLog(@"Logged in? %d", loggedIn);
    if (!loggedIn) {
        [(DriverAppDelegate *)[[UIApplication sharedApplication] delegate] switchToWelcomeView];
    } else {
        BOOL avail = [[NSUserDefaults standardUserDefaults] secretBoolForKey:TaxiBookInternalKeyAvailability];
        if (avail) {
            [self startUpdatingLocation:nil];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:TaxiBookNotificationUserLoadOrderData object:nil];
    }
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedLogoutNotification:) name:TaxiBookNotificationUserLoggedOut object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedLoginNotification:) name:TaxiBookNotificationUserLoggedIn object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startUpdatingLocation:) name:TaxibookNotificationDriverStartWorking object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)receivedLoginNotification:(NSNotification *)notification
{
    [self setSelectedIndex:0];
    BOOL avail = [[NSUserDefaults standardUserDefaults] secretBoolForKey:TaxiBookInternalKeyAvailability];
    if (avail) {
        [self startUpdatingLocation:nil];
    }
}

- (void)receivedLogoutNotification:(NSNotification *)notification
{
//    [self performSegueWithIdentifier:@"welcomeModal" sender:self];
    [(DriverAppDelegate *)[[UIApplication sharedApplication] delegate] switchToWelcomeView];
}

- (void)startUpdatingLocation:(NSNotification *)notification
{
    if ([CLLocationManager locationServicesEnabled] != NO) {
        
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
        [self.locationManager setDistanceFilter:kCLDistanceFilterNone];
        
        [self.locationManager startUpdatingLocation];
    }
}

#pragma mark - CLLocationManagerDelegate method

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    // If it's a relatively recent event, turn off updates to save power
    
    static BOOL updatingLocationFlag = NO;
    
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    
    if (abs(howRecent) < 10.0) {
        // If the event is recent, do something with it.
        
        // prepare getting a list of available location
        if (!updatingLocationFlag) {
            updatingLocationFlag = YES;
            TaxiBookConnectionManager *manager = [TaxiBookConnectionManager sharedManager];
            [manager postToUrl:@"/gps/update_location/" withParameters:@{@"latitude": @( location.coordinate.latitude ), @"longitude": @( location.coordinate.longitude)} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                updatingLocationFlag = NO;
                NSLog(@"updated location");
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                updatingLocationFlag = NO;
                NSLog(@"something wrong on updating location");
            } loginIfNeed:YES];
            
        }

    }
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if (error.code == kCLErrorDenied) {
        NSLog(@"user denied");
        [[self locationManager] stopUpdatingLocation];
    } else if (error.code == kCLErrorLocationUnknown) {
        NSLog(@"location unknown");
    }
}

@end
