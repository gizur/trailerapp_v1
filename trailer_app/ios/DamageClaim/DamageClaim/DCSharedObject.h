//
//  PLSharedObject.h
//  DamageClaim
//
//  Created by Dev on 14/06/12.
//  Copyright (c) 2012 developer.gslab@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HTTPService.h"

#import "DCParentViewController.h"

@class MBProgressHUD;

@interface DCSharedObject : NSObject
@property(nonatomic, retain) NSMutableDictionary *preferences;

+(DCSharedObject *) sharedPreferences;

+(void)showAlertWithMessage:(NSString *)alertMessage;

+(void)showAlertWithMessage:(NSString *)alertMessage delegate:(id<UIAlertViewDelegate>) delegate;

+(NSString *) generateSignatureFromModel:(NSString *)model requestType:(NSString *)requestType;

+(NSString *) createURLStringFromIdentifier:(NSString *)identifier;

+(NSString *) keyValuePairFromDictionary:(NSDictionary *)dict;


//in case the body is name=value pairs with progress view optional
+(void) makeURLCALLWithHTTPService:(HTTPService *)httpService extraHeaders:(NSDictionary *)headersDictionaryOrNil bodyDictionary:(NSDictionary *)bodyDictionaryOrNil identifier:(NSString *)identifier requestMethod:(RequestMethod)requestMethod model:(NSString *)model delegate:(id<HTTPServiceDelegate>) delegateOrNil viewController:(DCParentViewController *) viewControllerOrNil showProgressView:(BOOL) showProgressView;

//in case the body is NSData with progress view optional
+(void) makeURLCALLWithHTTPService:(HTTPService *)httpService extraHeaders:(NSDictionary *)headersDictionaryOrNil body:(NSData *)bodyOrNil identifier:(NSString *)identifier requestMethod:(RequestMethod)requestMethod model:(NSString *)model delegate:(id<HTTPServiceDelegate>) delegateOrNil viewController:(DCParentViewController *) viewControllerOrNil showProgressView:(BOOL) showProgressView;


//in case the body is name=value pairs
+(void) makeURLCALLWithHTTPService:(HTTPService *)httpService extraHeaders:(NSDictionary *)headersDictionaryOrNil bodyDictionary:(NSDictionary *)bodyDictionaryOrNil identifier:(NSString *)identifier requestMethod:(RequestMethod)requestMethod model:(NSString *)model delegate:(id<HTTPServiceDelegate>) delegateOrNil viewController:(DCParentViewController *) viewControllerOrNil;

//in case the body is NSData
+(void) makeURLCALLWithHTTPService:(HTTPService *)httpService extraHeaders:(NSDictionary *)headersDictionaryOrNil body:(NSData *)bodyOrNil identifier:(NSString *)identifier requestMethod:(RequestMethod)requestMethod model:(NSString *)model delegate:(id<HTTPServiceDelegate>) delegateOrNil viewController:(DCParentViewController *) viewControllerOrNil;


+(NSString *) keyValuePairFromDictionary:(NSDictionary *)dict;

+(NSString *) decodeSwedishHTMLFromString:(NSString *)swedishString;

+(NSString *) strFromISO8601:(NSDate *) date;

+(void)showProgressDialogInView:(UIView *)view message:(NSString *)labelText;
+(void)hideProgressDialogInView:(UIView *)view;
+(void) processLogout:(UINavigationController *)navigationController clearData:(BOOL) clearData;
@end
