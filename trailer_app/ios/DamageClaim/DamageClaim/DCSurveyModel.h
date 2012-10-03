//
//  DCSurveyModel.h
//  DamageClaim
//
//  Created by Dev on 18/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DCAssetModel.h"

@interface DCSurveyModel : NSObject
@property (nonatomic, retain) NSString *surveyTrailerType;
@property (nonatomic, retain) DCAssetModel *surveyAssetModel;
@property (nonatomic, retain) NSString *surveyPlace;
@property (nonatomic, retain) NSNumber *surveyTrailerSealed;
@property (nonatomic, retain) NSNumber *surveyPlates;
@property (nonatomic, retain) NSNumber *surveyStraps;

@end
