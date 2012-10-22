//
//  PLSharedObject.m
//  Plunk
//
//  Created by Dev on 14/06/12.
//  Copyright (c) 2012 developer.gslab@gmail.com. All rights reserved.
//

#import "DCSharedObject.h"
#import "Const.h"
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>
#import "NSData+Base64.h"
#import "RequestHeaders.h"
#import "MBProgressHUD.h"
#import "DCLoginViewController.h"

static DCSharedObject *sharedPreferences = nil;


@implementation DCSharedObject

@synthesize preferences = _preferences;

#pragma View Lifecycle methods
+(DCSharedObject *) sharedPreferences {
    @synchronized(self) {
        if (sharedPreferences == nil) {
            sharedPreferences = [[super allocWithZone:NULL] init];
            
        }
    }
    return sharedPreferences;
}

+(id) allocWithZone:(NSZone *)zone {
    return [[self sharedPreferences] retain];
}

-(id) copyWithZone:(NSZone *)zone {
    return self;
}

-(id) retain {
    return self;
}

-(NSUInteger) retainCount {
    return NSUIntegerMax;
}

-(oneway void) release {
    
}

-(id) autorelease {
    return self;
}

-(id) init {
    if (self = [super init]) {
        _preferences = [[NSMutableDictionary alloc] init];
        
    }
    return self;
}


-(void) dealloc {
    [_preferences release];
    [super dealloc];
}

#pragma mark - Others

+(void) showProgressDialogInView:(UIView *)view message:(NSString *)labelText {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.removeFromSuperViewOnHide = YES;
    hud.animationType = MBProgressHUDAnimationZoom;
    hud.labelText = labelText;
    
}

+(void) hideProgressDialogInView:(UIView *)view {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [MBProgressHUD hideHUDForView:view animated:YES];
}


+(void)showAlertWithMessage:(NSString *)alertMessage 
{

    UIAlertView *alertView;
    if ([alertMessage isEqualToString:@"INTERNAL_SERVER_ERROR"]) {
        alertView = [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(alertMessage, @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"LOGOUT", @"") otherButtonTitles:NSLocalizedString(@"OK", @""), nil] autorelease];
    } else {
        alertView = [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(alertMessage, @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil] autorelease];
    }
    
    [alertView show];
	
}

+(void)showAlertWithMessage:(NSString *)alertMessage delegate:(id<UIAlertViewDelegate>) delegate {
    
    UIAlertView *alertView;
    if ([alertMessage isEqualToString:NSLocalizedString(@"INTERNAL_SERVER_ERROR", @"")]) {
        alertView = [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(alertMessage, @"") delegate:delegate cancelButtonTitle:NSLocalizedString(@"LOGOUT", @"") otherButtonTitles:NSLocalizedString(@"OK", @""), nil] autorelease];
    } else {
        alertView = [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(alertMessage, @"") delegate:delegate cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil] autorelease];
    }
    
    [alertView show];
}

+(NSString *) createURLStringFromIdentifier:(NSString *)identifier {
    if ([[NSUserDefaults standardUserDefaults] valueForKey:GIZURCLOUD_API_URL]) {
        NSString *url = [[NSUserDefaults standardUserDefaults] valueForKey:GIZURCLOUD_API_URL];
        return [NSString stringWithFormat:@"%@/%@", url, identifier];
    }
    return [NSString stringWithFormat:@"%@/%@", HTTP_URL, identifier];
    
}

