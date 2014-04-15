//
//  OrderDetailViewController.m
//  TaxiBook
//
//  Created by Yik Wai Ng Jason on 16/2/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import "OrderDetailViewController.h"
#import "MDDirectionService.h"
#import "SubView.h"
#import <UIKit+AFNetworking.h>

@interface OrderDetailViewController () <MDDirectionServiceDelegate> {
    BOOL notFirstUpdate;
}

@property (strong, nonatomic) OrderModel *orderModel;
@property (strong, nonatomic) NSTimer *updateTimer;

@property (strong, nonatomic) GMSMarker *fromMarker;
@property (strong, nonatomic) GMSMarker *toMarker;

//@property (strong, nonatomic) GMSMarker *passengerMarker;

@property (nonatomic) OrderStatus previousOrderStatus;
@property (strong, nonatomic) UIView *mapOverlayView;
@property (strong, nonatomic) UIView *currentOverlayView;
@property (strong, nonatomic) UIView *passengerMarkerInfoView;

@property (nonatomic) BOOL manualUpdatePassengerProfileView;

@end

@implementation OrderDetailViewController


- (GMSMapView *)googleMapView
{
    if (!_googleMapView) {
        CGRect mapRect = self.mapView.frame;
        GMSCameraPosition *camera = nil;
        if (self.displayOrder.fromGPS.latitude != 0 && self.displayOrder.fromGPS.longitude != 0) {
            camera = [GMSCameraPosition cameraWithLatitude:self.displayOrder.fromGPS.latitude longitude:self.displayOrder.fromGPS.longitude zoom:15];
        } else {
            camera = [GMSCameraPosition cameraWithLatitude:22.3964 longitude:114.1095 zoom:11];
        }
        _googleMapView = [GMSMapView mapWithFrame:CGRectMake(0, 0, mapRect.size.width, mapRect.size.height) camera:camera];
        _googleMapView.delegate = self;
        [_googleMapView setMyLocationEnabled:YES];
        [self.mapView addSubview:_googleMapView];
    }
    
    return _googleMapView;
}

- (UIView *)mapOverlayView
{
    if (!_mapOverlayView) {
        _mapOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    }
    return _mapOverlayView;
}

- (PassengerInfoView *)loadPassengerInfoView
{
    NSArray *ele = [[NSBundle mainBundle] loadNibNamed:@"PassengerInfoView" owner:self options:nil];
    if ([ele count] > 0) {
        return [ele objectAtIndex:0];
    } else {
        return nil;
    }
}

- (PassengerProfileView *)loadPassengerProfileView
{
    NSArray *ele = [[NSBundle mainBundle] loadNibNamed:@"PassengerProfileView" owner:self options:nil];
    if ([ele count] > 0) {
        return [ele objectAtIndex:0];
    } else {
        return nil;
    }
}

- (OrderModel *)orderModel
{
    if (!_orderModel) {
        _orderModel = [OrderModel newInstanceWithIdentifier:self.description delegate:self];
    }
    return _orderModel;
}


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
    
    self.previousOrderStatus = OrderStatusUnknown;
    [self setupGoogleMapView];
    [SubView loadingView:nil];
    [self updateDisplayOrder];
    
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(updateDisplayOrder) userInfo:nil repeats:YES];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setupGoogleMapView];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.updateTimer invalidate];
    self.updateTimer = nil;
}


- (void)dealloc
{
    NSLog(@"dealloc %@", self.description);
    [self.updateTimer invalidate];
    self.updateTimer = nil;
}

#pragma mark - OrderModelDelegate

- (void)finishDownloadOrders:(OrderModel *)orderModel
{
    [self.displayOrder updateDetail:[orderModel objectAtIndex:0]];
    if (!notFirstUpdate) {
        [self updateView];
        notFirstUpdate = YES;
    } else {
        [self setupContentView];
    }
    [SubView dismissAlert];
}

- (void)failDownloadOrders:(OrderModel *)orderModel
{
    [self setupContentView];
    [SubView dismissAlert];
}

