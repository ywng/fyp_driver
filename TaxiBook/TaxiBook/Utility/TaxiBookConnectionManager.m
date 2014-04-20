//
//  TaxiBookConnectionManager.m
//  TaxiBook
//
//  Created by Chan Ho Pan on 8/11/13.
//  Copyright (c) 2013 taxibook. All rights reserved.
//

#import "TaxiBookConnectionManager.h"
#import "SSKeychain/SSKeychain.h"
#import "NSUserDefaults+SecureAdditions.h"

@implementation TaxiBookHTTPOperation

@end

@interface TaxiBookConnectionManager ()

@property (strong, nonatomic) NSString *serverDomain;
@property (atomic) BOOL isLoggingIn;

@property (strong, nonatomic) AFHTTPRequestOperationManager *normalRequestManager;
@property (strong, nonatomic) AFHTTPRequestOperationManager *imageRequestManager;

@property (strong, nonatomic) NSMutableArray *waitForProcessQueue;

@end


@implementation TaxiBookConnectionManager

+ (TaxiBookConnectionManager *)sharedManager
{
    static TaxiBookConnectionManager *_manager = nil;
    
    if (!_manager) {
        _manager = [[TaxiBookConnectionManager alloc] init];
    }
    return _manager;

}

- (NSMutableArray *)waitForProcessQueue
{
    if (!_waitForProcessQueue) {
        _waitForProcessQueue = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return _waitForProcessQueue;
}

- (AFHTTPRequestOperationManager *)normalRequestManager
{
    if (!_normalRequestManager) {
        _normalRequestManager = [AFHTTPRequestOperationManager manager];
    }
    
    return _normalRequestManager;
}

- (AFHTTPRequestOperationManager *)imageRequestManager
{
    if (!_imageRequestManager) {
        _imageRequestManager = [AFHTTPRequestOperationManager manager];
    }
    
    return _imageRequestManager;
}


- (void)registerDriver:(NSDictionary *)formDataParameters image: (UIImage*) image success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSLog(@"new register request to server param: %@", formDataParameters);
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
    
    NSString *postUrl = [NSString stringWithFormat:@"%@%@", self.serverDomain, @"/driver/register/"];
    
    [self.imageRequestManager POST:postUrl parameters:formDataParameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:@"userfile" fileName:@"userfile.jpg" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject){
        
        NSNumber *responseStatusCode = [responseObject objectForKey:@"status_code"];
        
        if (responseStatusCode && [responseStatusCode integerValue] < 0) {
            NSError *errorWithMessage = [NSError errorWithDomain:TaxiBookServiceName code:[responseStatusCode integerValue] userInfo:@{@"message": [responseObject objectForKey:@"message"]}];
            failure(operation, errorWithMessage); // negative reponse code consider to be fail
        } else {
            success(operation, responseObject);
        }
        
    } failure:failure];
}

- (void)editProfilePic:(NSDictionary *)formDataParameters image: (UIImage*) image success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure  loginIfNeed:(BOOL)loginIfNeed
{
    NSLog(@"edit profile pic");
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
    
    NSString *postUrl = [NSString stringWithFormat:@"%@%@", self.serverDomain, @"/driver/edit_profile_pic/"];
    
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    
    // get email and session_token stored in nsuserdefault
    
    NSString *email = [[NSUserDefaults standardUserDefaults] secretStringForKey:TaxiBookInternalKeyEmail];
    if (!email) {
        NSLog(@"email cannot find");
        [[NSNotificationCenter defaultCenter] postNotificationName:TaxiBookNotificationEmailCannotFind object:nil];
        return ;
    }
    NSString *sessionToken = [[NSUserDefaults standardUserDefaults] secretStringForKey:TaxiBookInternalKeySessionToken];
    if (!sessionToken) {
        NSLog(@"session token cannot find");
        sessionToken = @""; // let it expire the token and re-login
    } else {
        [requestSerializer setValue:sessionToken forHTTPHeaderField:@"X-taxibook-session-token"];
    }
    [requestSerializer setValue:email forHTTPHeaderField:@"X-taxibook-email"];
    [requestSerializer setValue:@"driver" forHTTPHeaderField:@"X-taxibook-user-type"];
    
    
    NSMutableURLRequest *request = [requestSerializer multipartFormRequestWithMethod:@"POST" URLString:postUrl parameters:formDataParameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:@"userfile" fileName:@"userfile.jpg" mimeType:@"image/jpeg"];
    } error:nil];
    
    
    AFHTTPRequestOperation *uploadOp = [self.imageRequestManager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject){
        
        NSNumber *responseStatusCode = [responseObject objectForKey:@"status_code"];
        
        if (responseStatusCode && [responseStatusCode integerValue] < 0) {
            NSError *errorWithMessage = [NSError errorWithDomain:TaxiBookServiceName code:[responseStatusCode integerValue] userInfo:@{@"message": [responseObject objectForKey:@"message"]}];
            failure(operation, errorWithMessage); // negative reponse code consider to be fail
        } else {
            success(operation, responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSString *str = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSLog(@"server return error %@" ,str);
        
        failure(operation, error);
    }];
    
    [self.imageRequestManager.operationQueue addOperation:uploadOp];
    
}



