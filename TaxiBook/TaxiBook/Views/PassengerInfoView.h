//
//  PassengerInfoView.h
//  TaxiBook
//
//  Created by Chan Ho Pan on 13/4/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Order.h"

@interface PassengerInfoView : UIView

@property (weak, nonatomic) IBOutlet UILabel *passengerNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *taxiStatusUpdateButton;
@property (weak, nonatomic) IBOutlet UITextView *mobileNumberTextView;

- (void)updateInfo:(Passenger *)passenger orderStatus:(OrderStatus)orderStatus;

@end
