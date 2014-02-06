//
//  MDDirectionService.m
//  MapsDirections
//
//  Created by Mano Marks on 4/8/13.
//  Copyright (c) 2013 Google. All rights reserved.
//

#import "MDDirectionService.h"

@implementation MDDirectionService{
@private
    BOOL _sensor;
    BOOL _alternatives;
    NSURL *_directionsURL;
    NSArray *_waypoints;
}

static NSString *kMDDirectionsURL = @"http://maps.googleapis.com/maps/api/directions/json?";

- (void)setDirectionsQuery:(NSDictionary *)query withDelegate:(id<MDDirectionServiceDelegate>)delegate
{
    NSArray *waypoints = [query objectForKey:@"waypoints"];
    NSString *origin = [waypoints objectAtIndex:0];
    NSUInteger waypointCount = [waypoints count];
    NSUInteger destinationPos = waypointCount -1;
    NSString *destination = [waypoints objectAtIndex:destinationPos];
    NSString *sensor = [query objectForKey:@"sensor"];
    NSMutableString *url = [NSMutableString stringWithFormat:@"%@&origin=%@&destination=%@&sensor=%@",
     kMDDirectionsURL,origin,destination, sensor];
    if(waypointCount>2) {
        [url appendString:@"&waypoints=optimize:true"];
        NSUInteger wpCount = waypointCount-2;
        for(NSUInteger i=1;i<wpCount;i++){
            [url appendString: @"|"];
            [url appendString:[waypoints objectAtIndex:i]];
        }
    }
    NSString *urlStr = [url stringByAddingPercentEscapesUsingEncoding: NSASCIIStringEncoding];
    _directionsURL = [NSURL URLWithString:urlStr];
    [self retrieveDirections:delegate];
}
- (void)retrieveDirections:(id<MDDirectionServiceDelegate>)delegate{
    dispatch_queue_t downloadQueue = dispatch_queue_create("MDDirectionService", nil);
    
    dispatch_async(downloadQueue, ^{
        NSData* data =
        [NSData dataWithContentsOfURL:_directionsURL];
        [self fetchedData:data withDelegate:delegate];
    });
}

- (void)fetchedData:(NSData *)data withDelegate:(id<MDDirectionServiceDelegate>)delegate{
    
    NSError* error;
    NSDictionary *json = [NSJSONSerialization
                          JSONObjectWithData:data
                          options:kNilOptions
                          error:&error];
    if (delegate && [delegate conformsToProtocol:@protocol(MDDirectionServiceDelegate)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [delegate finishDownloadDirections:json];
        });
    }
}

@end