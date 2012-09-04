//
//  DCDamageDetailModel.h
//  DamageClaim
//
//  Created by Dev on 19/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCDamageDetailModel : NSObject

@property (nonatomic, retain) NSString *damageType;
@property (nonatomic, retain) NSString *damagePosition;

//These are kept Sets and not Array because
//they need to be merged eliminating duplicates quite often
@property (nonatomic, retain) NSMutableArray *damageImagePaths;
@property (nonatomic, retain) NSMutableArray *damageThumbnailImagePaths;

@end