//in case the body is name=value pairs with progress view optional
+(void) makeURLCALLWithHTTPService:(HTTPService *)httpService extraHeaders:(NSDictionary *)headersDictionaryOrNil bodyDictionary:(NSDictionary *)bodyDictionaryOrNil identifier:(NSString *)identifier requestMethod:(RequestMethod)requestMethod model:(NSString *)model delegate:(NSObject<HTTPServiceDelegate> *) delegateOrNil viewController:(DCParentViewController *) viewControllerOrNil showProgressView:(BOOL) showProgressView {
    
    NSString *urlString = [DCSharedObject createURLStringFromIdentifier:identifier];
#if kDebug
    NSLog(@"%@", urlString);
#endif
    
    if (!httpService) {
        httpService = [[[HTTPService alloc] initWithURLString:urlString headers:[RequestHeaders commonHeaders] body:nil delegate:delegateOrNil requestMethod:requestMethod identifier:identifier] autorelease];
    } else {
        [httpService setServiceURLString:urlString];
        [httpService setHeadersDictionary:[[[RequestHeaders commonHeaders] mutableCopy] autorelease]];
        [httpService setDelegate:delegateOrNil];
        [httpService setServiceRequestMethod:requestMethod];
        [httpService setIdentifier:identifier];
        
    }
    
    
    for (NSString *key in headersDictionaryOrNil) {
        [[httpService headersDictionary] setValue:[headersDictionaryOrNil valueForKey:key] forKey:key];
    }
    
    NSString *signature;
    if ([httpService serviceRequestMethod] == kRequestMethodPOST) {
        NSString *bodyString = nil;
        if (bodyDictionaryOrNil) {
            bodyString = [DCSharedObject keyValuePairFromDictionary:bodyDictionaryOrNil];
        }
        httpService.bodyString = bodyString;
#if kDebug
        NSLog(@"%@", bodyString);
#endif
        signature  = [DCSharedObject generateSignatureFromModel:model requestType:POST];
    } else if ( [httpService serviceRequestMethod] == kRequestMethodGET){
        signature = [DCSharedObject generateSignatureFromModel:model requestType:GET];
    } else if([httpService serviceRequestMethod] == kRequestMethodPUT) {
        NSString *bodyString = nil;
        if (bodyDictionaryOrNil) {
            bodyString = [DCSharedObject keyValuePairFromDictionary:bodyDictionaryOrNil];
        }
        httpService.bodyString = bodyString;
#if kDebug
        NSLog(@"%@", bodyString);
#endif

        signature = [DCSharedObject generateSignatureFromModel:model requestType:PUT];
    }
#if kDebug
    NSLog(@"%@", signature);
#endif
    
    if (signature) {
        [[httpService headersDictionary] setValue:signature forKey:X_SIGNATURE];
        if (viewControllerOrNil && showProgressView) {
            if (viewControllerOrNil.navigationController) {
                [DCSharedObject hideProgressDialogInView:viewControllerOrNil.navigationController.view];
                [DCSharedObject showProgressDialogInView:viewControllerOrNil.navigationController.view message:NSLocalizedString(@"LOADING_MESSAGE", @"")];
            } else {
                [DCSharedObject hideProgressDialogInView:viewControllerOrNil.view];
                [DCSharedObject showProgressDialogInView:viewControllerOrNil.view message:NSLocalizedString(@"LOADING_MESSAGE", @"")];
            }
        }
        
        [httpService startService];
#if kDebug
        NSLog(@"%@", [[httpService headersDictionary] description]);
#endif
        
    } else {
        //something went wrong
        [viewControllerOrNil showAlertWithMessage:NSLocalizedString(@"INTERNAL_SERVER_ERROR", @"")];
    
    }

}