- (void)loginwithParemeters:(NSDictionary *)formDataParameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSLog(@"new login request to server");
    if (self.isLoggingIn) {
        NSError *error = [NSError errorWithDomain:TaxiBookServiceName code:TaxiBookErrorAlreadyLoggingIn userInfo:@{@"internal_message": @"logging in, please try again"}];
        
        failure(nil, error);
        return ; // stop the request
    }
    
    [self setIsLoggingIn:YES];
    NSString *postUrl = [NSString stringWithFormat:@"%@%@", self.serverDomain, @"/driver/login/"];
    
    [self.normalRequestManager POST:postUrl parameters:formDataParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"received login data from server");
        NSNumber *responseStatusCode = [responseObject objectForKey:@"status_code"];
        
        [self setIsLoggingIn:NO];
        
        if (responseStatusCode && [responseStatusCode integerValue] < 0) {
            NSError *errorWithMessage = [NSError errorWithDomain:TaxiBookServiceName code:[responseStatusCode integerValue] userInfo:@{@"message": [responseObject objectForKey:@"message"]}];
            failure(operation, errorWithMessage); // negative reponse code consider to be fail
        } else {
            
            NSString *sessionToken = [responseObject objectForKey:@"session_token"];
            NSString *expireTime = [responseObject objectForKey:@"expire_time"];
            NSString *firstName = [responseObject objectForKey:@"first_name"];
            NSString *lastName = [responseObject objectForKey:@"last_name"];
            NSInteger did = [[responseObject objectForKey:@"did"] integerValue];
            NSString *phoneNumber = [responseObject objectForKey:@"phone_no"];
            NSString *email = [responseObject objectForKey:@"email"];
            NSString *licenseNo= [responseObject objectForKey:@"license_no"];
            NSString *profilePic = [responseObject objectForKey:@"profile_pic"];
            
            BOOL avail= [[responseObject objectForKey:@"is_available"] boolValue];
            
            [[NSUserDefaults standardUserDefaults] setSecretObject:email forKey:TaxiBookInternalKeyEmail];
            [[NSUserDefaults standardUserDefaults] setSecretObject:licenseNo forKey:TaxiBookInternalKeyLicenseNo];
            [[NSUserDefaults standardUserDefaults] setSecretObject:firstName forKey:TaxiBookInternalKeyFirstName];
            [[NSUserDefaults standardUserDefaults] setSecretObject:lastName forKey:TaxiBookInternalKeyLastName];
            [[NSUserDefaults standardUserDefaults] setSecretObject:sessionToken forKey:TaxiBookInternalKeySessionToken];
            [[NSUserDefaults standardUserDefaults] setSecretObject:expireTime forKey:TaxiBookInternalKeySessionExpireTime];
            [[NSUserDefaults standardUserDefaults] setSecretBool:avail forKey:TaxiBookInternalKeyAvailability];
            [[NSUserDefaults standardUserDefaults] setSecretObject:phoneNumber forKey:TaxiBookInternalKeyPhone];
            [[NSUserDefaults standardUserDefaults] setSecretURL:profilePic forKey:TaxiBookInternalKeyProfilePic];
            
            if (profilePic == [NSNull null]) {
                [[NSUserDefaults standardUserDefaults] setSecretBool:NO forKey:TaxiBookInternalKeyHasProfilePic];
            }
            else {
                [[NSUserDefaults standardUserDefaults] setSecretBool:YES forKey:TaxiBookInternalKeyHasProfilePic];
            }

            [[NSUserDefaults standardUserDefaults] setSecretInteger:did forKey:TaxiBookInternalKeyUserId];
            [[NSUserDefaults standardUserDefaults] setSecretBool:YES forKey:TaxiBookInternalKeyLoggedIn];            [[NSUserDefaults standardUserDefaults] synchronize];
            
            
            NSString *password = [formDataParameters objectForKey:@"password"];
            if (password) {
                [SSKeychain setPassword:password forService:TaxiBookServiceName account:email];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:TaxiBookNotificationUserLoggedIn object:nil];
           // [[NSNotificationCenter defaultCenter] postNotificationName:TaxiBookNotificationUserLoadOrderData object:nil];
            
            success(operation, responseObject);
            for (NSInteger index = [self.waitForProcessQueue count] - 1; index >= 0; index -- ) {
                // pop all operation in the queue with the cannot login error
                TaxiBookHTTPOperation *taxibookOperation = [self.waitForProcessQueue objectAtIndex:index];
                [self.waitForProcessQueue removeLastObject];
                if (taxibookOperation.requestType == RequestManagerTypePOST) {
                    [self postToUrl:taxibookOperation.relativeUrl withParameters:taxibookOperation.params success:taxibookOperation.success failure:taxibookOperation.failure loginIfNeed:NO];
                } else if (taxibookOperation.requestType == RequestManagerTypeGET) {
                    [self getUrl:taxibookOperation.relativeUrl success:success failure:failure loginIfNeed:NO];
                } else {
                    // we do not have photo upload for now
//                    [self uploadImageToUrl:taxibookOperation.relativeUrl withParameters:taxibookOperation.params filePath:taxibookOperation.fileURL success:taxibookOperation.success failure:taxibookOperation.failure loginIfNeed:NO];
                }
            }
            
            // register apns token
            NSString *apnsToken = [[NSUserDefaults standardUserDefaults] secretStringForKey:TaxiBookInternalKeyAPNSToken];
            if (apnsToken && [apnsToken length] > 0) {
                [self postToUrl:@"/driver/register_apns_token/" withParameters:@{@"device_token": apnsToken} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSLog(@"register inside apns token %@", responseObject);
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"error: register inside apns token %@", error);
                } loginIfNeed:YES];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self setIsLoggingIn:NO];
        NSLog(@"received login error data from server %@", error);
        
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:error.userInfo];
        [userInfo setObject:@"loginError" forKey:@"addition error messsage"];
        
        NSError *customError = [NSError errorWithDomain:TaxiBookServiceName code:-4 userInfo:userInfo];
        for (NSInteger index = [self.waitForProcessQueue count] - 1; index >= 0; index -- ) {
            // pop all operation in the queue with the cannot login error
            TaxiBookHTTPOperation *taxibookOperation = [self.waitForProcessQueue objectAtIndex:index];
            [self.waitForProcessQueue removeLastObject];
            taxibookOperation.failure(operation, customError);
        }
        
        failure(operation, error);
    }];
}

