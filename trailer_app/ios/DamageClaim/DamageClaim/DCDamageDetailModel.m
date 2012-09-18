//
//  DCDamageDetailModel.m
//  DamageClaim
//
//  Created by Dev on 19/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DCDamageDetailModel.h"

@implementation DCDamageDetailModel
@synthesize damageType = _damageType;
@synthesize damagePosition = _damagePosition;
@synthesize damageImagePaths = _damageImagePaths;
@synthesize damageThumbnailImagePaths = _damageThumbnailImagePaths;

-(void) dealloc {
    [_damageImagePaths release];
    [_damageThumbnailImagePaths release];
    [_damagePosition release];
    [_damageType release];
    [super dealloc];
}

@end
