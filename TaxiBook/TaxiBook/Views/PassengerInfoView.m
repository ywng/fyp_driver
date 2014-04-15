//
//  PassengerInfoView.m
//  TaxiBook
//
//  Created by Chan Ho Pan on 13/4/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import "PassengerInfoView.h"

@implementation PassengerInfoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [self initSetup];
}

- (void)initSetup
{
    [self.mobileNumberTextView setContentInset:UIEdgeInsetsMake(-4, -4, 0, 0)];
}

- (void)updateInfo:(Passenger *)passenger orderStatus:(OrderStatus)orderStatus
{
    [self.taxiStatusUpdateButton setTitle:[Order driverStatusUpdateToString:orderStatus] forState:UIControlStateNormal];
    
    if (!passenger) {
        [self.passengerNameLabel setText:@"Waiting for passenger"];
        [self.mobileNumberTextView setText:@"Unknown"];
        [self.taxiStatusUpdateButton setTitle:@"Unknown" forState:UIControlStateNormal];
    } else {
        [self.passengerNameLabel setText:[NSString stringWithFormat:@"%@ %@", passenger.firstName, passenger.lastName]];
        [self.mobileNumberTextView setText:[NSString stringWithFormat:@"+852-%@", passenger.phoneNumber]];
    }
    
}

- (IBAction)didPressedUpdateStatusButton:(id)sender {
    if (self.delegate && [self.delegate conformsToProtocol:@protocol(PassengerInfoViewDelegate)]) {
        [self.delegate driverDidPressUpdateStatusButton];
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
