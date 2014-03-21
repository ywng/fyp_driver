//
//  GMPlace.h
//  TaxiBook
//
//  Created by Chan Ho Pan on 26/1/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/**
 Custom class for Google Place Search API Result
 */

@interface GMPlace : NSObject

@property (strong, nonatomic) NSString *placeId;
@property (strong, nonatomic) NSString *placeDescription;
@property (strong, nonatomic) NSString *placeSecondaryDescription;
@property (strong, nonatomic) NSString *placeAddress;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (strong, nonatomic) NSString *placeReference;


@end
