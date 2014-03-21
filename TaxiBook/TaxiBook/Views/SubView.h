//
//  LoadingView.h
//  TaxiBook
//
//  Created by Yik Wai Ng Jason on 9/1/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SubView : NSObject

+(void) loadingView:(NSString*) loadingMessage;
+(void) showError:(NSString*)message withTitle:(NSString*)title ;
+(void) confirmDia:(NSString*)message withTitle:(NSString*)title;

+(void) dismissAlert;

@end
