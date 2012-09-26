//
//  PLSharedObject.h
//  Plunk
//
//  Created by Dev on 14/06/12.
//  Copyright (c) 2012 developer.gslab@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HTTPService.h"

@class MBProgressHUD;

@interface DCSharedObject : NSObject
@property(nonatomic, retain) NSMutableDictionary *preferences;


+(DCSharedObject *) sharedPreferences;

+(void)showAlertWithMessage:(NSString *)alertMessage;

+(NSString *) generateSignatureFromModel:(NSString *)model requestType:(NSString *)requestType;

+(NSString *) createURLStringFromIdentifier:(NSString *)identifier;

+(NSString *) keyValuePairFromDictionary:(NSDictionary *)dict;


//in case the body is name=value pairs with progress view optional
+(void) makeURLCALLWithHTTPService:(HTTPService *)httpService extraHeaders:(NSDictionary *)headersDictionaryOrNil bodyDictionary:(NSDictionary *)bodyDictionaryOrNil identifier:(NSString *)identifier requestMethod:(RequestMethod)requestMethod model:(NSString *)model delegate:(id<HTTPServiceDelegate>) delegateOrNil viewController:(UIViewController *) viewControllerOrNil showProgressView:(BOOL) showProgressView;

//in case the body is NSData with progress view optional
+(void) makeURLCALLWithHTTPService:(HTTPService *)httpService extraHeaders:(NSDictionary *)headersDictionaryOrNil body:(NSData *)bodyOrNil identifier:(NSString *)identifier requestMethod:(RequestMethod)requestMethod model:(NSString *)model delegate:(id<HTTPServiceDelegate>) delegateOrNil viewController:(UIViewController *) viewControllerOrNil showProgressView:(BOOL) showProgressView;


//in case the body is name=value pairs
+(void) makeURLCALLWithHTTPService:(HTTPService *)httpService extraHeaders:(NSDictionary *)headersDictionaryOrNil bodyDictionary:(NSDictionary *)bodyDictionaryOrNil identifier:(NSString *)identifier requestMethod:(RequestMethod)requestMethod model:(NSString *)model delegate:(id<HTTPServiceDelegate>) delegateOrNil viewController:(UIViewController *) viewControllerOrNil;

//in case the body is NSData
+(void) makeURLCALLWithHTTPService:(HTTPService *)httpService extraHeaders:(NSDictionary *)headersDictionaryOrNil body:(NSData *)bodyOrNil identifier:(NSString *)identifier requestMethod:(RequestMethod)requestMethod model:(NSString *)model delegate:(id<HTTPServiceDelegate>) delegateOrNil viewController:(UIViewController *) viewControllerOrNil;


+(NSString *) keyValuePairFromDictionary:(NSDictionary *)dict;

+(NSString *) decodeSwedishHTMLFromString:(NSString *)swedishString;

+(NSString *) strFromISO8601:(NSDate *) date;

+(void)showProgressDialogInView:(UIView *)view message:(NSString *)labelText;
+(void)hideProgressDialogInView:(UIView *)view;
@end
