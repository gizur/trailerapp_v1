//
//  DCLoginModel.m
//  DamageClaim
//
//  Created by Dev on 19/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DCLoginModel.h"

@implementation DCLoginModel
@synthesize loginPassword = _loginPassword;
@synthesize loginUsername = _loginUsername;


-(void) dealloc {
    [_loginUsername release];
    [_loginPassword release];
    [super dealloc];
}

@end
