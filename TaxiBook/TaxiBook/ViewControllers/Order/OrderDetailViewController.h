//
//  OrderDetailViewController.h
//  TaxiBook
//
//  Created by Yik Wai Ng Jason on 16/2/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "PassengerInfoView.h"
#import "PassengerProfileView.h"
#import "OrderModel.h"

@interface OrderDetailViewController : UIViewController <OrderModelDelegate, GMSMapViewDelegate, PassengerProfileViewDelegate>

@property (weak, nonatomic) Order *displayOrder;

@property (strong, nonatomic) GMSMapView *googleMapView;
@property (weak, nonatomic) IBOutlet UIView *mapView;

@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *estimatedFeeLabel;

@property (weak, nonatomic) IBOutlet UIView *bottomContainerView;


@property (strong, nonatomic) PassengerInfoView *passengerInfoView;
@property (strong, nonatomic) PassengerProfileView *passengerProfileView;


@end
