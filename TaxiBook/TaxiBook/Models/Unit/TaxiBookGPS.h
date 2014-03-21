//
//  TaxiBookGPS.h
//  TaxiBook
//
//  Created by Chan Ho Pan on 10/1/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GMPlace;

@interface TaxiBookGPS : NSObject

@property (nonatomic) float latitude;
@property (nonatomic) float longitude;
@property (nonatomic) NSString *streetDescription;

+ (TaxiBookGPS *)taxibookGPSFromGMPlace:(GMPlace *)place;

@end
