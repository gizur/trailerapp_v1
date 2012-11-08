//
//  DCAssetModel.h
//  DamageClaim
//
//  Created by Dev on 04/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCAssetModel : NSObject
//right now ony trailer id is used
//more fields can be added here later
@property (nonatomic, retain) NSString *trailerId;
@property (nonatomic, retain) NSString *trailerName;
@property (nonatomic, retain) NSString *trailerType;

@end