#pragma mark - IBAction

//- (void)userConfirmTheDriver:(id)sender
//{
//    NSLog(@"Confirm button pressed");
//    
//    [self.orderModel confirmDriver:self.displayOrder.orderId success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"success to confirm driver");
//        [self updateDisplayOrder];
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"fail to confirm driver %@", error);
//        NSString *string = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
//        NSLog(@"string %@",string);
//    }];
//    
//}
//
//- (void)userRejectTheDriver:(id)sender
//{
//    NSLog(@"Reject button pressed");
//    
//    [self.orderModel rejectDriver:self.displayOrder.orderId success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"success to reject driver");
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"fail to reject driver %@", error);
//    }];
//}

#pragma mark - View update

- (void)updateDisplayOrder
{
    [self.orderModel downloadOrderDetail:self.displayOrder.orderId];
}

- (void)updateView
{
    [self.googleMapView clear];
    BOOL fromShown = NO, toShown = NO;
    if (self.displayOrder.fromGPS.latitude != 0 && self.displayOrder.fromGPS.longitude != 0) {
        [self.googleMapView setCamera:[GMSCameraPosition cameraWithLatitude:self.displayOrder.fromGPS.latitude longitude:self.displayOrder.fromGPS.longitude zoom:15]];
        CLLocationCoordinate2D position = CLLocationCoordinate2DMake(self.displayOrder.fromGPS.latitude, self.displayOrder.fromGPS.longitude);
        GMSMarker *marker = [GMSMarker markerWithPosition:position];
        marker.title = @"Pick up location";
        marker.map = self.googleMapView;
        marker.appearAnimation = kGMSMarkerAnimationPop;
        self.fromMarker = marker;
        fromShown = YES;
    }
    if (self.displayOrder.toGPS.latitude != 0 && self.displayOrder.toGPS.longitude != 0) {
        
        CLLocationCoordinate2D position = CLLocationCoordinate2DMake(self.displayOrder.toGPS.latitude, self.displayOrder.toGPS.longitude);
        GMSMarker *marker = [GMSMarker markerWithPosition:position];
        marker.title = @"Drop off location";
        marker.map = self.googleMapView;
        marker.appearAnimation = kGMSMarkerAnimationPop;
        [self.googleMapView setCamera:[GMSCameraPosition cameraWithLatitude:self.displayOrder.toGPS.latitude longitude:self.displayOrder.toGPS.longitude zoom:15]];
        self.toMarker = marker;
        toShown = YES;
    }
    if (fromShown && toShown) {
        
        // update the camera view to display two locations
        
        GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:CLLocationCoordinate2DMake(self.displayOrder.fromGPS.latitude, self.displayOrder.fromGPS.longitude) coordinate:CLLocationCoordinate2DMake(self.displayOrder.toGPS.latitude, self.displayOrder.toGPS.longitude)];
        [self.googleMapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds]];
        
        
        // draw polylines
        
        NSString *origin = [NSString stringWithFormat:@"%f,%f", self.displayOrder.fromGPS.latitude, self.displayOrder.fromGPS.longitude];
        NSString *to = [NSString stringWithFormat:@"%f,%f", self.displayOrder.toGPS.latitude, self.displayOrder.toGPS.longitude];
        
        NSString *sensor = @"false";
        NSArray *parameters = [NSArray arrayWithObjects:sensor, @[origin, to], nil];
        NSArray *keys = [NSArray arrayWithObjects:@"sensor", @"waypoints", nil];
        NSDictionary *query = [NSDictionary dictionaryWithObjects:parameters forKeys:keys];
        MDDirectionService *mds=[[MDDirectionService alloc] init];
        [mds setDirectionsQuery:query withDelegate:self];
        
        // need to rewrite mds to compatible with AFNetworking
    }
    
    // check status to add/remove view
    [self setupContentView];
    
    
    [SubView dismissAlert];
}

