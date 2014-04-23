//
//  DriverAppDelegate.h
//  TaxiBook
//
//  Created by ngyik wai on 10/11/13.
//  Copyright (c) 2013 ngyik wai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DriverAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UITabBarController *tabBarController;

- (void)switchToWelcomeView;
- (void)switchToMainView;

@end