- (void)postToUrl:(NSString *)relativeUrl withParameters:(NSDictionary *)formDataParameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure loginIfNeed:(BOOL)loginIfNeed
{
    NSLog(@"new POST request to server: %@ param: %@", relativeUrl, formDataParameters);
    
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    
    // get email and session_token stored in nsuserdefault
    
    NSString *email = [[NSUserDefaults standardUserDefaults] secretStringForKey:TaxiBookInternalKeyEmail];
    if (!email) {
        NSLog(@"email cannot find");
        [[NSNotificationCenter defaultCenter] postNotificationName:TaxiBookNotificationEmailCannotFind object:nil];
        return ;
    }
    NSString *sessionToken = [[NSUserDefaults standardUserDefaults] secretStringForKey:TaxiBookInternalKeySessionToken];
    if (!sessionToken) {
        NSLog(@"session token cannot find");
        sessionToken = @""; // let it expire the token and re-login
    } else {
        [requestSerializer setValue:sessionToken forHTTPHeaderField:@"X-taxibook-session-token"];
    }
    [requestSerializer setValue:email forHTTPHeaderField:@"X-taxibook-email"];
    [requestSerializer setValue:@"driver" forHTTPHeaderField:@"X-taxibook-user-type"];
    
    NSString *postUrl = [NSString stringWithFormat:@"%@%@", self.serverDomain, relativeUrl];

    NSMutableURLRequest *request = [requestSerializer requestWithMethod:@"POST" URLString:postUrl parameters:formDataParameters];
    
    AFHTTPRequestOperation *operation = [self.normalRequestManager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSNumber *responseStatusCode = [responseObject objectForKey:@"status_code"];
        NSLog(@"received data from server %@", relativeUrl);
        if (responseStatusCode && [responseStatusCode integerValue] == -1 && loginIfNeed) {
            // Credential checking failed, re-login the user
            
            NSDictionary *parameters = nil;
            NSString *reLoginEmail = [[NSUserDefaults standardUserDefaults] secretStringForKey:TaxiBookInternalKeyEmail];
            NSString *password = [SSKeychain passwordForService:TaxiBookServiceName account:reLoginEmail];
            
            if (!password) {
                // cannot find a password
                [[NSNotificationCenter defaultCenter] postNotificationName:TaxiBookNotificationUserLoggedOut object:nil];
                return;
            }
            parameters = @{@"email" : reLoginEmail, @"password" : password, @"user_type": @"driver"};
            
            [self loginwithParemeters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                // re-do the post method again
                [self postToUrl:relativeUrl withParameters:formDataParameters success:success failure:failure loginIfNeed:NO]; // break the loop if credential check fail again
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                if ([error.domain isEqualToString:TaxiBookServiceName] && error.code == TaxiBookErrorAlreadyLoggingIn) {
                    // create a TaxiBookHTTPOperation object
                    TaxiBookHTTPOperation *taxibookOperation = [[TaxiBookHTTPOperation alloc] init];
                    taxibookOperation.relativeUrl = relativeUrl;
                    taxibookOperation.requestType = RequestManagerTypePOST;
                    taxibookOperation.params = formDataParameters;
                    taxibookOperation.success = success;
                    taxibookOperation.failure = failure;
                    [self.waitForProcessQueue insertObject:taxibookOperation atIndex:0];
                } else {
                    // force logout
                    [[NSNotificationCenter defaultCenter] postNotificationName:TaxiBookNotificationUserLoggedOut object:nil];
                }
            }];
        }
        else if (responseStatusCode && [responseStatusCode integerValue] < 0) {
            NSError *errorWithMessage = [NSError errorWithDomain:TaxiBookServiceName code:[responseStatusCode integerValue] userInfo:@{@"message": [responseObject objectForKey:@"message"]}];
            failure(operation, errorWithMessage); // negative reponse code consider to be fail
        } else {
            success(operation, responseObject);
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([error.domain isEqualToString:TaxiBookServiceName]) {
            NSLog(@"received error from server %@ %@", relativeUrl, error);
        }
//        NSString *str = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];

        failure(operation, error);
    }];
    
    [self.normalRequestManager.operationQueue addOperation:operation];
    
}

