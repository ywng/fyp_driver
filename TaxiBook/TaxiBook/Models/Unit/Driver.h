//
//  Driver.h
//  TaxiBook
//
//  Created by Chan Ho Pan on 10/1/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TaxiBookGPS.h"

@interface Driver : NSObject

@property (nonatomic) NSInteger driverId;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *phoneNumber;
@property (strong, nonatomic) NSString *licenseNumber;
@property (strong, nonatomic) NSURL *licensePhotoUrl;
@property (strong, nonatomic) TaxiBookGPS *currentLocation;

+ (Driver *)newInstanceFromServerData:(id)jsonData;

- (void)updateDriverLatitude:(float)latitude longitude:(float)longitude description:(NSString *)description;

@end
