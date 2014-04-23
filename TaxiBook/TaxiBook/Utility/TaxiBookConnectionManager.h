//
//  TaxiBookConnectionManager.h
//  TaxiBook
//
//  Created by Chan Ho Pan on 8/11/13.
//  Copyright (c) 2013 taxibook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking/AFNetworking.h"
//#import "AFNetworking/AFNetworkReachabilityManager.h"
//#import "AFNetworking/AFHTTPRequestOperationManager.h"
//#import "AFNetworking/AFHTTPSessionManager.h"

#pragma mark -
#pragma mark - TaxiBookHTTPOperation

/* Self define HTTPOperation to be recreated when waiting user to login */

typedef void (^SuccessHandler)(AFHTTPRequestOperation *operation, id responseObject);
typedef void (^FailureHandler)(AFHTTPRequestOperation *operation, NSError *error);
typedef enum {
    RequestManagerTypePOST = 0,
    RequestManagerTypeImage = 1,
    RequestManagerTypeGET = 2,
} RequestManagerType;

@interface TaxiBookHTTPOperation : NSObject

@property (strong, nonatomic) NSString *relativeUrl;
@property (strong, nonatomic) NSDictionary *params;
@property (strong, nonatomic) NSURL *fileURL;
@property (nonatomic, copy) SuccessHandler success;
@property (nonatomic, copy) FailureHandler failure;
@property (nonatomic) RequestManagerType requestType;

@end


@interface TaxiBookConnectionManager : NSObject

+ (TaxiBookConnectionManager *)sharedManager;

- (void)registerDriver:(NSDictionary *)formDataParameters image: (UIImage*) image success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)editProfilePic:(NSDictionary *)formDataParameters image: (UIImage*) image success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure loginIfNeed:(BOOL)loginIfNeed;

- (void)loginwithParemeters:(NSDictionary *)formDataParameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)postToUrl:(NSString *)relativeUrl withParameters:(NSDictionary *)formDataParameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure loginIfNeed:(BOOL)loginIfNeed;

- (void)loadImageFromUrl:(NSString *)url success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)getUrl:(NSString *)relativeUrl success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure loginIfNeed:(BOOL)loginIfNeed;

- (void)logoutDriverWithCompletionHandler:(void (^)(id responseObject))completionHandler;

@end
