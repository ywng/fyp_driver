//
//  GoogleMapPlaceSearchService.m
//  TaxiBook
//
//  Created by Chan Ho Pan on 23/1/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import "GoogleMapPlaceSearchService.h"
#import <AFNetworking/AFNetworking.h>
#import <GoogleMaps/GoogleMaps.h>

@interface GoogleMapPlaceSearchService ()

@end

@implementation GoogleMapPlaceSearchService

static NSString *queryAutoCompleteUrl = @"https://maps.googleapis.com/maps/api/place/queryautocomplete/json?";

static NSString *reverseGeocodingCompleteUrl = @"https://maps.googleapis.com/maps/api/geocode/json?";

static NSString *textSearchCompleteUrl = @"https://maps.googleapis.com/maps/api/place/textsearch/json?";

static NSString *detailSearchCompleteUrl = @"https://maps.googleapis.com/maps/api/place/details/json?";

+ (void)searchWithKeyword:(NSString *)keyword gpsEnable:(BOOL)gpsEnable location:(CLLocation *)location withDelegate:(id<GMPlaceSearchServiceDelegate>)delegate
{
    NSString *completedUrl = nil;
    
    if (gpsEnable && location) {
        completedUrl = [NSString stringWithFormat:@"%@key=%@&sensor=true&location=%f,%f&query=%@", textSearchCompleteUrl, TaxiBookGoogleAPIServerKey, location.coordinate.latitude, location.coordinate.longitude, [keyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    } else {
        completedUrl = [NSString stringWithFormat:@"%@key=%@&sensor=false&query=%@", textSearchCompleteUrl, TaxiBookGoogleAPIServerKey, [keyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [[AFHTTPRequestOperationManager manager] GET:completedUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // parse the object here
        //        NSLog(@"responseObject %@", responseObject);
        id results = [responseObject objectForKey:@"results"];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        
        for (id result in results) {
            GMPlace *place = [[GMPlace alloc] init];
            [place setPlaceId:[result objectForKey:@"id"]];
            NSString *formatAddress = [result objectForKey:@"formatted_address"];
            [place setPlaceAddress:formatAddress];
            [place setPlaceDescription:[result objectForKey:@"name"]];
            
            id geometry = [result objectForKey:@"geometry"];
            id location = [geometry objectForKey:@"location"];
            
            place.coordinate = CLLocationCoordinate2DMake([[location objectForKey:@"lat"] floatValue], [[location objectForKey:@"lng"] floatValue]);
            
            [array addObject:place];
        }
        
        [delegate finishDownloadPlaceSearch:array searchType:PlaceSearchTypeExactSearch];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"fail to download auto complete search result, error %@", error);
    }];
}

+ (void)placeDetail:(NSString *)placeReference withDelegate:(id<GMPlaceSearchServiceDelegate>)delegate
{
    NSString *completedUrl = [NSString stringWithFormat:@"%@key=%@&sensor=false&reference=%@", detailSearchCompleteUrl, TaxiBookGoogleAPIServerKey, placeReference];
    
    [[AFHTTPRequestOperationManager manager] GET:completedUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // parse the object here
        //        NSLog(@"responseObject %@", responseObject);
        id result = [responseObject objectForKey:@"result"];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        
        GMPlace *place = [[GMPlace alloc] init];
        [place setPlaceId:[result objectForKey:@"id"]];
        NSString *formatAddress = [result objectForKey:@"formatted_address"];
        [place setPlaceAddress:formatAddress];
        [place setPlaceDescription:[result objectForKey:@"name"]];
        
        id geometry = [result objectForKey:@"geometry"];
        id location = [geometry objectForKey:@"location"];
        
        place.coordinate = CLLocationCoordinate2DMake([[location objectForKey:@"lat"] floatValue], [[location objectForKey:@"lng"] floatValue]);
        
        [array addObject:place];
        
        [delegate finishDownloadPlaceSearch:array searchType:PlaceSearchTypeDetailSearch];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"fail to download auto complete search result, error %@", error);
    }];

}

+ (void)autoCompleteWithKeyword:(NSString *)keyword gpsEnable:(BOOL)gpsEnable location:(CLLocation *)location withDelegate:(id<GMPlaceSearchServiceDelegate>)delegate
{
    NSString *completedUrl = nil;
    
    if (gpsEnable && location) {
        completedUrl = [NSString stringWithFormat:@"%@key=%@&sensor=true&location=%f,%f&input=%@", queryAutoCompleteUrl, TaxiBookGoogleAPIServerKey, location.coordinate.latitude, location.coordinate.longitude, [keyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    } else {
        completedUrl = [NSString stringWithFormat:@"%@key=%@&sensor=false&input=%@", queryAutoCompleteUrl, TaxiBookGoogleAPIServerKey, [keyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    
//    completedUrl = [completedUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSLog(@"completed URL %@", completedUrl);
    
    [[AFHTTPRequestOperationManager manager] GET:completedUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // parse the object here
//        NSLog(@"responseObject %@", responseObject);
        id predictions = [responseObject objectForKey:@"predictions"];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        
        for (id prediction in predictions) {
//            NSLog(@"get prediction %@", prediction);
            GMPlace *place = [[GMPlace alloc] init];
            
            place.placeId = [prediction objectForKey:@"id"];
            place.placeSecondaryDescription = [prediction objectForKey:@"description"];
            place.placeReference = [prediction objectForKey:@"reference"];
            
            id terms = [prediction objectForKey:@"terms"];
            NSString *description = nil;
            for (id term in terms) {
                if (!description) {
                    description = [term objectForKey:@"value"];
                    break;
                }
            }
            place.placeDescription = description;
            
            [array addObject:place];
        }
        
        [delegate finishDownloadPlaceSearch:array searchType:PlaceSearchTypeAutoComplete];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"fail to download auto complete search result, error %@", error);
    }];
}

+ (void)reverseGeocodingWithLocation:(CLLocation *)location withDelegate:(id<GMPlaceSearchServiceDelegate>)delegate
{
    
    /** Refer to https://developers.google.com/maps/documentation/geocoding/#ReverseGeocoding **/
    
    NSString *completeUrl = nil;
    
    if (!location) {
        return;
    }
    
    completeUrl = [NSString stringWithFormat:@"%@latlng=%f,%f&sensor=false", reverseGeocodingCompleteUrl, location.coordinate.latitude, location.coordinate.longitude];
    
    [[AFHTTPRequestOperationManager manager] GET:completeUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // parse the object here

        NSMutableArray *array = [[NSMutableArray alloc] init];
        
        id results = [responseObject objectForKey:@"results"];
        
        for (id result in results) {
            GMPlace *place = [[GMPlace alloc] init];
            
            NSString *formatAddress = [result objectForKey:@"formatted_address"];
            [place setPlaceAddress:formatAddress];
            
            id geometry = [result objectForKey:@"geometry"];
            id location = [geometry objectForKey:@"location"];
            
            place.coordinate = CLLocationCoordinate2DMake([[location objectForKey:@"lat"] floatValue], [[location objectForKey:@"lng"] floatValue]);
            
            [array addObject:place];
            
        }
        
        
        [delegate finishDownloadPlaceSearch:array searchType:PlaceSearchTypeReverseGeocoding];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"fail to download reverse geocoding search result, error %@", error);
    }];
    
}

@end
