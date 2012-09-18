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
        NSString *inputString = [NSString stringWithFormat:@"KeyID%@Model%@Timestamp%@Verb%@Version%@", publicKey, model, timestamp, verb, apiVersion];
#if kDebug
        NSLog(@"%@", inputString);
#endif
        NSString *signature = [DCSharedObject hmacSHA256WithKey:@"9b45e67513cb3377b0b18958c4de55be" andInputString:inputString];
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
    
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC
                                          length:sizeof(cHMAC)];
    
    return [HMAC base64EncodedString];
    
    
}



@end
