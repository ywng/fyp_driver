//
//  GoogleMapPlaceSearchService.h
//  TaxiBook
//
//  Created by Chan Ho Pan on 23/1/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "GMPlace.h"

typedef NS_ENUM(NSInteger, PlaceSearchType) {

    PlaceSearchTypeExactSearch = 1,
    PlaceSearchTypeAutoComplete = 2,
    PlaceSearchTypeReverseGeocoding = 3,
    PlaceSearchTypeDetailSearch = 4,

};

@protocol GMPlaceSearchServiceDelegate <NSObject>

- (void)finishDownloadPlaceSearch:(NSArray *)places searchType:(PlaceSearchType)searchType;

@end

@interface GoogleMapPlaceSearchService : NSObject

+ (void)searchWithKeyword:(NSString *)keyword gpsEnable:(BOOL)gpsEnable location:(CLLocation *)location withDelegate:(id<GMPlaceSearchServiceDelegate>)delegate;

+ (void)placeDetail:(NSString *)placeReference withDelegate:(id<GMPlaceSearchServiceDelegate>)delegate;

+ (void)autoCompleteWithKeyword:(NSString *)keyword gpsEnable:(BOOL)gpsEnable location:(CLLocation *)location withDelegate:(id<GMPlaceSearchServiceDelegate>)delegate;


/**
 * Data will be returned via the delegate method, each object in the Array is type of `GMPlace`, with only `coordinate` and `placeAddress` available
 */
+ (void)reverseGeocodingWithLocation:(CLLocation *)location withDelegate:(id<GMPlaceSearchServiceDelegate>)delegate;

@end
