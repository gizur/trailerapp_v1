//
//  RequestHeaders.m
//  DamageClaim
//
//  Created by GS LAB on 21/05/12.
//  Copyright (c) 2012 developer.gslab@gmail.com. All rights reserved.

#import "RequestHeaders.h"

#import "Const.h"

#import "DCSharedObject.h"


@implementation RequestHeaders

+(NSDictionary *)commonHeaders {
	
    NSString *username = nil;
    NSString *password = nil;
    if ([[NSUserDefaults standardUserDefaults] valueForKey:USER_NAME]) {
        username = [[NSUserDefaults standardUserDefaults] valueForKey:USER_NAME];
    } else if ([[[DCSharedObject sharedPreferences] preferences] valueForKey:USER_NAME]) {
        username = [[[DCSharedObject sharedPreferences] preferences] valueForKey:USER_NAME];
    }
    if ([[NSUserDefaults standardUserDefaults] valueForKey:PASSWORD]) {
        password = [[NSUserDefaults standardUserDefaults] valueForKey:PASSWORD];
    } else if ([[[DCSharedObject sharedPreferences] preferences] valueForKey:PASSWORD]) {
        password = [[[DCSharedObject sharedPreferences] preferences] valueForKey:PASSWORD];
    }
    
    if (username) {
        //generate a random number and save it as unique salt
        NSInteger randomNumber = arc4random();
        NSString *randomNumberString = [NSString stringWithFormat:@"%d", randomNumber];
        [[[DCSharedObject sharedPreferences] preferences] setValue:randomNumberString forKey:UNIQUE_SALT];
        
        NSDate *timestamp = [NSDate date];
        
        if ([[[DCSharedObject sharedPreferences] preferences] valueForKey:TIME_DIFFERENCE]) {
            NSInteger timeDifference = [(NSNumber *)[[[DCSharedObject sharedPreferences] preferences] valueForKey:TIME_DIFFERENCE] intValue];
#if kDebug
            NSLog(@"Timestamp: %d", timeDifference);
            NSLog(@"oldDate in requestHeaders: %@", [DCSharedObject strFromISO8601:timestamp]);
#endif
            timestamp = [timestamp dateByAddingTimeInterval:timeDifference];
#if kDebug
            NSLog(@"newDate in requestHeaders: %@", [DCSharedObject strFromISO8601:timestamp]);
#endif
            
        }
        
        NSString *timestampString = [DCSharedObject strFromISO8601:timestamp];
        //use the same timestamp to generate the signature
        [[NSUserDefaults standardUserDefaults] setValue:timestampString forKey:X_TIMESTAMP];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSString *apiKey = [[NSUserDefaults standardUserDefaults] valueForKey:GIZURCLOUD_API_KEY];
        
        NSDictionary *headerDictionary = nil;
        if (apiKey && timestampString) {
            if (password) {
                headerDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  @"text/json", @"Accept",
                                                  username, X_USERNAME,
                                                  password, X_PASSWORD,
                                                  timestampString, X_TIMESTAMP,
                                                  apiKey, X_GIZUR_API_KEY,
                                                  randomNumberString, X_UNIQUE_SALT,
                                                  @"sv,en-us,en;q=0.5", @"Accept-Language",
                                                  nil];
            } else {
                headerDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"text/json", @"Accept",
                                    username, X_USERNAME,
                                    timestampString, X_TIMESTAMP,
                                    apiKey, X_GIZUR_API_KEY,
                                    randomNumberString, X_UNIQUE_SALT,
                                    @"sv,en-us,en;q=0.5", @"Accept-Language",
                                    nil];
            }
        }
        return headerDictionary;
    }
    
    return nil;
}



@end
