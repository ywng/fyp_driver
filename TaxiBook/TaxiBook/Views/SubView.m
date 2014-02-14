//
//  LoadingView.m
//  TaxiBook
//
//  Created by Yik Wai Ng Jason on 9/1/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import "SubView.h"


static UIAlertView *alertWindow = nil;

@implementation SubView
+(void) loadingView:(NSString*) loadingMessage{
    [SubView removeViewIfNeeded];
    
    alertWindow = [[UIAlertView alloc] initWithTitle:@"Loading..." message:loadingMessage delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
    [alertWindow show];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    // Adjust the indicator so it is up a few pixels from the bottom of the alert
    indicator.center = CGPointMake(alertWindow.bounds.size.width / 2, alertWindow.bounds.size.height - 50);
    [indicator startAnimating];
    [alertWindow addSubview:indicator];
    
}

+(void) showError:(NSString*)message withTitle:(NSString *)title{
    [SubView removeViewIfNeeded];
    alertWindow = [[UIAlertView alloc] initWithTitle:title
                                                           message:message
                                                          delegate:nil
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
    [alertWindow show];
}

+(void) confirmDia:(NSString*)message withTitle:(NSString*)title{
    [SubView removeViewIfNeeded];
    alertWindow = [[UIAlertView alloc] initWithTitle:title
                                             message:message
                                            delegate:nil
                                   cancelButtonTitle:@"Cancel"
                                   otherButtonTitles:@"Confirm", nil];
    [alertWindow show];

    
}


+(void) dismissAlert{
    [alertWindow dismissWithClickedButtonIndex:1 animated:NO];
    
    alertWindow = nil;
}


+ (void)removeViewIfNeeded
{
    if (alertWindow) {
        [alertWindow dismissWithClickedButtonIndex:0 animated:NO];
    }
    alertWindow = nil;
}

@end
