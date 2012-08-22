//
//  DCDamageModel.m
//  DamageClaim
//
//  Created by Dev on 19/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DCDamageModel.h"

@implementation DCDamageModel
@synthesize damageType = _damageType;
@synthesize damagePosition = _damagePosition;
@synthesize damageImages = _damageImages;

-(void) dealloc {
    [_damageImages release];
    [_damagePosition release];
    [_damageType release];
    [super dealloc];
}

@end
