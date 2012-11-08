//
//  DCAssetModel.m
//  DamageClaim
//
//  Created by Dev on 04/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DCAssetModel.h"

@implementation DCAssetModel
@synthesize trailerId = _trailerId;
@synthesize trailerName = _trailerName;
@synthesize trailerType = _trailerType;

-(void) dealloc {
    [_trailerId release];
    [_trailerName release];
    [_trailerType release];
    [super dealloc];
}
@end
