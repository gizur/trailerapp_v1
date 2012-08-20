//
//  LPURLConnection.m
//  LottoPicksNewUI
//
//  Created by Dev on 10/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DCURLConnection.h"

@implementation DCURLConnection

@synthesize callType = _callType;

-(id) initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately forCallType:(DC_URL_CALL_TYPE)callType {
    self = [super initWithRequest:request delegate:delegate startImmediately:startImmediately];
    if (self) {
        _callType = callType;
    }
    return self;
}

-(void) dealloc {
    [super dealloc];
}
@end