- (void)updatePassengerLocation
{
    // redraw passenger location
//    if (self.displayOrder.confirmedPassenger.currentLocation) {
//        if (!self.driverMarker) {
//            
//            GMSMarker *marker = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(self.displayOrder.confirmedPassenger.currentLocation.latitude, self.displayOrder.confirmedDriver.currentLocation.longitude)];
//            // need an image for the circle
//            
//            self.driverMarker = marker;
//            
//        } else {
//            [self.driverMarker setPosition:CLLocationCoordinate2DMake(self.displayOrder.confirmedDriver.currentLocation.latitude, self.displayOrder.confirmedDriver.currentLocation.longitude)];
//        }
//        self.driverMarker.map = self.googleMapView;
//        if (!self.googleMapView.selectedMarker) {
//            self.googleMapView.selectedMarker = self.driverMarker;
//        }
//    }
}

- (void)setupGoogleMapView
{
    CGRect mapRect = self.mapView.frame;
    [self.googleMapView setFrame:CGRectMake(0, 0, mapRect.size.width, mapRect.size.height)];
}

- (void)finishDownloadDirections:(NSDictionary *)json
{
    [self drawDirection:json];
}

- (void)drawDirection:(NSDictionary *)json
{
    if ([[json objectForKey:@"routes"] count] > 0) {
        NSDictionary *routes = [json objectForKey:@"routes"][0];
        
        NSDictionary *route = [routes objectForKey:@"overview_polyline"];
        NSString *overviewRoute = [route objectForKey:@"points"];
        GMSPath *path = [GMSPath pathFromEncodedPath:overviewRoute];
        GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
        polyline.strokeWidth = 5;
        polyline.map = self.googleMapView;
        
        UIColor *transBlue = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.7];
        UIColor *transPurple = [UIColor colorWithRed:0.5 green:0 blue:0.5 alpha:0.7];
        
        GMSStrokeStyle *bluePurple = [GMSStrokeStyle gradientFromColor:transBlue toColor:transPurple];
        GMSStyleSpan *redYellowSpan = [GMSStyleSpan spanWithStyle:bluePurple];
        
        polyline.spans = @[redYellowSpan];
        
        NSDictionary *distances = [[[routes objectForKey:@"legs"] objectAtIndex:0] objectForKey:@"distance"];
        NSDictionary *durations = [[[routes objectForKey:@"legs"] objectAtIndex:0] objectForKey:@"duration"];
        
        //        NSLog(@"distances %@; durations %@", distances, durations);
        
        [self.distanceLabel setText:[distances objectForKey:@"text"]];
        [self.durationLabel setText:[durations objectForKey:@"text"]];
        //
        //        [self.durationLabel sizeToFit];
        
        [self.displayOrder setEstimatedDuration:[[durations objectForKey:@"value"] doubleValue]];
        
        // make up taxi fee
        float distance = [[distances objectForKey:@"value"] floatValue];
        
        if (distance < 2000) {
            self.displayOrder.estimatedPrice = 18.0;
        } else if ( distance < 9500 ) {
            self.displayOrder.estimatedPrice = 18 + (distance - 2000) /200 *1.6; // make up formula
        } else {
            self.displayOrder.estimatedPrice = 78 + (distance - 9500) /200 * 1; // make up formula
        }
        
        [self.estimatedFeeLabel setText:[NSString stringWithFormat:@"HK$ %.1f", self.displayOrder.estimatedPrice]];
        
        self.distanceLabel.hidden = NO;
        self.durationLabel.hidden = NO;
        self.estimatedFeeLabel.hidden = NO;
    } else {
        // zero result
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No possible routes" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)setupContentView
{
    [self updatePassengerLocation];
    
    
    if (self.currentOverlayView && self.previousOrderStatus != self.displayOrder.orderStatus) {
        [self.currentOverlayView removeFromSuperview];
        self.currentOverlayView = nil;
    }
    
    switch (self.displayOrder.orderStatus) {
        case OrderStatusPending:
        {
            if (self.previousOrderStatus != self.displayOrder.orderStatus) {
                
                /* top bar config */
                [self setupTopBarWithColor:[UIColor colorWithRed:60.0/255 green:188.0/255 blue:1 alpha:1] withString:@"Waiting for your confirmation" spinnerNeed:NO];
                
                /* bottom view config */
                
                [self.passengerInfoView removeFromSuperview];
                self.passengerInfoView = nil;
                
                UIView *confirmPassengerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
                
                UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 150, 80)];
//                [cancelButton addTarget:self action:@selector(userRejectTheOrder:) forControlEvents:UIControlEventTouchUpInside];
                [cancelButton setCenter:CGPointMake(80, 50)];
                [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
                [cancelButton setBackgroundColor:[UIColor redColor]];
                [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                
                [confirmPassengerView addSubview:cancelButton];
                
                UIButton *confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 150, 80)];
//                [confirmButton addTarget:self action:@selector(userConfirmTheOrder:) forControlEvents:UIControlEventTouchUpInside];
                [confirmButton setCenter:CGPointMake(240, 50)];
                [confirmButton setTitle:@"Confirm" forState:UIControlStateNormal];
                [confirmButton setBackgroundColor:[UIColor greenColor]];
                [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                
                [confirmPassengerView addSubview:confirmButton];
                [confirmPassengerView setBackgroundColor:[UIColor whiteColor]];
                [self.bottomContainerView addSubview:confirmPassengerView];
                self.currentOverlayView = confirmPassengerView;
            }
        }
            break;
        case OrderStatusBidded:
        {
            if (self.previousOrderStatus != self.displayOrder.orderStatus) {
                
                /* top bar config */
                [self setupTopBarWithColor:[UIColor colorWithRed:0 green:237.0/255 blue:88.0/255 alpha:1] withString:@"Waiting for passenger's confirmation" spinnerNeed:YES];
                
                /* bottom view config */
                [self.passengerInfoView removeFromSuperview];
                self.passengerInfoView = nil;
                
            }
        }
            break;
        case OrderStatusCustomerConfirmed:
        {
            if (self.previousOrderStatus != self.displayOrder.orderStatus) {
                
                /* top bar config */
                NSTimeInterval timeDiff = [self.displayOrder.orderTime timeIntervalSinceNow];
                if (timeDiff < 0) {
                    timeDiff = 0;
                }
                [self setupTopBarWithColor:[UIColor colorWithRed:60.0/255 green:188.0/255 blue:1 alpha:1] withString:[NSString stringWithFormat:@"Pickup time %ld hr %ld min remaining", (long)timeDiff/3600, ((long)timeDiff%3600)/60] spinnerNeed:NO];
                
                /* bottom view config */
                [self setupBottomBarPassengerInfoView];
            }
        }
            break;
        case OrderStatusDriverComing:
        {
            if (self.previousOrderStatus != self.displayOrder.orderStatus) {
                
                /* top bar config */
                NSTimeInterval timeDiff = [self.displayOrder.orderTime timeIntervalSinceNow];
                if (timeDiff < 0) {
                    timeDiff = 0;
                }
                [self setupTopBarWithColor:[UIColor colorWithRed:60.0/255 green:188.0/255 blue:1 alpha:1] withString:[NSString stringWithFormat:@"Pickup time %ld hr %ld min remaining", (long)timeDiff/3600, ((long)timeDiff%3600)/60] spinnerNeed:NO];
                
                /* bottom view config */
                [self setupBottomBarPassengerInfoView];
            }
        }
            break;
        case OrderStatusDriverWaiting:
        {
            if (self.previousOrderStatus != self.displayOrder.orderStatus) {
                
                /* top bar config */
                [self setupTopBarWithColor:[UIColor colorWithRed:0 green:237.0/255 blue:88.0/255 alpha:1] withString:[NSString stringWithFormat:@"Destination: %@", self.displayOrder.toGPS.streetDescription] spinnerNeed:NO];
                
                /* bottom view config */
                [self setupBottomBarPassengerInfoView];
            }
        }
            break;
        case OrderStatusDriverPickedUp:
        {
            if (self.previousOrderStatus != self.displayOrder.orderStatus) {
                
                /* top bar config */
                [self setupTopBarWithColor:[UIColor colorWithRed:0 green:237.0/255 blue:88.0/255 alpha:1] withString:[NSString stringWithFormat:@"Destination: %@", self.displayOrder.toGPS.streetDescription] spinnerNeed:NO];
                
                /* bottom view config */
                [self setupBottomBarPassengerInfoView];
            }
        }
            break;
        case OrderStatusOrderFinished:
        {
            if (self.previousOrderStatus != self.displayOrder.orderStatus) {
                
                /* top bar config */
                [self setupTopBarWithColor:[UIColor colorWithRed:0 green:237.0/255 blue:88.0/255 alpha:1] withString:@"Get ready with next order." spinnerNeed:NO];
                
                /* bottom view config */
                [self setupBottomBarPassengerInfoView];
            }
        }
            break;
        default:
        {
        }
            break;
    }
    self.previousOrderStatus = self.displayOrder.orderStatus;
}