//in case the body is NSData with progress view optional
+(void) makeURLCALLWithHTTPService:(HTTPService *)httpService extraHeaders:(NSDictionary *)headersDictionaryOrNil body:(NSData *)bodyOrNil identifier:(NSString *)identifier requestMethod:(RequestMethod)requestMethod model:(NSString *)model delegate:(NSObject<HTTPServiceDelegate> *) delegateOrNil viewController:(DCParentViewController *) viewControllerOrNil showProgressView:(BOOL) showProgressView {
    NSString *urlString = [DCSharedObject createURLStringFromIdentifier:identifier];
#if kDebug
    NSLog(@"%@", urlString);
#endif
    
    if (!httpService) {
        httpService = [[[HTTPService alloc] initWithURLString:urlString headers:[RequestHeaders commonHeaders] body:nil delegate:delegateOrNil requestMethod:requestMethod identifier:identifier] autorelease];
    } else {
        [httpService setServiceURLString:urlString];
        [httpService setHeadersDictionary:[[[RequestHeaders commonHeaders] mutableCopy] autorelease]];
        [httpService setDelegate:delegateOrNil];
        [httpService setServiceRequestMethod:requestMethod];
        [httpService setIdentifier:identifier];
        
    }
    
    
    for (NSString *key in headersDictionaryOrNil) {
        [[httpService headersDictionary] setValue:[headersDictionaryOrNil valueForKey:key] forKey:key];
    }
    
    NSString *signature;
    if ([httpService serviceRequestMethod] == kRequestMethodPOST) {
        if (bodyOrNil) {
            httpService.bodyData = bodyOrNil;
        }
        
//#if kDebug
//        NSLog(@"%@", bodyString);
//#endif
        signature  = [DCSharedObject generateSignatureFromModel:model requestType:POST];
    } else if ( [httpService serviceRequestMethod] == kRequestMethodGET){
        signature = [DCSharedObject generateSignatureFromModel:model requestType:GET];
    } else if([httpService serviceRequestMethod] == kRequestMethodPUT) {
        if (bodyOrNil) {
            httpService.bodyData = bodyOrNil;
        }
        
//#if kDebug
//        NSLog(@"%@", bodyString);
//#endif

        signature = [DCSharedObject generateSignatureFromModel:model requestType:PUT];
    }
#if kDebug
    NSLog(@"%@", signature);
#endif
    
    if (signature) {
        [[httpService headersDictionary] setValue:signature forKey:X_SIGNATURE];
        if (viewControllerOrNil && showProgressView) {
            if (viewControllerOrNil.navigationController) {
                [DCSharedObject hideProgressDialogInView:viewControllerOrNil.navigationController.view];
                [DCSharedObject showProgressDialogInView:viewControllerOrNil.navigationController.view message:NSLocalizedString(@"LOADING_MESSAGE", @"")];
            } else {
                [DCSharedObject hideProgressDialogInView:viewControllerOrNil.view];
                [DCSharedObject showProgressDialogInView:viewControllerOrNil.view message:NSLocalizedString(@"LOADING_MESSAGE", @"")];
            }
        }
        
        [httpService startService];
#if kDebug
        NSLog(@"%@", [[httpService headersDictionary] description]);
#endif
        
    } else {
        //something went wrong
        [viewControllerOrNil showAlertWithMessage:NSLocalizedString(@"INTERNAL_SERVER_ERROR", @"")];
    }
}


