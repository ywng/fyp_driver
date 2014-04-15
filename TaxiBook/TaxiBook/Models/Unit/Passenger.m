//
//  Customer.m
//  TaxiBook
//
//  Created by Chan Ho Pan on 13/4/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import "Passenger.h"
 
@implementation Passenger

+ (Passenger *)newInstanceFromServerData:(id)jsonData
{
    Passenger *newPassenger = [[Passenger alloc] init];
    
    //customerId
    
    id tmp = [jsonData objectForKey:@"pid"];
    if (tmp && tmp!=[NSNull null]) {
        newPassenger.passengerId = [tmp integerValue];
    }
    
    // firstName
    tmp = [jsonData objectForKey:@"first_name"];
    if (tmp && tmp!= [NSNull null]) {
        newPassenger.firstName = tmp;
    }
    
    // lastName
    tmp = [jsonData objectForKey:@"last_name"];
    if (tmp && tmp!= [NSNull null]) {
        newPassenger.lastName = tmp;
    }
    
    // email
    tmp = [jsonData objectForKey:@"email"];
    if (tmp && tmp!= [NSNull null]) {
        newPassenger.email = tmp;
    }
    
    // phoneNumber
    tmp = [jsonData objectForKey:@"phone_no"];
    if (tmp && tmp!= [NSNull null]) {
        newPassenger.phoneNumber = tmp;
    }
    
    // licenseNumber
    tmp = [jsonData objectForKey:@"license_no"];
    if (tmp && tmp!= [NSNull null]) {
        newPassenger.licenseNumber = tmp;
    }
    
    // licensePhotoUrl
    tmp = [jsonData objectForKey:@"license_photo"];
    if (tmp && tmp!= [NSNull null]) {
        newPassenger.licensePhotoUrl = [NSURL URLWithString:tmp];
    }
    
    return newPassenger;
}


@end