- (void)setupTopBarWithColor:(UIColor *)color withString:(NSString *)string spinnerNeed:(BOOL)spinnerNeed
{
    [self.mapOverlayView removeFromSuperview];
    self.mapOverlayView = nil;
    [self.mapOverlayView setBackgroundColor:color];
    UILabel *label = nil;
    if (spinnerNeed) {
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [activityIndicator setCenter:CGPointMake(20, 22)];
        [activityIndicator startAnimating];
        [self.mapOverlayView addSubview:activityIndicator];
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 260, 30)];
        [label setCenter:CGPointMake(170, 22)];
    } else {
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 30)];
        [label setCenter:CGPointMake(160, 22)];
    }
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setText:string];
    [label setFont:[UIFont fontWithName:UIFontTextStyleHeadline size:15]];
    [label setTextColor:[UIColor whiteColor]];
    
    [self.mapOverlayView addSubview:label];
    [self.view addSubview:self.mapOverlayView];
}

- (void)setupBottomBarPassengerInfoView
{
    if (!self.passengerInfoView) {
        self.passengerInfoView = [self loadPassengerInfoView];
        [self.passengerInfoView setFrame:CGRectMake(0, 0, 320, 100)];
        [self.bottomContainerView addSubview:self.passengerInfoView];
        [self.passengerInfoView updateInfo:self.displayOrder.confirmedPassenger orderStatus:self.displayOrder.orderStatus];
    } else {
        [self.passengerInfoView updateInfo:self.displayOrder.confirmedPassenger orderStatus:self.displayOrder.orderStatus];
    }
}