+(void) makeURLCALLWithHTTPService:(HTTPService *)httpService extraHeaders:(NSDictionary *)headersDictionaryOrNil bodyDictionary:(NSDictionary *)bodyDictionaryOrNil identifier:(NSString *)identifier requestMethod:(RequestMethod)requestMethod model:(NSString *)model delegate:(NSObject<HTTPServiceDelegate> *) delegateOrNil viewController:(DCParentViewController *) viewControllerOrNil {
    
    NSString *urlString = [DCSharedObject createURLStringFromIdentifier:identifier];
#if kDebug
    NSLog(@"urlString: %@", urlString);
#endif
    if (!httpService) {
        httpService = [[[HTTPService alloc] initWithURLString:urlString headers:[RequestHeaders commonHeaders] body:nil delegate:delegateOrNil requestMethod:requestMethod identifier:identifier] autorelease];
    } else {
        [httpService setServiceURLString:urlString];
        [httpService setHeadersDictionary:[[[RequestHeaders commonHeaders] mutableCopy] autorelease]];
        [httpService setDelegate:delegateOrNil];
        [httpService setServiceRequestMethod:requestMethod];
        [httpService setIdentifier:identifier];
        
    }
    
    for (NSString *key in headersDictionaryOrNil) {
        [[httpService headersDictionary] setValue:[headersDictionaryOrNil valueForKey:key] forKey:key];
    }
    
    NSString *signature;
    if ([httpService serviceRequestMethod] == kRequestMethodPOST) {
        NSString *bodyString = nil;
        if (bodyDictionaryOrNil) {
            bodyString = [DCSharedObject keyValuePairFromDictionary:bodyDictionaryOrNil];
        }
        httpService.bodyString = bodyString;
#if kDebug
        NSLog(@"%@", bodyString);
#endif
        signature  = [DCSharedObject generateSignatureFromModel:model requestType:POST];
    } else if ( [httpService serviceRequestMethod] == kRequestMethodGET){
        signature = [DCSharedObject generateSignatureFromModel:model requestType:GET];
    } else if([httpService serviceRequestMethod] == kRequestMethodPUT) {
        NSString *bodyString = nil;
        if (bodyDictionaryOrNil) {
            bodyString = [DCSharedObject keyValuePairFromDictionary:bodyDictionaryOrNil];
        }
        httpService.bodyString = bodyString;
#if kDebug
        NSLog(@"%@", bodyString);
#endif
        signature  = [DCSharedObject generateSignatureFromModel:model requestType:PUT];
    }
#if kDebug
    NSLog(@"%@", signature);
#endif
    if (signature) {
        [[httpService headersDictionary] setValue:signature forKey:X_SIGNATURE];
        if (viewControllerOrNil) {
            if (viewControllerOrNil.navigationController) {
                [DCSharedObject hideProgressDialogInView:viewControllerOrNil.navigationController.view];
                [DCSharedObject showProgressDialogInView:viewControllerOrNil.navigationController.view message:NSLocalizedString(@"LOADING_MESSAGE", @"")];
            } else {
                [DCSharedObject hideProgressDialogInView:viewControllerOrNil.view];
                [DCSharedObject showProgressDialogInView:viewControllerOrNil.view message:NSLocalizedString(@"LOADING_MESSAGE", @"")];
            }
        }
        
        [httpService startService];
#if kDebug
        NSLog(@"%@", [[httpService headersDictionary] description]);
#endif
        
    } else {
        //something went wrong
        [viewControllerOrNil showAlertWithMessage:NSLocalizedString(@"INTERNAL_SERVER_ERROR", @"")];
    }
}

+(void) makeURLCALLWithHTTPService:(HTTPService *)httpService extraHeaders:(NSDictionary *)headersDictionaryOrNil body:(NSData *)bodyOrNil identifier:(NSString *)identifier requestMethod:(RequestMethod)requestMethod model:(NSString *)model delegate:(NSObject<HTTPServiceDelegate> *) delegateOrNil viewController:(DCParentViewController *) viewControllerOrNil {
    
    NSString *urlString = [DCSharedObject createURLStringFromIdentifier:identifier];
#if kDebug
    NSLog(@"urlString: %@", urlString);
#endif
    
    if (!httpService) {
        httpService = [[[HTTPService alloc] initWithURLString:urlString headers:[RequestHeaders commonHeaders] body:nil delegate:delegateOrNil requestMethod:requestMethod identifier:identifier] autorelease];
    } else {
        [httpService setServiceURLString:urlString];
        [httpService setHeadersDictionary:[[[RequestHeaders commonHeaders] mutableCopy] autorelease]];
        [httpService setDelegate:delegateOrNil];
        [httpService setServiceRequestMethod:requestMethod];
        [httpService setIdentifier:identifier];
        
    }
    
    
    for (NSString *key in headersDictionaryOrNil) {
        [[httpService headersDictionary] setValue:[headersDictionaryOrNil valueForKey:key] forKey:key];
    }
    
    NSString *signature;
    if ([httpService serviceRequestMethod] == kRequestMethodPOST) {
        NSString *bodyString = nil;
        if (bodyOrNil) {
            httpService.bodyData = bodyOrNil;
        }
        
#if kDebug
        NSLog(@"%@", bodyString);
#endif
        signature  = [DCSharedObject generateSignatureFromModel:model requestType:POST];
    } else if ( [httpService serviceRequestMethod] == kRequestMethodGET){
        signature = [DCSharedObject generateSignatureFromModel:model requestType:GET];
    } else if([httpService serviceRequestMethod] == kRequestMethodPUT) {
        NSString *bodyString = nil;
        if (bodyOrNil) {
            httpService.bodyData = bodyOrNil;
        }
        
#if kDebug
        NSLog(@"%@", bodyString);
#endif
        signature = [DCSharedObject generateSignatureFromModel:model requestType:PUT];
    }
#if kDebug
    NSLog(@"%@", signature);
#endif
    
    if (signature) {
        [[httpService headersDictionary] setValue:signature forKey:X_SIGNATURE];
        if (viewControllerOrNil) {
            if (viewControllerOrNil.navigationController) {
#if kDebug
                NSLog(@"%@", viewControllerOrNil.navigationController);
#endif
                [DCSharedObject hideProgressDialogInView:viewControllerOrNil.navigationController.view];
                [DCSharedObject showProgressDialogInView:viewControllerOrNil.navigationController.view message:NSLocalizedString(@"LOADING_MESSAGE", @"")];
            } else {
                [DCSharedObject hideProgressDialogInView:viewControllerOrNil.view];
                [DCSharedObject showProgressDialogInView:viewControllerOrNil.view message:NSLocalizedString(@"LOADING_MESSAGE", @"")];
            }
        }
        
        [httpService startService];
#if kDebug
        NSLog(@"%@", [[httpService headersDictionary] description]);
#endif
        
    } else {
        //something went wrong
        [viewControllerOrNil showAlertWithMessage:NSLocalizedString(@"INTERNAL_SERVER_ERROR", @"")];
    }
}


