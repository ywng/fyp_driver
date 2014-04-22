//
//  WelcomeViewController.m
//  TaxiBook
//
//  Created by Yik Wai Ng Jason on 8/1/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import "WelcomeViewController.h"

@interface WelcomeViewController ()

@property (nonatomic) BOOL animated;

@end

@implementation WelcomeViewController

#pragma mark - VC Lifecycle

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
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.animated = NO;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //    if (self.animated) {
    //        dispatch_async(dispatch_get_main_queue(), ^{
    //
    //            // restore to animated position
    //            CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    //            self.backgroundImageView.frame = CGRectMake( screenWidth - self.backgroundImageView.frame.size.width , self.backgroundImageView.frame.origin.y, self.backgroundImageView.frame.size.width, self.backgroundImageView.frame.size.height);
    //            self.joinButton.frame = CGRectMake(self.joinButton.frame.origin.x - screenWidth, self.joinButton.frame.origin.y, self.joinButton.frame.size.width, self.joinButton.frame.size.height);
    //            self.sloganImageView.frame = CGRectMake(self.sloganImageView.frame.origin.x - screenWidth, self.sloganImageView.frame.origin.y, self.sloganImageView.frame.size.width, self.sloganImageView.frame.size.height);
    //            self.signinButton.frame = CGRectMake(self.signinButton.frame.origin.x - screenWidth, self.signinButton.frame.origin.y, self.signinButton.frame.size.width, self.signinButton.frame.size.height);
    //        });
    //    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!self.navigationController.navigationBarHidden) {
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }
    NSLog(@"%@", NSStringFromCGRect(self.sloganImageView.frame));
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    if (!self.animated) {
        
        NSLog(@"screen width %g", screenWidth);
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:2 delay:0 options:UIViewAnimationOptionTransitionNone animations:^{
                self.backgroundImageView.frame = CGRectMake( screenWidth - self.backgroundImageView.frame.size.width , self.backgroundImageView.frame.origin.y, self.backgroundImageView.frame.size.width, self.backgroundImageView.frame.size.height);
            } completion:nil];
            [UIView animateWithDuration:1 delay:1 options:UIViewAnimationOptionTransitionNone animations:^{
                NSLog(@"joinButton %@", NSStringFromCGRect(self.joinButton.frame));
                self.joinButton.frame = CGRectMake(self.joinButton.frame.origin.x - screenWidth, self.joinButton.frame.origin.y, self.joinButton.frame.size.width, self.joinButton.frame.size.height);
            } completion:nil];
            [UIView animateWithDuration:0.8 delay:0.8 options:UIViewAnimationOptionTransitionNone animations:^{
                self.sloganImageView.frame = CGRectMake(self.sloganImageView.frame.origin.x - screenWidth, self.sloganImageView.frame.origin.y, self.sloganImageView.frame.size.width, self.sloganImageView.frame.size.height);
            } completion:nil];
            [UIView animateWithDuration:0.8 delay:1.2 options:UIViewAnimationOptionTransitionNone animations:^{
                NSLog(@"signinButton %@", NSStringFromCGRect(self.joinButton.frame));
                self.signinButton.frame = CGRectMake(self.signinButton.frame.origin.x - screenWidth, self.signinButton.frame.origin.y, self.signinButton.frame.size.width, self.signinButton.frame.size.height);
            } completion:nil];
            self.animated = YES;
        });
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    self.animated = NO;
}

@end