- (void)loadImageFromUrl:(NSString *)url success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    AFImageResponseSerializer *imageResponse = [[AFImageResponseSerializer alloc] init];
    
    [self.imageRequestManager setResponseSerializer:imageResponse];
    [self.imageRequestManager GET:url parameters:nil success:success failure:failure];
}

- (void)getUrl:(NSString *)relativeUrl success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure loginIfNeed:(BOOL)loginIfNeed
{
    NSLog(@"new GET request to server: %@", relativeUrl);
    
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    
    // get email and session_token stored in nsuserdefault
    
    NSString *email = [[NSUserDefaults standardUserDefaults] secretStringForKey:TaxiBookInternalKeyEmail];
    if (!email) {
        NSLog(@"email cannot find");
        [[NSNotificationCenter defaultCenter] postNotificationName:TaxiBookNotificationEmailCannotFind object:nil];
        return ;
    }
    NSString *sessionToken = [[NSUserDefaults standardUserDefaults] secretStringForKey:TaxiBookInternalKeySessionToken];
    if (!sessionToken) {
        NSLog(@"session token cannot find");
        sessionToken = @""; // let it expire the token and re-login
    } else {
        [requestSerializer setValue:sessionToken forHTTPHeaderField:@"X-taxibook-session-token"];
    }
    [requestSerializer setValue:email forHTTPHeaderField:@"X-taxibook-email"];
    [requestSerializer setValue:@"driver" forHTTPHeaderField:@"X-taxibook-user-type"];
    
    NSString *getUrl = [NSString stringWithFormat:@"%@%@", self.serverDomain, relativeUrl];
    
    NSMutableURLRequest *request = [requestSerializer requestWithMethod:@"GET" URLString:getUrl parameters:nil];
    
    AFHTTPRequestOperation *operation = [self.normalRequestManager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSNumber *responseStatusCode = [responseObject objectForKey:@"status_code"];
        NSLog(@"received data from server %@", relativeUrl);
        if (responseStatusCode && [responseStatusCode integerValue] == -1 && loginIfNeed) {
            // Credential checking failed, re-login the user
            
            NSDictionary *parameters = nil;
            NSString *reLoginEmail = [[NSUserDefaults standardUserDefaults] secretStringForKey:TaxiBookInternalKeyEmail];
            NSString *password = [SSKeychain passwordForService:TaxiBookServiceName account:reLoginEmail];
            
            if (!password) {
                // cannot find a password
                [[NSNotificationCenter defaultCenter] postNotificationName:TaxiBookNotificationUserLoggedOut object:nil];
                return;
            }
            parameters = @{@"email" : reLoginEmail, @"password" : password, @"user_type": @"driver"};
            
            [self loginwithParemeters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                // re-do the post method again
                [self getUrl:relativeUrl success:success failure:failure loginIfNeed:NO]; // break the loop if credential check fail again
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                if ([error.domain isEqualToString:TaxiBookServiceName] && error.code == TaxiBookErrorAlreadyLoggingIn) {
                    // create a TaxiBookHTTPOperation object
                    TaxiBookHTTPOperation *taxibookOperation = [[TaxiBookHTTPOperation alloc] init];
                    taxibookOperation.relativeUrl = relativeUrl;
                    taxibookOperation.requestType = RequestManagerTypeGET;
                    taxibookOperation.params = nil;
                    taxibookOperation.success = success;
                    taxibookOperation.failure = failure;
                    [self.waitForProcessQueue insertObject:taxibookOperation atIndex:0];
                } else {
                    // force logout
                    [[NSNotificationCenter defaultCenter] postNotificationName:TaxiBookNotificationUserLoggedOut object:nil];
                }
            }];
        }
        else if (responseStatusCode && [responseStatusCode integerValue] < 0) {
            NSError *errorWithMessage = [NSError errorWithDomain:TaxiBookServiceName code:[responseStatusCode integerValue] userInfo:@{@"message": [responseObject objectForKey:@"message"]}];
            failure(operation, errorWithMessage); // negative reponse code consider to be fail
        } else {
            success(operation, responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([error.domain isEqualToString:TaxiBookServiceName]) {
            NSLog(@"received error from server %@ %@", relativeUrl, error);
        }
        failure(operation, error);
    }];
    [self.normalRequestManager.operationQueue addOperation:operation];
}

