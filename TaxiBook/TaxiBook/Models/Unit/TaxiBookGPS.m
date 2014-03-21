//
//  TaxiBookGPS.m
//  TaxiBook
//
//  Created by Chan Ho Pan on 10/1/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import "TaxiBookGPS.h"
#import "GMPlace.h"

@implementation TaxiBookGPS

+ (TaxiBookGPS *)taxibookGPSFromGMPlace:(GMPlace *)place
{
    TaxiBookGPS *gps = [[TaxiBookGPS alloc] init];
    gps.latitude = place.coordinate.latitude;
    gps.longitude = place.coordinate.longitude;
    gps.streetDescription = place.placeAddress;
    
    return gps;
}

@end