#pragma mark - GMSMapViewDelegate

- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker
{
    if (marker == self.fromMarker) {
        if (!self.passengerMarkerInfoView) {
            self.passengerProfileView = [self loadPassengerProfileView];
            self.passengerMarkerInfoView = self.passengerProfileView;
            [self.passengerProfileView setDelegate:self];
        }
        
        if (self.manualUpdatePassengerProfileView) {
            [self.passengerProfileView updateViewWithPassenger:self.displayOrder.confirmedPassenger manuallyUpdate:YES];
        } else {
            [self.passengerProfileView updateViewWithPassenger:self.displayOrder.confirmedPassenger];
        }
        
        self.manualUpdatePassengerProfileView = NO;
        
        // calculate distance between them
        //CLLocationDistance distance = [firstLocation distanceFromLocation:secondLocation];
        
        
        
        return self.passengerMarkerInfoView;
    } else {
        return nil;
    }
}

#pragma mark - DriverProfileViewDelegate

- (void)driverProfilePicFinishLoading
{
    if (self.fromMarker && self.googleMapView.selectedMarker == self.fromMarker) {
        self.googleMapView.selectedMarker = nil;
        self.googleMapView.selectedMarker = self.fromMarker;
        self.manualUpdatePassengerProfileView = YES;
    }
}



@end
