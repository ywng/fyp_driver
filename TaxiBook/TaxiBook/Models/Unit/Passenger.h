//
//  Customer.h
//  TaxiBook
//
//  Created by Chan Ho Pan on 13/4/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Passenger : NSObject

@property (nonatomic) NSInteger passengerId;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *phoneNumber;
@property (strong, nonatomic) NSURL *profilePicUrl;

+ (Passenger *)newInstanceFromServerData:(id)jsonData;

@end
