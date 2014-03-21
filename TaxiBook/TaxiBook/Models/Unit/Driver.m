//
//  Driver.m
//  TaxiBook
//
//  Created by Chan Ho Pan on 10/1/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import "Driver.h"

@implementation Driver

+ (Driver *)newInstanceFromServerData:(id)jsonData
{
    Driver *newDriver = [[Driver alloc] init];
    
    //driverId
    
    id tmp = [jsonData objectForKey:@"did"];
    if (tmp && tmp!=[NSNull null]) {
        newDriver.driverId = [tmp integerValue];
    }
    
    // firstName
    tmp = [jsonData objectForKey:@"first_name"];
    if (tmp && tmp!= [NSNull null]) {
        newDriver.firstName = tmp;
    }
    
    // lastName
    tmp = [jsonData objectForKey:@"last_name"];
    if (tmp && tmp!= [NSNull null]) {
        newDriver.lastName = tmp;
    }
    
    // email
    tmp = [jsonData objectForKey:@"email"];
    if (tmp && tmp!= [NSNull null]) {
        newDriver.email = tmp;
    }
    
    // phoneNumber
    tmp = [jsonData objectForKey:@"phone_no"];
    if (tmp && tmp!= [NSNull null]) {
        newDriver.phoneNumber = tmp;
    }
    
    // licenseNumber
    tmp = [jsonData objectForKey:@"licenseNumber"];
    if (tmp && tmp!= [NSNull null]) {
        newDriver.licenseNumber = tmp;
    }
    
    // licensePhotoUrl
    tmp = [jsonData objectForKey:@"license_photo"];
    if (tmp && tmp!= [NSNull null]) {
        newDriver.licensePhotoUrl = [NSURL URLWithString:tmp];
    }
    
    return newDriver;
}

- (void)updateDriverLatitude:(float)latitude longitude:(float)longitude description:(NSString *)description
{
    TaxiBookGPS *currentLocation = [[TaxiBookGPS alloc] init];
    currentLocation.latitude = latitude;
    currentLocation.longitude = longitude;
    currentLocation.streetDescription = description;
    self.currentLocation = currentLocation;
}

@end
