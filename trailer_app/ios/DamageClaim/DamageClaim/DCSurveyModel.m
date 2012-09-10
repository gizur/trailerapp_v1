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
@synthesize surveyTrailerId = _surveyTrailerId;
@synthesize surveyTrailerType = _surveyTrailerType;
@synthesize surveyTrailerSealed = _surveyTrailerSealed;



-(void) dealloc {
#if kDebug
    NSLog(@"Deallocating surveyPlates: %p", _surveyPlates);
#endif
    [_surveyPlace release];
    [_surveyPlates release];
    [_surveyStraps release];
    [_surveyTrailerId release];
    [_surveyTrailerSealed release];
    [_surveyTrailerType release];
    [super dealloc];
}



@end