+(NSString *) keyValuePairFromDictionary:(NSDictionary *)dict {
#if kDebug
    NSLog(@"dict: %@", dict);
#endif
    NSMutableString *retVal = [[[NSMutableString alloc] init] autorelease];
    if (dict) {
        for (NSString *key in dict) {
            retVal = [[[retVal stringByAppendingFormat:[NSString stringWithFormat:@"%@=%@&", key, [dict valueForKey:key]]] mutableCopy] autorelease];
        }
        if ([retVal length] > 1) {
            retVal = [[[retVal substringToIndex:[retVal length] - 1] mutableCopy] autorelease];
        }
        return retVal;
    }
    return nil;
}

+(NSString *) generateSignatureFromModel:(NSString *)model requestType:(NSString *)requestType {
    
    //extract the verb i.e. GET POST etc
    NSString *verb = requestType;
    NSString *apiVersion = @"0.1";
    NSString *timestampString = [[NSUserDefaults standardUserDefaults] valueForKey:X_TIMESTAMP];
    if (!timestampString) {
        NSDate *timestamp = [NSDate date];
        if ([[[DCSharedObject sharedPreferences] preferences] valueForKey:TIME_DIFFERENCE]) {
            NSInteger timeDifference = [(NSNumber *)[[[DCSharedObject sharedPreferences] preferences] valueForKey:TIME_DIFFERENCE] intValue];
#if kDebug
            NSLog(@"time_diff in signature: %d", timeDifference);
#endif
            timestamp =  [timestamp dateByAddingTimeInterval:timeDifference];
        }
        
        timestampString = [DCSharedObject strFromISO8601:timestamp];
        
        //remove TIME_DIFFERENCE since using the same delta gives problems
        //in case the system on the client side changes. Hence, every URL is hit with
        //time_difference 0 in the beginning. TIME_DIFFERENCE is always used only once.
        [[[DCSharedObject sharedPreferences] preferences] removeObjectForKey:TIME_DIFFERENCE];
    }
    
    //retrieve randomNumberString
    NSString *randomNumberString = [[[DCSharedObject sharedPreferences] preferences] valueForKey:UNIQUE_SALT];
    NSString *publicKey = [[NSUserDefaults standardUserDefaults] valueForKey:GIZURCLOUD_API_KEY];
    NSString *privateKey = [[NSUserDefaults standardUserDefaults] valueForKey:GIZURCLOUD_SECRET_KEY];
    if (verb && apiVersion && timestampString && publicKey && privateKey) {
        NSString *inputString = [NSString stringWithFormat:@"KeyID%@Model%@Timestamp%@UniqueSalt%@Verb%@Version%@", publicKey, model, timestampString, randomNumberString, verb, apiVersion];
#if kDebug
        NSLog(@"%@", inputString);
#endif
        NSString *signature = [DCSharedObject hmacSHA256WithKey:privateKey andInputString:inputString];
        if (signature) {
            return signature;
        } else {
            return nil;
        }
    }
    return nil;
}
+ (NSString *)hmacSHA256WithKey:(NSString *)key andInputString:(NSString *)inputString {
    
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [inputString cStringUsingEncoding:NSASCIIStringEncoding];
    
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMAC = [[[NSData alloc] initWithBytes:cHMAC
                                          length:sizeof(cHMAC)] autorelease];
    
    return [HMAC base64EncodedString];
    
    
}