- (void)logoutDriverWithCompletionHandler:(void (^)(id responseObject))completionHandler
{
    NSLog(@"new logout request to server");
    
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    
    // get email and session_token stored in nsuserdefault
    
    NSString *email = [[NSUserDefaults standardUserDefaults] secretStringForKey:TaxiBookInternalKeyEmail];
    if (!email) {
        NSLog(@"email cannot find");
        [[NSNotificationCenter defaultCenter] postNotificationName:TaxiBookNotificationEmailCannotFind object:nil];
        return ;
    }
    NSString *sessionToken = [[NSUserDefaults standardUserDefaults] secretStringForKey:TaxiBookInternalKeySessionToken];
    
    if (!sessionToken) {
        NSLog(@"session token cannot find");
        sessionToken = @""; // let it expire the token and re-login
    } else {
        [requestSerializer setValue:sessionToken forHTTPHeaderField:@"X-taxibook-session-token"];
    }
    [requestSerializer setValue:email forHTTPHeaderField:@"X-taxibook-email"];
    [requestSerializer setValue:@"driver" forHTTPHeaderField:@"X-taxibook-user-type"];
    
    NSString *getUrl = [NSString stringWithFormat:@"%@%@", self.serverDomain, @"/driver/logout"];
    
    NSMutableURLRequest *request = [requestSerializer requestWithMethod:@"GET" URLString:getUrl parameters:nil];
    
    AFHTTPRequestOperation *operation = [self.normalRequestManager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"received logout confirm from server");
        
        [[NSUserDefaults standardUserDefaults] setSecretBool:NO forKey:TaxiBookInternalKeyLoggedIn];
        [[NSUserDefaults standardUserDefaults] setSecretObject:@"" forKey:TaxiBookInternalKeyEmail];
        [[NSUserDefaults standardUserDefaults] setSecretObject:@"" forKey:TaxiBookInternalKeyFirstName];
        [[NSUserDefaults standardUserDefaults] setSecretObject:@"" forKey:TaxiBookInternalKeyLastName];
        [[NSUserDefaults standardUserDefaults] setSecretObject:@"" forKey:TaxiBookInternalKeySessionToken];
        [[NSUserDefaults standardUserDefaults] setSecretObject:@"" forKey:TaxiBookInternalKeySessionExpireTime];
        [[NSUserDefaults standardUserDefaults] setSecretInteger:-1 forKey:TaxiBookInternalKeyUserId];
        [[NSUserDefaults standardUserDefaults] setSecretObject:@"" forKey:TaxiBookInternalKeyLicenseNo];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:TaxiBookNotificationUserLoggedOut object:nil];
        
        completionHandler(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"received error from server: logout function %@", error);

        [[NSUserDefaults standardUserDefaults] setSecretBool:NO forKey:TaxiBookInternalKeyLoggedIn];
        [[NSUserDefaults standardUserDefaults] setSecretObject:@"" forKey:TaxiBookInternalKeyEmail];
        [[NSUserDefaults standardUserDefaults] setSecretObject:@"" forKey:TaxiBookInternalKeyFirstName];
        [[NSUserDefaults standardUserDefaults] setSecretObject:@"" forKey:TaxiBookInternalKeyLastName];
        [[NSUserDefaults standardUserDefaults] setSecretObject:@"" forKey:TaxiBookInternalKeySessionToken];
        [[NSUserDefaults standardUserDefaults] setSecretObject:@"" forKey:TaxiBookInternalKeySessionExpireTime];
        [[NSUserDefaults standardUserDefaults] setSecretInteger:-1 forKey:TaxiBookInternalKeyUserId];
          [[NSUserDefaults standardUserDefaults] setSecretObject:@"" forKey:TaxiBookInternalKeyLicenseNo];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:TaxiBookNotificationUserLoggedOut object:nil];
        completionHandler(nil);
    }];

    [self.normalRequestManager.operationQueue addOperation:operation];
    
}

- (id)init
{
    if (self = [super init]) {
        self.serverDomain = @"http://ec2-54-255-141-218.ap-southeast-1.compute.amazonaws.com/index.php";
        self.isLoggingIn = NO;
//        __weak TaxiBookConnectionManager *weakSelf = self;
        [self.normalRequestManager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            NSLog(@"internet status change %d" ,status);
            if (status == AFNetworkReachabilityStatusNotReachable || status == AFNetworkReachabilityStatusUnknown) {
                // network not available
            }
        }];
    }
    return self;

}

- (void)dealloc
{
    if (_normalRequestManager) {
        _normalRequestManager = nil;
    }
    if (_imageRequestManager) {
        _imageRequestManager = nil;
    }
}

@end
