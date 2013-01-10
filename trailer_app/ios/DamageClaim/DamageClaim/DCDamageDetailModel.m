//
//  DCDamageDetailModel.m
//  DamageClaim
//
//  Created by Dev on 19/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DCDamageDetailModel.h"

#import "Const.h"

@implementation DCDamageDetailModel
@synthesize damageId = _damageId;
@synthesize damageType = _damageType;
@synthesize damagePosition = _damagePosition;
@synthesize damageImagePaths = _damageImagePaths;
@synthesize damageThumbnailImagePaths = _damageThumbnailImagePaths;
@synthesize surveyModel = _surveyModel;
@synthesize damageDriverCausedDamage = _damageDriverCausedDamage;

-(void) dealloc {
    [_damageId release];
    [_damageImagePaths release];
    [_damageThumbnailImagePaths release];
    [_damagePosition release];
    [_damageType release];
    [_surveyModel release];
    [_damageDriverCausedDamage release];
    [super dealloc];
}

@end
