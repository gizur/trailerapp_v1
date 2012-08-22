//
//  LPURLConnection.h
//  LottoPicksNewUI
//
//  Created by Dev on 10/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Const.h"

@interface DCURLConnection : NSURLConnection

@property(nonatomic) DC_URL_CALL_TYPE callType;

-(id) initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately forCallType:(DC_URL_CALL_TYPE) callType;
@end
