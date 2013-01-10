//
//  DCSurveyModel.m
//  DamageClaim
//
//  Created by Dev on 18/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DCSurveyModel.h"

#import "Const.h"


@implementation DCSurveyModel
@synthesize surveyPlace = _surveyPlace;
@synthesize surveyPlates = _surveyPlates;
@synthesize surveyStraps = _surveyStraps;
@synthesize surveyAssetModel = _surveyAssetModel;
@synthesize surveyTrailerSealed = _surveyTrailerSealed;

- (id) init
{
    self = [super init];
    if (self) {
        _surveyAssetModel = [[DCAssetModel alloc] init];
        [_surveyAssetModel retain];
    }
    return self;
}

-(void) dealloc {
    [_surveyPlace release];
    [_surveyPlates release];
    [_surveyStraps release];
    [_surveyAssetModel release];
    [_surveyTrailerSealed release];
    [super dealloc];
}



@end
