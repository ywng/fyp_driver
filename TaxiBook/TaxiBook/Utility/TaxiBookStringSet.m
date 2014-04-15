//
//  TaxiBookStringSet.m
//  TaxiBook
//
//  Created by Chan Ho Pan on 8/11/13.
//  Copyright (c) 2013 taxibook. All rights reserved.
//

#import "TaxiBookStringSet.h"

@implementation TaxiBookStringSet

NSString const *TaxiBookServiceName = @"com.taxibook.taxibook";
NSString const *TaxiBookGoogleAPIIOSKey = @"AIzaSyDICXJm7NJ-SXutreHUi09Q8TLZiJ9NFRU";
NSString const *TaxiBookGoogleAPIServerKey = @"AIzaSyBA78cM911xXcBpOFMzD6BMjwjt2eLK2kM";

#pragma mark -
#pragma mark - NSNotification Set
NSString const *TaxiBookNotificationEmailCannotFind = @"com.taxibook.notification.user.email.notFound";
NSString const *TaxiBookNotificationUserLoggedIn = @"com.taxibook.notifiation.user.login";
NSString const *TaxiBookNotificationUserLoggedOut = @"com.taxibook.notification.user.logout";
NSString const *TaxiBookNotificationUserLoadOrderData = @"com.taxibook.notification.user.load.order.data";
NSString const *TaxibookNotificationDriverStartWorking = @"com.taxibook.notification.driver.startWorking";

#pragma mark -
#pragma mark - Internal Key Mapping

// internal key mapping -- useful when access NSSecureUserDefault

NSString const *TaxiBookInternalKeyUserId = @"com.taxibook.internal.user.userId";
//NSString const *TaxiBookInternalKeyUsername = @"com.taxibook.internal.user.username";
NSString const *TaxiBookInternalKeyEmail = @"com.taxibook.internal.user.email";
NSString const *TaxiBookInternalKeyFirstName = @"com.taxibook.internal.user.firstName";
NSString const *TaxiBookInternalKeyLastName = @"com.taxibook.internal.user.lastName";
NSString const *TaxiBookInternalKeyPhone = @"com.taxibook.internal.user.phone";
NSString const *TaxiBookInternalKeySessionToken = @"com.taxibook.internal.user.sessionToken.sessionToken";
NSString const *TaxiBookInternalKeySessionExpireTime = @"com.taxibook.internal.user.sessionToken.expireTime";
NSString const *TaxiBookInternalKeyLoggedIn = @"com.taxibook.internal.user.loggedIn";
NSString const *TaxiBookInternalKeyLanguage = @"com.taxibook.internal.user.language";
NSString const *TaxiBookInternalKeyLicenseNo=@"com.taxibook.internal.user.licenseNo";
NSString const *TaxiBookInternalKeyProfilePic=@"com.taxibook.internal.user.profilePic";
NSString const *TaxiBookInternalKeyHasProfilePic=@"com.taxibook.internal.user.hasProfilePic";

NSString const *TaxiBookInternalKeyAvailability=@"com.taxibook.internal.user.availability";
NSString const *TaxiBookInternalKeyAPNSToken = @"com.taxibook.internal.user.apnstoken";


@end
