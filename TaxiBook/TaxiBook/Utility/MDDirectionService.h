//
//  MDDirectionService.h
//  MapsDirections
//
//  Created by Mano Marks on 4/8/13.
//  Copyright (c) 2013 Google. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MDDirectionServiceDelegate <NSObject>

- (void)finishDownloadDirections:(NSDictionary *)json;

@end

@interface MDDirectionService : NSObject
- (void)setDirectionsQuery:(NSDictionary *)object withDelegate:(id<MDDirectionServiceDelegate>)delegate;
- (void)retrieveDirections:(id<MDDirectionServiceDelegate>)delegate;
- (void)fetchedData:(NSData *)data withDelegate:(id<MDDirectionServiceDelegate>)delegate;
@end