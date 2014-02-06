//
//  TaxiBookErrorSet.h
//  TaxiBook
//
//  Created by Chan Ho Pan on 8/11/13.
//  Copyright (c) 2013 taxibook. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    TaxiBookErrorAlreadyLoggingIn = -(1<<9)
} TaxiBookError;

@interface TaxiBookErrorSet : NSObject

@end
