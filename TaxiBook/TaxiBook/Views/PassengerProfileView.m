//
//  PassengerProfileView.m
//  TaxiBook
//
//  Created by Chan Ho Pan on 13/4/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import "PassengerProfileView.h"
#import <UIKit+AFNetworking.h>
#import "UIImage+Color.h"

@interface PassengerProfileView ()

@property (strong, nonatomic) Passenger *displayingPassenger;

@end

@implementation PassengerProfileView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initView];
    }
    return self;
}

- (void)awakeFromNib
{
    [self initView];
}

- (void)initView
{
    self.passengerProfilePic.layer.cornerRadius = self.passengerProfilePic.frame.size.height/2;
    self.passengerProfilePic.clipsToBounds = YES;
    [self.passengerProfilePic setBackgroundColor:[UIColor clearColor]];
}

- (void)updateViewWithPassenger:(Passenger *)passenger
{
    [self updateViewWithPassenger:passenger manuallyUpdate:NO];
}

- (void)updateViewWithPassenger:(Passenger *)passenger manuallyUpdate:(BOOL)manuallyUpdate
{
    if (!self.displayingPassenger && self.displayingPassenger.passengerId != passenger.passengerId) {
        // update view
        
        static UIImage *grayImage = nil;
        
        if (!grayImage) {
            grayImage = [UIImage imageWithColor:[UIColor grayColor] andSize:self.passengerProfilePic.frame.size];
        }
        
        if (passenger.profilePicUrl) {
            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:passenger.profilePicUrl cachePolicy:NSURLCacheStorageAllowed timeoutInterval:30];
            __weak PassengerProfileView *weakSelf = self;
            
            [self.passengerProfilePic setImageWithURLRequest:request placeholderImage:grayImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.passengerProfilePic setImage:image];
                    [weakSelf setNeedsDisplay];
                    
                    if (!manuallyUpdate && self.delegate && [self.delegate respondsToSelector:@selector(passengerProfilePicFinishLoading)]) {
                        [self.delegate passengerProfilePicFinishLoading];
                    }
                });
                
                NSLog(@"image loaded");
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                NSLog(@"image fail to load");
            }];
        }
        if (passenger.firstName && passenger.lastName) {
            [self.passengerNameLabel setText:[NSString stringWithFormat:@"%@ %@", passenger.firstName, passenger.lastName]];
        } else {
            [self.passengerNameLabel setText:@""];
        }
        self.displayingPassenger = passenger;
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