+(NSString *)decodeSwedishHTMLFromString:(NSString *)swedishString {
    NSMutableString *retVal = [[swedishString mutableCopy] autorelease];
    if (retVal) {
        BOOL specialCharacterExists = YES;
        while (specialCharacterExists) {
            specialCharacterExists = NO;
            NSRange range = [retVal rangeOfString:@"&Aring;"];
            if (range.location != NSNotFound) {
                [retVal replaceCharactersInRange:range withString:@"Å"];
                specialCharacterExists = YES;
            }
            
            range = [retVal rangeOfString:@"&aring;"];
            if (range.location != NSNotFound) {
                [retVal replaceCharactersInRange:range withString:@"å"];
                specialCharacterExists = YES;
            }
            
            range = [retVal rangeOfString:@"&Auml;"];
            if (range.location != NSNotFound) {
                [retVal replaceCharactersInRange:range withString:@"Ä"];
                specialCharacterExists = YES;
            }
            
            range = [retVal rangeOfString:@"&auml;"];
            if (range.location != NSNotFound) {
                [retVal replaceCharactersInRange:range withString:@"ä"];
                specialCharacterExists = YES;
            }
            
            range = [retVal rangeOfString:@"&Ouml;"];
            if (range.location != NSNotFound) {
                [retVal replaceCharactersInRange:range withString:@"Ö"];
                specialCharacterExists = YES;
            }
            
            range = [retVal rangeOfString:@"&ouml;"];
            if (range.location != NSNotFound) {
                [retVal replaceCharactersInRange:range withString:@"ö"];
                specialCharacterExists = YES;
            }
        }
        
        
        
    }
    return retVal;
}


+(NSString *) strFromISO8601:(NSDate *) date {
    static NSDateFormatter* sISO8601 = nil;
    
    if (!sISO8601) {
        sISO8601 = [[NSDateFormatter alloc] init];
        
        NSTimeZone *timeZone = [NSTimeZone localTimeZone];
        int offset = [timeZone secondsFromGMT];
        
        NSMutableString *strFormat = [NSMutableString stringWithString:@"yyyyMMdd'T'HH:mm:ss"];
        offset /= 60; //bring down to minutes
        if (offset == 0)
            [strFormat appendString:@"Z"];
        else
            [strFormat appendFormat:@"%+02d%02d", offset / 60, offset % 60];
        
        [sISO8601 setTimeStyle:NSDateFormatterFullStyle];
        [sISO8601 setDateFormat:strFormat];
    }
    return[sISO8601 stringFromDate:date];
}

+(void) processLogout:(UINavigationController *)navigationController clearData:(BOOL)clearData{
    
    if (clearData) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_NAME];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:PASSWORD];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:GIZURCLOUD_API_KEY];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:GIZURCLOUD_SECRET_KEY];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:CONTACT_NAME];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:ACCOUNT_NAME];
        
    }
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_LOGGED_IN];
    //remove all the viewControllers from the array and push LoginViewController
    NSMutableArray *viewControllers = [[[navigationController viewControllers] mutableCopy] autorelease];
#if kDebug
    NSLog(@"%@", viewControllers);
#endif
    [viewControllers removeAllObjects];
    navigationController.viewControllers = viewControllers;
    
    DCLoginViewController *loginViewController = [[[DCLoginViewController alloc] initWithNibName:@"LoginView" bundle:nil] autorelease];
    [navigationController pushViewController:loginViewController animated:NO];

}

@end
