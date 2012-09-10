//
//  RequestHeaders.m
//  Plunk
//
//  Created by GS LAB on 21/05/12.
//  Copyright (c) 2012 developer.gslab@gmail.com. All rights reserved.

#import "RequestHeaders.h"

#import "Const.h"

#import "DCSharedObject.h"


@implementation RequestHeaders

+(NSDictionary *)commonHeaders {
	
    NSString *username;
    NSString *password;
    if ([[[DCSharedObject sharedPreferences] preferences] valueForKey:USER_NAME] && [[[DCSharedObject sharedPreferences] preferences] valueForKey:PASSWORD]) {
        
        username = [[[DCSharedObject sharedPreferences] preferences] valueForKey:USER_NAME];
        password = [[[DCSharedObject sharedPreferences] preferences] valueForKey:PASSWORD];
    }
    
    if (username && password) {
        NSString *timestamp = [DCSharedObject strFromISO8601:[NSDate date]];
        
        //use the same timestamp to generate the signature
        [[NSUserDefaults standardUserDefaults] setValue:[timestamp description] forKey:X_TIMESTAMP];
        NSString *apiKey = [[NSUserDefaults standardUserDefaults] valueForKey:GIZURCLOUD_API_KEY];
        
        NSDictionary *headerDictionary = [NSDictionary dictionaryWithObjectsAndKeys: 
                                          @"text/json", @"Accept", 
                                          username, X_USERNAME, 
                                          password, X_PASSWORD, 
                                          timestamp, X_TIMESTAMP, 
                                          apiKey, X_GIZUR_API_KEY, 
                                          @"sv,en-us,en;q=0.5", @"Accept-Language", 
                                          nil];
        return headerDictionary;
    }
    
    return nil;
}



@end
