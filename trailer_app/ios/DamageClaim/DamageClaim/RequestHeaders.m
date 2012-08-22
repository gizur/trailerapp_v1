//
//  RequestHeaders.m
//  Plunk
//
//  Created by GS LAB on 21/05/12.
//  Copyright (c) 2012 developer.gslab@gmail.com. All rights reserved.

#import "RequestHeaders.h"


@implementation RequestHeaders

+(NSDictionary *)commonHeaders {
	
   NSDictionary *headerDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Plunk for iPhone v.1.0",@"User-Agent", @"application/json", @"Accept", @"application/json", @"Content-Type", nil];
    
    return headerDictionary;
}



@end
