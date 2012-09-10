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

-(void) dealloc {
    [_trailerId release];
    [super dealloc];
}
@end
