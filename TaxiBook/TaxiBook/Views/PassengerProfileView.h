//
//  PassengerProfileView.h
//  TaxiBook
//
//  Created by Chan Ho Pan on 13/4/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Passenger.h"

@protocol PassengerProfileViewDelegate <NSObject>

@optional

- (void)passengerProfilePicFinishLoading;

@end

@interface PassengerProfileView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *passengerProfilePic;
@property (weak, nonatomic) IBOutlet UILabel *passengerNameLabel;
@property (weak, nonatomic) id<PassengerProfileViewDelegate> delegate;

- (void)updateViewWithPassenger:(Passenger *)passenger;
- (void)updateViewWithPassenger:(Passenger *)passenger manuallyUpdate:(BOOL)manuallyUpdate;


@end
