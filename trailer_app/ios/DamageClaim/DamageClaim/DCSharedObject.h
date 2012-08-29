//
//  PLSharedObject.h
//  Plunk
//
//  Created by Dev on 14/06/12.
//  Copyright (c) 2012 developer.gslab@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCSharedObject : NSObject
@property(nonatomic, retain) NSMutableDictionary *preferences;


+(DCSharedObject *) sharedPreferences;
+(void)showAlertWithMessage:(NSString *)alertMessage;
+(NSString *) generateSignatureForRequest:(NSURLRequest *)urlRequest model:(NSString *)model requestType:(NSString *)requestType;

@end
