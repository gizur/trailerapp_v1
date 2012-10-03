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
@synthesize surveyTrailerType = _surveyTrailerType;
@synthesize surveyTrailerSealed = _surveyTrailerSealed;



-(void) dealloc {
    [_surveyPlace release];
    [_surveyPlates release];
    [_surveyStraps release];
    [_surveyAssetModel release];
    [_surveyTrailerSealed release];
    [_surveyTrailerType release];
    [super dealloc];
}



@end
