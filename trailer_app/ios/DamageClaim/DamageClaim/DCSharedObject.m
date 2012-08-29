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

static DCSharedObject *sharedPreferences = nil;


@implementation DCSharedObject

@synthesize preferences = _preferences;


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


+(void)showAlertWithMessage:(NSString *)alertMessage
{
	UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(alertMessage, @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil] autorelease];
	[alertView show];
	
}

+(NSString *) generateSignatureForRequest:(NSURLRequest *)urlRequest model:(NSString *)model requestType:(NSString *)requestType{
    
    //extract the verb i.e. GET POST etc
    NSString *verb = requestType;
    NSString *apiVersion = @"0.1";
    NSString *timestamp = [[NSDate date] description];
    NSString *publicKey = [[NSUserDefaults standardUserDefaults] valueForKey:GIZURCLOUD_API_KEY];
    
    if (verb && apiVersion && timestamp && publicKey) {
        NSString *inputString = [NSString stringWithFormat:@"KEYID%@Model%@Timestamp%@Verb%@Version%@", publicKey, model, timestamp, verb, apiVersion];
#if kDebug
        NSLog(@"%@", inputString);
#endif
        NSString *signature = [DCSharedObject hmacWithSecret:@"9b45e67513cb3377b0b18958c4de55be" forString:inputString];
        if (signature) {
            return signature;
        } else {
            return nil;
        }
    }
    return nil;
}

+ (NSString*) hmacWithSecret:(NSString*) secret forString:(NSString *)string
{
    CCHmacContext    ctx;
    const char       *key = [secret UTF8String];
    const char       *str = [string UTF8String];
    unsigned char    mac[CC_MD5_DIGEST_LENGTH];
    char             hexmac[2 * CC_MD5_DIGEST_LENGTH + 1];
    char             *p;
    
    CCHmacInit( &ctx, kCCHmacAlgMD5, key, strlen( key ));
    CCHmacUpdate( &ctx, str, strlen(str) );
    CCHmacFinal( &ctx, mac);
    
    p = hexmac;
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++ ) {
        snprintf( p, 3, "%02x", mac[ i ] );
        p += 2;
    }
    
    return [NSString stringWithUTF8String:hexmac];
}


@end
