//
//  RequestHeaders.m
//  Plunk
//
//  Created by GS LAB on 21/05/12.
//  Copyright (c) 2012 developer.gslab@gmail.com. All rights reserved.

#import "RequestHeaders.h"

#import "Const.h"


@implementation RequestHeaders

+(NSDictionary *)commonHeaders {
	
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:USER_NAME];
    NSString *password = [[NSUserDefaults standardUserDefaults] valueForKey:PASSWORD];
    NSString *timestamp = [[NSDate date] description];
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



@end
